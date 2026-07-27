# The History Book

*Reading-level experiment · target: high school · rewritten from `docs/posts/0004-the-history-book.md` · original untouched*

---

Sonder is a universe simulator with one rule above all others:
nothing "happens" except an event appended to a log called the
**annals**. Every view of the universe is computed from that log.
Time advances in **ticks**, and a **seed** (the starting number for
the random generator) determines the whole run: same seed, same
universe, bit for bit.

Post 0002 ended on a confession: the annals — the permanent record
every reader is required to trust — was an array in RAM, and closing
the terminal erased history. Fixed. A run now leaves behind a SQLite
database file:

```
$ ./lua src/main.lua --seed 1893 --ticks 200 | tail -2
fingerprint df4d5b9f9f01cc4f
annals archived to out/universe-20260726-183006-seed1893-dev-1.db (401 events)

$ sqlite3 out/universe-*.db "SELECT key, value FROM provenance"
config|{}
engine_version|dev-1
git_commit|435c8d0
interventions|[]
lua_version|Lua 5.4
schema_version|1
seed|1893
sqlite_version|3.53.3
```

The run: seed 1893, 200 ticks, 401 events archived. The second
command queries the file's **provenance** table — the file's own
origins: which engine version wrote it, at which git commit, from
which seed, on which SQLite. A log found on a beach can testify about
where it came from. Files without that testimony can't be reproduced
once they leave the machine that made them — and you cannot add it
retroactively, which is why provenance shipped on day one.

The best demonstration: post 0002's running program could answer
`--why 9` — trace event 9's chain of causes back to the beginning.
Asking the *file* the same question with a SQL query, program not
even running, returns the identical ladder: muster 1, muster 2,
muster 2, muster 4, genesis. Same events, same ids, a different
witness.

## Persistence is just another spectator

Where does the database code live? The obvious move: teach the annals
to write SQLite itself. But then the core knows about files, every
test pays the disk cost, and law 4 — *the sim never knows whether
anyone is watching* — gets a carve-out for one special watcher.

Instead, the archive is a **follower**, built exactly like the
terminal chronicle. It keeps a cursor (a bookmark) over the event
log, and when asked, copies everything it hasn't seen yet:

```lua
local archive = Archive.create(path, u.annals, provenance)
archive:sync()   -- copy the new suffix, in one transaction
archive:close()  -- final sync, let go of the file
```

The sim runs bit-identically with or without it — not because the
archive is polite, but because it has no way in; it reads copies
through the same window every other viewer uses.

One decision hides in `sync()`: *when* to call it. Per-event would
open a transaction 401 times for the run above; once-at-exit would
mean a crash at tick 199 loses everything. We sync at every tick
boundary — one transaction per tick, so a crash costs at most the
current tick and can never tear an event in half.

## The schema: three tables

```sql
CREATE TABLE annals (
   id         INTEGER PRIMARY KEY,  -- the event's position, same as in memory
   tick       INTEGER NOT NULL,
   kind       TEXT    NOT NULL,
   location   TEXT    NOT NULL,
   magnitude  INTEGER NOT NULL,
   visibility TEXT    NOT NULL,
   payload    TEXT    NOT NULL      -- canonical JSON, fields in declaration order
);

CREATE TABLE causes (
   event_id INTEGER NOT NULL REFERENCES annals(id),
   ord      INTEGER NOT NULL,
   cause_id INTEGER NOT NULL REFERENCES annals(id),
   PRIMARY KEY (event_id, ord)
) WITHOUT ROWID;
```

Three things to notice.

**Position is identity.** Event n's `id` is n in memory and n on
disk — no mapping table, no translation layer, just as post 0002
promised.

**Causes get real rows**, not a JSON list stuffed into a text column.
That lets SQL walk the cause graph itself with a *recursive query*:
start from event 9, repeatedly join in the causes of everything found
so far, stop when nothing new appears. That's `--why` reimplemented
by the database engine against pure data — the reasoning survives the
death of the program that wrote it. It's also why the file beats the
live feed: the feed can say the war office mustered 9 levies at tick
9; it cannot say the market's net drift over 200 ticks is +24 without
you reading 200 lines. One `SELECT sum(...)` can.

