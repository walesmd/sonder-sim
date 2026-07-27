# The History Book

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0004-the-history-book.md` · original untouched*

---

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

$ sqlite3 out/universe-*.db "
    WITH RECURSIVE why(id) AS (
       SELECT 9
       UNION
       SELECT c.cause_id FROM causes c JOIN why ON c.event_id = why.id
    )
    SELECT a.id, a.tick, a.kind, a.payload
    FROM annals a JOIN why USING (id) ORDER BY a.id DESC"
9|4|war.muster|{"muster":1}
7|3|war.muster|{"muster":2}
5|2|war.muster|{"muster":2}
3|1|war.muster|{"muster":4}
1|0|universe.genesis|{"seed":1893}
```

Post 0002 admitted the annals — the event log every projection
depends on — lived only in RAM. Fixed: a run now emits a SQLite
universe file, and the recursive query above is the equivalence
proof. Asking the *file* for event 9's causal ancestry reproduces the
exact ladder the live `--why 9` printed — same events, same ids —
with the writing process dead.

The provenance table is the ship-now-or-never part. Every universe
file opens with its own attestation: engine version, git commit,
seed, vocabulary schema version, host SQLite. A file without embedded
provenance is unreproducible the moment it leaves its origin machine,
and provenance cannot be added retroactively to files already in the
wild — hence its position on the day-one list.

## Persistence as a subscriber

The load-bearing design decision: the archive is *not* the annals
learning to write SQLite. That would put file I/O in the core, tax
every spec with disk latency, and carve an exception into law 4 (the
sim never knows whether anyone is watching). Instead the archive is a
follower, structurally identical to the terminal chronicle: a cursor
over `annals:get()`, copying the unseen suffix on demand.

```lua
local archive = Archive.create(path, u.annals, provenance)
archive:sync()   -- copy the new suffix, in one transaction
archive:close()  -- final sync, let go of the file
```

Bit-identical execution with or without the archive is structural,
not behavioral — it reads copies through the same interface as every
other viewer. Law 4 doubles as the persistence seam: "the core is
headless" and "the core doesn't know about disks" are the same
sentence.

Sync cadence: per-event would open 401 transactions for the run
above; sync-at-exit loses everything on a crash at tick 199. The
choice is one transaction per tick boundary — worst-case loss is the
current tick, and no event (or its `causes` rows) can be torn. The
durability quantum equals the simulation's time quantum.

## Schema

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

Position-as-identity carries over verbatim: event n's `id` is n in
memory and n on disk — no mapping table. Envelope fields map to
columns one-for-one; the vocabulary constrained payloads to flat,
ordered, integer-or-string fields precisely so this mapping would be
boring.

**Causes are relational rows, not embedded JSON**, because the
recursive CTE above walks the cause DAG inside the query engine —
`--why` reimplemented by SQLite against pure data, surviving the
death of the program that wrote it. This is the card's done-when
("SQL can answer questions the terminal feed can't"): the feed
reports 9 levies mustered at tick 9; it cannot report the market's
net drift over 200 ticks is +24 without a human scanning 200 lines.
`SELECT sum(json_extract(payload, '$.drift'))` can.

**Payloads use canonical serialization** — a ~15-line in-house
encoder emitting fields in vocabulary declaration order with total
escaping. dkjson sits unused in `lua_modules/` because a library's
key order is not a contract, and card 116 will hash file contents:
two universes differing only in key order must not hash apart.
Determinism extends to the byte level.

**The file is append-only by trigger.** Four triggers —
`UPDATE`/`DELETE` on both tables:

```sql
CREATE TRIGGER annals_no_update BEFORE UPDATE ON annals
BEGIN SELECT RAISE(ABORT, 'annals is append-only'); END;
```

Post 0002 made the in-memory log append-only by structure; this is
the on-disk analogue. Well-behaved Lua enforces nothing on someone
else's laptop, but triggers travel inside the file: a raw `sqlite3`
shell attempting to revise history is refused by the database itself.

## Provenance semantics

Eight rows, written before the first event. Four are host facts the
archive refuses to invent — engine version, git commit, seed, config
— caller-supplied, because only the host knows them and the core may
not go looking (no shelling out near sim code; `main.lua`, on the
viewer side of the law-4 line, legally runs `git describe --always
--dirty`). Four are archive-observable: the vocabulary's
`schema_version` (which now buys two files knowing whether they speak
the same dialect), SQLite and Lua versions, and `interventions = []`.

