# The universe file — a reference

*What a run writes, exactly (card 166; engine 0.2.0, file layout
v2). The save file is a database and the database is a history
book; this page is its card catalog. Written from
`src/sonder/archive.lua`, which remains the source of truth — if
this page and the DDL disagree, the DDL wins and this page owes a
fix.*

Every run archives to a SQLite file in `out/` (or `--db PATH`, or
nowhere with `--db none`), named by time, seed, and engine version.
The file is self-describing: provenance says where it came from,
the annals is the history, causes make the history walkable, and
checkpoints let anyone verify none of it has been quietly edited.

## The schema

Four tables, six triggers, `PRAGMA user_version = 2` (the *file
layout* version — v2 renamed `visibility` to `loudness` at card
122; distinct from the per-world *vocabulary* `schema_version`,
which lives in provenance).

```sql
CREATE TABLE provenance (
   key   TEXT PRIMARY KEY,
   value TEXT NOT NULL
) WITHOUT ROWID;

CREATE TABLE annals (
   id         INTEGER PRIMARY KEY,  -- the event's position, same as in memory
   tick       INTEGER NOT NULL,
   kind       TEXT    NOT NULL,
   location   TEXT    NOT NULL,
   magnitude  INTEGER NOT NULL,
   loudness   TEXT    NOT NULL,
   payload    TEXT    NOT NULL      -- canonical JSON, fields in declaration order
);

CREATE TABLE causes (
   event_id INTEGER NOT NULL REFERENCES annals(id),
   ord      INTEGER NOT NULL,      -- position in the event's causes array
   cause_id INTEGER NOT NULL REFERENCES annals(id),
   PRIMARY KEY (event_id, ord)
) WITHOUT ROWID;

CREATE TABLE checkpoints (
   tick   INTEGER PRIMARY KEY,  -- the completed tick this seals
   events INTEGER NOT NULL,     -- how many events existed through it
   hash   TEXT    NOT NULL      -- the rolling seal, sixteen hex digits
) WITHOUT ROWID;
```

The six triggers refuse `UPDATE` and `DELETE` on `annals`,
`causes`, and `checkpoints` — history is append-only *in the file
itself*, enforced by the database engine, not by politeness.
`provenance` is deliberately unguarded (it is a label, not
history).

## Provenance — the nine rows

Written once, at file creation, in sorted key order (byte-stable
output is a habit here):

| key | value | supplied by |
|---|---|---|
| `config` | `"{}"` today — no run configuration exists yet | caller (required) |
| `engine_version` | e.g. `"0.2.0"` — the determinism epoch (see the version convention in `src/main.lua`) | caller (required) |
| `git_commit` | `git describe --always --dirty`, or `"unknown"` | caller (required) |
| `interventions` | `"[]"` — present and empty from day one, on purpose (card 121, future) | archive |
| `lua_version` | Lua's `_VERSION` | archive |
| `schema_version` | the world's vocabulary version, as decimal text | archive |
| `seed` | the seed, as decimal text | caller (required) |
| `sqlite_version` | SQLite's version | archive |
| `world` | which world wrote this file (e.g. `continent`) — card 167, paying ADR 0004's requirement that three worlds' archives never be confusable | caller (required) |

One reading note: `schema_version` is the **world's** vocabulary
version, meaningful only beside the `world` row (space's v3 and
the continent's v2 are different vocabularies, not one vocabulary
at two ages). A world's version *is* its vocabulary's version —
one world, one vocabulary, one number.

## Write behavior

- `Archive.create` refuses to open a path that already exists —
  *"refusing to overwrite history."*
- `Archive:sync()` copies the annals' un-copied suffix in one
  transaction; `main.lua` syncs once per tick, so a tick is the
  durability quantum.
- Payloads are written through `byteform` — canonical JSON with
  fields in vocabulary-declaration order, the **same bytes the
  seal hashes**. The archive and the seal can never disagree about
  what an event looks like.
- Foreign keys are enforced on the writing connection only
  (`PRAGMA foreign_keys` is connection-scoped in SQLite); a later
  `sqlite3` shell opens the file with enforcement off unless you
  turn it on yourself.
- There are no explicit indexes. `annals.id` and the `WITHOUT
  ROWID` primary keys are the only fast paths: queries by `kind`,
  or reverse cause-walks (`WHERE cause_id = ?`), are full scans —
  fine at today's sizes, worth knowing before you loop one.

## Checkpoints — the seal trail

A checkpoint for tick T is written only once an event from a later
tick proves T complete: `hash` is the rolling seal over all events
with `tick <= T`, and `events` counts them. Rows land every
`checkpoint_every` ticks (default 100) — and `Archive:close()`
always writes a final checkpoint sealing the entire history, so
**every well-closed universe file ends with its own fingerprint.**
Any tool can recompute the fold from the log alone and compare;
see [`verification.md`](verification.md) for the procedure, and
post 0005 for why the seal is built the way it is.

## A query cookbook

```sh
# where did this file come from?
sqlite3 out/universe-*.db "SELECT key, value FROM provenance"

# what happened, by kind?
sqlite3 out/universe-*.db "SELECT kind, count(*) FROM annals GROUP BY kind"

# the seal trail — is the history intact?
sqlite3 out/universe-*.db "SELECT * FROM checkpoints ORDER BY tick"

# read a day of history
sqlite3 out/universe-*.db "SELECT id, kind, location, magnitude, payload
   FROM annals WHERE tick = 86 ORDER BY id"

# why did event 214 happen? (one rung of the --why ladder)
sqlite3 out/universe-*.db "SELECT a.* FROM causes c JOIN annals a
   ON a.id = c.cause_id WHERE c.event_id = 214 ORDER BY c.ord"

# what did event 214 cause? (a reverse walk — full scan, see above)
sqlite3 out/universe-*.db "SELECT a.* FROM causes c JOIN annals a
   ON a.id = c.event_id WHERE c.cause_id = 214"

# every letter the roads took, and what each was carrying
sqlite3 out/universe-*.db "SELECT l.tick, l.payload, a.kind AS carried
   FROM annals l JOIN causes c ON c.event_id = l.id
   JOIN annals a ON a.id = c.cause_id
   WHERE l.kind = 'continent.letter-lost'"
```