**Payloads are canonical JSON from our own encoder** — about fifteen
lines that write fields in a fixed, declared order. Not a library
encoder, though one sits right there in `lua_modules/`: a library's
key order is not ours to promise things about, and card 116 will hash
this file's contents — two universes differing only in key order must
not hash apart. Determinism goes down to the commas.

**And the file is append-only.** Four triggers travel inside it:

```sql
CREATE TRIGGER annals_no_update BEFORE UPDATE ON annals
BEGIN SELECT RAISE(ABORT, 'annals is append-only'); END;
```

— likewise for `DELETE`, likewise both on `causes`. Our Lua code
being well-behaved protects nothing once the file is on someone
else's laptop, but these rules travel inside the file. Open a
universe in a raw `sqlite3` shell, try to quietly improve history,
and the database itself says no.

## Provenance at birth

Eight rows, written before the first event. Four are host facts the
archive refuses to invent (engine version, git commit, seed, config)
— supplied by the caller, because the core is never allowed to go
looking. Four it can see itself: `schema_version`, the SQLite and Lua
versions, and `interventions = []`. That empty list is deliberate: an
untouched universe should say "no interventions" with an explicit
`[]`, not a missing key that might mean "recorded before we tracked
them."

And there is **no timestamp anywhere in the file**. A created-at row
would be the only nondeterministic bytes in an otherwise reproducible
artifact — two runs of the same seed produce databases that diff
empty. The wall clock appears only in the *filename*, so a
development session's runs sort like a lab notebook. The name is the
host's note-to-self; the bytes are the universe's.

## The CS underneath

SQLite isn't a file format; it's a transaction machine. The acronym
to know is **ACID** — atomicity, consistency, isolation, durability.
**Atomicity** does the visible work here: each tick's events go in
wrapped in `BEGIN … COMMIT`, all-or-nothing — kill the process
mid-write and the file contains the whole tick or none of it.
**Durability** is the other half: `COMMIT` doesn't return until the
bytes can survive a crash. That guarantee is expensive — the disk
must actually confirm — which is why batching per tick beats
committing per event: the fixed cost is paid once per tick. Big
databases call the same trick *group commit*.

The pleasing part is *how* SQLite delivers atomicity: internally it
keeps its own journal — in its famous mode, a **write-ahead log** —
and formally treats its tables as a summary of that log. So our
source of truth is an append-only event log, persisted by an engine
that persists everything via its own internal append-only log. Logs
all the way down — except SQLite hides its log as plumbing, while
Sonder's log *is the product*, with a query engine attached.

## What we got wrong

**Claude designed the flag backwards.** The card said "a run writes
universe.db"; Claude shipped archiving as opt-in `--db PATH`. Mike
flipped it: every bare run now archives itself into the gitignored
`out/`, because browsing the tables *is* the education. `--db none`
remains for runs that should leave no trace.

**`os.tmpname()` pre-creates the file on macOS.** The test suite's
fresh-path helper collided with our own refuse-to-overwrite rule
before any test logic ran. The helper now deletes what `tmpname`
made — the refusal working exactly as designed, against us first.

**The files came out byte-identical, and we're promising less.** Two
50-tick runs of seed 1893 produce databases `cmp` can't tell apart.
Tempting to advertise; wrong to. SQLite's page layout happens to be
deterministic on one library version, but nobody guarantees it across
versions — a promise you can't keep across a Homebrew upgrade isn't a
promise. The tests compare logical dumps instead. The claim that
matters is *same history*, not *same pages*.

**And a process bug, jointly owned.** Claude built, verified, and
committed the card before Mike had looked at a line — erasing exactly
the editor highlights Mike reviews with. New standing rule: nothing
gets committed until Mike says so.

## Next

The file can testify about its origins — but nothing yet checks that
two universes claiming the same origins lived the same history. Card
116 is that check: a rolling state hash checkpointed into this file,
plus a replay test — same seed, N years, same hash, on every machine,
forever. The history book gets a tamper seal.

Same seed, same history — now on disk. Ask the file why.
