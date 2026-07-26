# Notebook — 114-event-bus

Card 114: *Event bus + event vocabulary v1 + terminal chronicle.*
Done when: the sim emits events and the terminal renders a readable
feed from them alone. Ships with post 0002 *The Event Log*, tag
`post/0002`.

## Session 1 (2026-07-25)

### What's already decided (inherited, not ours to relitigate)

- Law 2, verbatim: nothing "happens" except an append to the annals.
  Every event carries **tick, kind, location, magnitude, visibility,
  payload, and cause links** (ids of the events that caused it). All
  state views, chronicles, and statistics are projections of it.
- The vocabulary is a **public API**: versioned schema, documented
  migrations, append-mostly kinds. Events are the edge of the system,
  so they are strict from day one (the harden-from-the-edges rule).
- Law 4: the core is headless. The chronicle subscribes to the sim;
  the sim must run bit-identically whether zero or many observers are
  attached.
- Scope fences from the board: **115** owns SQLite + provenance (114's
  annals live in memory, shaped so a database can drop in underneath),
  **117** owns the belief store (114 stamps visibility but nothing
  consumes it yet), **118** owns the toy world (so 114's emitting
  systems are still the placeholder market/war drifters).

### The design space (drafted for discussion, nothing decided yet)

**1. Event identity.** Cause links need ids. Candidates: (a) **the
event's position in the annals** — a sequential integer, 1-based;
deterministic because emission order is deterministic (systems run in
array order, law 1); doubles as the natural SQLite rowid when 115
arrives. (b) Content hashes — deterministic but circular (the id would
have to hash the cause ids of events that don't have ids yet) and
unreadable in a terminal. (c) UUIDs — nondeterministic, forbidden on
sight. Leaning (a); it's also the teachable one (a log offset *is* an
identity — the Kafka lesson).

**2. Emission API and timing.** Systems get handed the bus (or the
universe exposes `emit`), and an append happens **immediately** —
mid-tick, not queued to the tick boundary — because a system that
causes two linked events needs the first id before emitting the
second. The event's `tick` field is stamped by the bus from the
universe clock, not passed by the caller (one less thing to lie
about). Question for discussion: does `emit` return the id, the whole
event, or nothing?

**3. How strict is strict?** Proposal: `emit` validates at the door —
`kind` must be registered in the vocabulary; required envelope fields
present and correctly typed (integers where law 1 demands); payload
checked against the kind's declared payload schema; unknown payload
fields rejected. A bad event is a **hard error, not a warning** — in a
deterministic sim a malformed event either always happens or never
does, so failing loudly at emit is free and failing quietly is a
forensic nightmare later.

**4. What the vocabulary looks like as code.** A declaration module
(`sonder/vocabulary.lua`?): each kind declares its payload fields with
types, plus a doc line. The vocabulary carries a **schema version**
(an integer, starts at 1) that 115 will write into provenance.
"Append-mostly" pre-0.1: we reserve the right to churn kinds freely
until v0.1 ships, and say so in the post — versioned-schema discipline
starts now, migration discipline starts when there's a universe worth
migrating.

**5. Which kinds exist in v1?** The only emitters are the two
placeholder systems. Sketch: `market.drift` (payload: the drift
integer) and `war.muster` (payload: the muster integer) — placeholder
kinds we expect 118 to replace, plus maybe `universe.genesis` (tick 0,
the first row of every annals, carrying the seed — every chain of
cause links ultimately terminates there, which is a nice invariant
*and* a nice sentence). Question: is genesis an event, or is that
provenance's job (115)?

**6. Location and magnitude before geography exists.** There is no map
until 125 and no civs until 118. Options: (a) make `location` a free
string now (`"the-void"`, later `"sector:12"`) and tighten when
geography arrives; (b) allow nil until someone has somewhere to stand.
Law 2 says every event *carries* location — proposal: required string,
placeholder value, tighten later. Same question for magnitude:
proposal — required integer, and the placeholder systems' draws are
honest magnitudes.

**7. Visibility v1.** Nothing consumes it until 117. Proposal: a
required enum from a small closed set — `public | regional | secret` —
stamped honestly by emitters, filtered by nobody yet. The alternative
(numeric visibility radius) needs geography we don't have. The enum
can gain members append-mostly.

