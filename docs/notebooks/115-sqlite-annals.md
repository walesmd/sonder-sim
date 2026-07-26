# Notebook — 115-sqlite-annals

Card 115: *SQLite annals + provenance table.* Persist the event log
with lsqlite3: an append-only annals table, plus the day-one
provenance table — engine version, git commit, seed, config, schema
version, intervention log. The save file is a database; the database
is a history book. Done when: a run writes universe.db and SQL can
answer questions the terminal feed can't.

## Session 1 (2026-07-26)

### What's already decided (inherited, not ours to relitigate)

- Day-one requirement, verbatim: every universe DB carries a
  provenance table — engine version, git commit, seed, config, schema
  version, intervention log.
- ADR 0002 made a promise this card must keep: the SQLite *library*
  version floats with the machine, so **the provenance table records
  it per universe**.
- lsqlite3 is pinned `== 0.9.5` in rocks.lock; doctor.lua already
  proves it loads and round-trips. No new dependencies.
- Card 114 shaped the annals for exactly this moment: payload values
  are integers and strings only, flat, declared **in order** — "one
  bind away from a SQLite column" (vocabulary.lua's own comment). The
  vocabulary's `schema_version` comment says card 115 writes it into
  provenance. Event ids are already the natural rowid.
- Scope fences from the board: **116** owns the rolling state hash and
  golden-master replay (so 115 does not hash anything), **121** owns
  interventions and apocrypha (so the intervention log ships *empty*,
  not absent), **124** owns lineage across engine versions (so 115
  records provenance but doesn't migrate anything).

### The design space (drafted; decisions marked, all awaiting Mike's
### interrogation)

**1. Where does persistence sit — inside the annals or beside it?**
(a) Teach `Annals` to write SQLite itself — but then the core knows
about files, and every spec pays the disk tax. (b) A second,
DB-backed annals implementation — two sources of truth, divergence
waiting to happen. (c) **A follower** — the same shape as the
chronicle: a cursor over `annals:get()`, copying new events into the
database at sync points. The sim never knows it's being archived (law
4 does double duty: persistence is just another subscriber). Leaning
(c), implemented as `src/sonder/archive.lua`. The nice consequence:
the in-memory annals stays the interface, and the DB is provably a
projection *of the log* — while being, on disk, the log's durable
form.

**2. One payload column or many tables?** Per-kind tables (one column
per payload field) are maximally SQL-native but mean DDL churn on
every vocabulary addition. A key-value side table is queryable but
shreds an event across rows. **Leaning: one `payload` TEXT column
holding canonical JSON** — fields in declaration order (the
vocabulary's ordered arrays exist precisely so nothing ever walks
`pairs()`), our own ~20-line encoder so the bytes are deterministic on
every machine. SQLite's JSON functions make it queryable:
`json_extract(payload, '$.drift')`. dkjson is already in the tree
(busted dependency) but its key order isn't ours to control —
deterministic bytes beat a dependency.

**3. Causes: JSON array or real rows?** Real rows. A `causes` table
(`event_id, ord, cause_id`) with foreign keys makes the cause DAG a
thing SQL can walk — a recursive CTE is `--why` without the
terminal. That query is the card's "questions the feed can't answer"
demo, and the post's CS section (recursive CTEs over DAGs).

**4. Append-only by structure, again.** The in-memory annals hands
out copies so history can't be edited in place. The DB equivalent:
`BEFORE UPDATE` / `BEFORE DELETE` triggers on `annals` and `causes`
that `RAISE(ABORT)`. The database itself enforces law 2 — not the
Lua code that happens to write it, and not politeness.

**5. Provenance: one row or key-value?** Key-value (`key TEXT PRIMARY
KEY, value TEXT`). Adding a provenance fact later is an INSERT, not
an ALTER TABLE. Keys at birth: `engine_version`, `git_commit`,
`seed`, `config`, `schema_version` (the *vocabulary's* version, per
its own comment), `sqlite_version` (ADR 0002's promise),
`lua_version`, and `interventions` = `[]` — the intervention log,
empty because canon has none and card 121 owns making it real. The
*database layout* version is a separate thing from the event-schema
version; it lives in SQLite's own `PRAGMA user_version` (= 1).

**6. Who supplies provenance values?** The archive can't invent them:
git commit and engine version are host facts, and the core must never
reach for them (no `io.popen` anywhere near sim code). So
`Archive.create(path, provenance)` takes them as arguments and
*requires* them — a universe.db with blank provenance is the
retrofit-brutal future we were warned about. main.lua gathers:
engine version from the rockspec's "dev-1", git commit from
`git describe --always --dirty` (host-side, in the viewer layer,
where the wall clock and the shell are legal), config `{}` honestly —
there is no config yet; card 118 will put real shape here.

**7. No wall-clock timestamp in provenance — deliberately.** A
created-at would be the only nondeterministic byte in the file. Two
runs of the same triple should produce databases that *diff empty*;
that's a property worth more than knowing when a file was made (the
filesystem remembers that anyway).