The empty list is a deliberate shape: canon has an intervention log
with nothing in it, distinguishable from a missing key that could
mean "predates recording." Card 121 makes interventions real; the
slot has existed since the first file.

Two absences are load-bearing. `config` is honestly `{}` until card
118 adds real knobs. And **no timestamp exists anywhere in the
file** — a created-at row would be the only nondeterministic bytes in
an otherwise reproducible artifact. Two runs of the same triple
produce databases that diff empty. The wall clock appears only in the
filename (`universe-20260726-183006-seed1893-dev-1.db`, so dev runs
sort like a lab notebook): the name is the host's annotation; the
bytes are the universe's. Identical runs, identical databases,
different names.

(`sqlite_version|3.53.3` is ADR 0002 kept: rocks are pinned but the
SQLite library floats with the machine, so each universe records
which one wrote it.)

## The CS: the log meets the ledger machine

SQLite is a transaction machine, and the operative letters are
**ACID**. Atomicity does the visible work: `sync()` wraps each tick
in `BEGIN … COMMIT`; a mid-write kill leaves the whole tick or none
of it — never a torn event or orphaned `causes` rows. Durability is
the other half: `COMMIT` doesn't return until the bytes survive a
crash, bought with `fsync`, which is expensive because the disk must
actually confirm. That cost structure is why batch-per-tick beats
commit-per-event — the fixed durability cost amortizes once per tick.
At scale the same amortization is called **group commit**.

The mechanism is the pleasing part: SQLite delivers atomicity via a
journal — rollback journal by default, **write-ahead log** in its
better-known mode — and formally treats tables as a materialized view
of that log. Post 0002 called this "event sourcing in the basement."
So the card's actual move: an append-only event log as source of
truth, persisted by an engine whose own persistence is an internal
append-only log. Logs all the way down — SQLite hides its log as an
implementation detail; Sonder's log is the product, with a query
engine attached.

The query engine is the payoff. **Recursive CTEs** (SQL:1999, in
SQLite since 2014) make SQL expressive enough to walk graphs: the
`why` query seeds with event 9 and joins `causes` against its own
result to a **fixpoint**; `UNION`'s duplicate elimination is the
visited set guaranteeing termination on any finite graph, cycles
included. Ours cannot cycle — post 0002's only-the-past-causes-the-
present rule makes the log a DAG by construction — so the recursion
is also correct forensics: strictly backwards in time, genesis the
only fixed point.

## What we got wrong

**The flag was designed backwards.** The done-when read "a run writes
universe.db"; Claude shipped opt-in `--db PATH`, reasoning a
determinism demo shouldn't silently drop files. Mike inverted it:
every bare run archives into gitignored `out/`, because browsing the
tables *is* the education. `--db none` remains for trace-free runs.

**`os.tmpname()` pre-creates the file on macOS.** The spec suite's
fresh-path helper tripped `Archive.create`'s refuse-to-overwrite
check before any test logic ran. The helper now deletes what
`tmpname` made; the collision stands as the refusal working as
designed, against us first.

**Byte-identical output, deliberately under-promised.** Two 50-tick
runs of seed 1893 yield databases `cmp` cannot distinguish. SQLite's
page layout happens to be deterministic for identical operation
sequences on one library version, but that is not guaranteed across
versions, and a promise that dies on a Homebrew upgrade isn't one.
The spec compares logical dumps — every table, every row,
deterministic order. The invariant is *same history*, not *same
pages*.

**Process bug, jointly owned.** Claude built, verified, and committed
before Mike reviewed a line — destroying the editor's
diff-against-last-commit gutter marks Mike reviews with, inverting
"Mike interrogates the code" into "Mike interrogates the commit."
Standing rule now: nothing is committed until Mike says so.

## Next

The file testifies about its origins; nothing yet verifies two files
claiming the same origins lived the same history. Card 116: a rolling
state hash checkpointed every N ticks into this file, plus a
golden-master replay test — same seed, N years, same hash, every
machine, forever. The history book gets a tamper seal.

Same seed, same history — now on disk. Ask the file why.