**8. Bus vs log — what "subscribe" means.** The purist reading of law
2: the annals array **is** the interface; the chronicle is a function
over it (`chronicle(annals) → lines`), re-runnable from any prefix,
trivially replayable when 115 gives us persistence. The observer
reading: `bus:subscribe(fn)` callbacks fire on append — live, but now
subscriber code runs *inside* the sim's tick, where an error or a
sneaky write violates law 4 structurally rather than politely.
Proposal: **projection, not callbacks** — the chronicle reads the log
after the fact and keeps a cursor. Live-following is just "call me
again with the new suffix". This is also the CS heart of post 0002:
event sourcing, log offsets, projections as pure functions.

**9. Chronicle rendering.** A renderer module keyed by kind: each
vocabulary entry supplies (or the chronicle owns?) a template turning
an event into a sentence — `tick 12 · the-void · market drifts +3`.
Unknown kind → render a generic line rather than crash (the chronicle
is a viewer; viewers of old logs will meet kinds younger than they
are — forward compatibility is a viewer's problem and a good lesson).
Question: do render templates live in the vocabulary (one place per
kind) or in the chronicle (the sim shouldn't know how it's displayed —
law 4 smell)?

**10. Payload discipline for a future database.** Payloads are Lua
tables today, SQLite rows tomorrow. Proposal: payload values limited
to **integers and strings** (law 1 already bans floats from outcomes),
no nesting, and payload schemas declare fields **in order** so
anything that iterates a payload (rendering, future hashing) walks the
declaration array, never `pairs()`.

### Proving "done"

Busted specs, sketched: (a) emit appends, ids are sequential, tick is
stamped from the clock; (b) strictness — unregistered kind, missing
field, wrong type, unknown payload field, dangling cause id all error;
(c) cause links resolve and terminate at genesis; (d) headless — same
seed, chronicle attached vs not, identical annals (law 4 as an
executable claim); (e) golden chronicle — fixed seed, N ticks, exact
expected terminal text; (f) determinism — same seed twice, identical
annals including ids and cause links.

### Decisions (round 1)

- **Decision (Mike): projection, not callbacks.** The annals array is
  the interface; the chronicle is a pure function over it with a
  cursor. No subscriber code ever runs inside the sim's tick.
- **Decision (Mike): genesis is an event.** Tick 0, first row of every
  annals, carries the seed. Provenance (115) records *how the universe
  was made* (engine version, config); genesis records *that it began*
  — an event, because law 2 says nothing happens except an append.
- **Decision (Mike): location is a required placeholder string
  (`"the-void"`) until geography exists; visibility is a small closed
  enum now, granular ranges later if ever needed.**

### Round 2 — clarifying templates (Q9) and emit's return (Q2)

- **Mike: "I don't grasp *viewers of old logs will meet kinds younger
  than they are*."** — Fair, because the sentence was backwards as
  written. The real shape: **viewers meet logs younger than they
  are.** The annals is durable data that outlives any particular
  viewer version — the lineage requirement (universes crossing engine
  versions), the synopsis tool (comparing universes made by different
  versions), and seed reports (someone else's universe file) all point
  a chronicle at annals containing kinds added to the vocabulary
  *after* that chronicle was written. Crash-on-unknown makes every old
  tool useless against every new log. Hence the asymmetry, deliberate
  and opposite on each side: **emit is strict** (a malformed event
  written today corrupts history forever) while **the chronicle is
  tolerant** (an unknown kind renders as a generic line from the
  envelope fields, which every event of every era carries). Writes are
  forever; readers age.
- Mike inclined to make unknown kinds a viewer problem (fallback
  rendering), understanding the terminal chronicle is a viewer.

### Decisions (round 2)

- **Decision (Mike): templates live in the chronicle** (option B).
  The vocabulary declares what happens; each viewer decides how to say
  it, with a safe generic fallback for unknown kinds. A coverage spec
  binds this repo's chronicle to this repo's vocabulary (can't add a
  kind and forget its sentence) while the runtime fallback handles
  logs written by other eras. Mike can imagine third-party clients
  someday — a conformance suite for the unknown-kind problem is a
  problem for another day (captured as a triage card).
- **Decision (Mike): `emit` returns the id.** On an invalid event it
  raises — there is no nil return, no soft-failure path into the log.
- **Decision (Mike): causes are required; drifts chain.** Every event
  except genesis must cite at least one cause. Markets don't just
  move, wars don't just start, asteroids don't just exist — an event
  may look random to the civilization it lands on, but something
  caused it. Placeholder drifts each cite the previous drift (first
  one cites genesis), so every chain provably terminates at event 1.
- **Decision (Mike): visibility enum is `public | regional | secret`**
  — blessed, not precious about it.
- **Decision (Mike): v1 kinds are `universe.genesis`, `market.drift`,
  `war.muster`** — all temporary, expected to churn before v0.1.
- Captured as card 128 (triage): viewer conformance suite for
  third-party chronicle clients — the unknown-kind contract as
  something clients we didn't write can test against.

### What we built

- `src/sonder/vocabulary.lua` — the public API as data: schema_version
  (1), the visibility set, three kinds, each with a doc line and an
  **ordered** payload declaration (`{name, type}` array — nothing that
  walks a payload ever needs `pairs()`; types are integer|string only,
  flat and SQLite-shaped for 115).
- `src/sonder/annals.lua` — the append-only log. `append(tick, spec)`
  validates everything at the door (unregistered kind, missing/extra
  envelope fields, float magnitudes, off-enum visibility, mistyped/
  missing/extra payload fields, bad causes, backwards time) and raises
  on any of it; returns the id, which is the event's position.
  Copy-in and copy-out: the log never stores a caller's table and
  `get()` returns fresh copies — append-only by structure, not
  politeness. Genesis rules enforced: once, first, uncaused; a cause
  must be `1 <= id <= len` (only the past causes the present, and an
  event can't cite itself because its id doesn't exist yet).
- `src/sonder/universe.lua` — universes now carry an annals;
  `Universe.new` emits genesis (tick 0, `the-void`, the seed in the
  payload) so event 1 exists before anything else can; `u:emit(spec)`
  stamps the current tick (callers don't get to lie about when) and
  returns the id.
- `src/sonder/chronicle.lua` — the first projection. Sentence
  templates per kind, the sorted-keys envelope fallback for unknown
  kinds, and a cursor (`lines()` returns what's new; a fresh chronicle
  over the same annals is a replay).
- `src/main.lua` — the feed. Placeholder systems now emit chained
  events (drift causes drift, muster causes muster, first of each
  cites genesis); fingerprint is now folded over the rendered feed
  bytes; `--why N` walks event N's cause links back to genesis and
  prints the ladder.
- Specs: `vocabulary_spec` (declaration holds its own rules),
  `annals_spec` (strictness, copies, genesis, causes, determinism),
  `chronicle_spec` (template coverage over the vocabulary, golden
  lines per kind, unknown-kind fallback, cursor/replay, golden feed
  for seed 1893, law 4 as an executable claim), plus genesis/emit
  additions to `universe_spec`. 58 specs green.
- Verified: `./lua src/main.lua --seed 1893 --ticks 10` twice →
  byte-identical, fingerprint over the feed; `--why 9` prints the
  muster chain down to genesis.

### What broke / what surprised us (post material)

- **The first spec failure of the card was in the test, again.**
  `assert.has_error(fn, msg)` treats its second argument as the
  *expected error string*, not a failure label — a habit imported
  from `assert.is_true(cond, msg)` where the second argument *is* a
  label. The test failed because the annals raised the right error
  with the wrong words. Same lesson as 113's zero-state test, new
  costume: know which side of the assertion the string is on.
- **Genesis magnitude is 0** and it reads odd — the largest thing
  that will ever happen, magnitude zero. Magnitude has no scale until
  118 gives it one; 0 is an honest "unscaled". Post-worthy footnote.
- **`math.abs` keeps the integer subtype** in Lua 5.4 (used for
  drift → magnitude), worth a line in the post since law 1 hangs on
  subtypes surviving arithmetic.

## Session 2 (2026-07-25, same day) — the post

Mike interrogated the implementation and signed off; drafted
`docs/posts/0002-the-event-log.md`. Shape: the 5-tick feed plus the
`--why 9` ladder as the excerpt (fingerprint `30022225827550c9` — from
the 5-tick run, not the 10; the 0001 lesson about quoting fingerprints
at the right run length, remembered this time) → design (append or it
didn't happen, stamped tick/id, visibility-can't-be-retrofitted,
required causes and the DAG-by-construction argument, the strictness
asymmetry, vocabulary as declared data, projection over callbacks,
copies both directions) → CS (event sourcing: ledgers, git's commit
DAG, Kafka offsets/cursors, WALs; projections as pure functions; the
log-is-a-cache-and-also-the-truth paradox given determinism) → what
we got wrong (the backwards viewers/logs sentence from our own design
chat, the has_error label-vs-expected-message test bug, the genesis
magnitude-0 wart put on public record for card 118 to fix or defend).