**8. When to write?** Per-event INSERTs would fsync-storm; buffering
everything to close() loses history on a crash. **Leaning: sync at
tick boundaries** — `archive:sync()` wraps everything new in one
transaction. Durability quantum = the tick, which is also the sim's
own quantum of time. This is the post's other CS thread: transactions,
WAL, group commit — the annals is itself a write-ahead log, so we're
writing a WAL into a WAL.

**9. Fresh file or resume?** `Archive.create` refuses a path that
already exists. Overwriting a universe.db is destroying a history
book; resuming one is lineage (card 124's problem, with checkpoints
and version records we don't have yet). Deleting is the user's
explicit act, not our default.

**10. Does main.lua write universe.db by default?** The card's
done-when says "a run writes universe.db". Leaning: an explicit
`--db universe.db` flag rather than a default side effect — a
determinism demo that silently drops files feels wrong, and
"refuses to overwrite" (Q9) would make the *second* default run an
error. Flagged for Mike: if "a run" must mean "the bare run", flip
the default and make the second run's error a feature.

### What we built

- `src/sonder/archive.lua` — the follower. `Archive.create(path,
  annals, provenance)` makes a fresh universe file (refusing paths
  that exist), writes the schema (`annals`, `causes`, `provenance`,
  `PRAGMA user_version = 1`, RAISE(ABORT) triggers), and writes
  provenance at birth: the four host facts the caller must supply
  (`engine_version`, `git_commit`, `seed`, `config`) plus the four
  the archive can see itself (`schema_version` from the vocabulary,
  `sqlite_version`, `lua_version`, `interventions = []`). `sync()`
  copies the new suffix of the annals in one transaction and returns
  the count; `close()` syncs, finalizes, lets go. Payloads go in as
  canonical JSON from a ~15-line encoder walking the declaration
  order; causes go in as real rows.
- `src/main.lua` — `--db PATH` flag: gathers host provenance
  (`git describe --always --dirty` via `io.popen`, legal on the
  viewer side of the law-4 line), syncs at every tick boundary,
  closes at the end, reports `annals archived to PATH (N events)`.
  A path that already exists is a clean one-line stderr death, like
  every other CLI misuse.
- `tests/archive_spec.lua` — 9 specs: provenance at birth (all eight
  rows + user_version), required-host-facts validation, refusal to
  overwrite, sync copies exactly the suffix, disk history == memory
  history event by event (envelope + causes), canonical payload JSON
  reachable by `json_extract`, UPDATE/DELETE aborted by the file
  itself, same seed → identical logical dumps, closed archive is
  spent. Suite: 67 green (58 + 9).
- Demo (the card's done-when): a 200-tick run wrote universe.db;
  SQL answered what the feed can't — mean drift 0.12 and net drift
  +24 across 200 ticks, mean muster 4.515, the three biggest musters
  with their ticks, and a recursive CTE walking event 9's cause
  chain back to genesis (`--why`, without the terminal).

### What broke / what surprised us (post material)

- **The raw .db files came out byte-identical**, not just the logical
  dumps — `cmp` agrees, two runs of seed 1893 for 50 ticks. Stronger
  than we promised, and we should *keep* promising only the logical
  dump: SQLite page layout happens to be deterministic for identical
  operation sequences on one library version, but nobody guarantees
  it across versions. The spec compares dumps, not files, on purpose.
- **`os.tmpname()` pre-creates the file on macOS** — so the spec's
  fresh-path helper collided with our own refuse-if-exists rule
  before any test logic ran. The helper deletes what tmpname made;
  the collision is a tiny proof the refusal works.
- **The dirty-tree confession works**: provenance recorded
  `git_commit = 2ffca37-dirty` during development. A universe written
  from uncommitted code says so, forever. (`--dirty` was the whole
  reason to use `git describe` over `rev-parse`.)
- **`sqlite3.version()` returned 3.53.3 from Homebrew's keg** — the
  floating library ADR 0002 warned about, now pinned down per
  universe in provenance, exactly as that ADR promised.
- Demo queries lean on SQLite's JSON1 (`json_extract`), which is
  compiled into effectively every modern SQLite. The *write* path
  depends on no JSON support at all — payload is just a TEXT column
  we happen to fill with canonical JSON.

### Proving "done"

- Specs: schema exists (tables, triggers, pragma); provenance rows
  match what was passed; sync copies exactly the new suffix; payload
  JSON is canonical (declaration order, escaping); causes rows match;
  UPDATE and DELETE on annals/causes abort; create refuses an
  existing path; same seed → two databases whose dumps are
  byte-identical.
- The demo: run with `--db`, then answer questions the feed can't —
  average drift across all of history, biggest muster, event counts
  by kind, and a recursive CTE that walks an event's cause chain back
  to genesis (SQL `--why`).
