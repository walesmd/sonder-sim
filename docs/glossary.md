# Glossary

The project's working vocabulary — what a word means when this repo
says it, in code, posts, or conversation. Each entry points at the
post that earned the term, where one exists. The rule (from the
working agreement): a card that coins a term a reader would need
adds it here, in the same PR.

## The universe and its laws

- **universe** — a running simulation: a seed, a tick counter, named
  RNG streams, an annals, and ordered lists of systems and factions.
  Defined entirely by `(code version, seed, intervention log)`.
- **seed** — the integer that names a universe. Same seed, same
  universe, bit for bit, forever. (post 0001)
- **tick** — the integer quantum of sim-time, and the only clock the
  sim has. Wall clocks are banned from simulation code. (post 0001)
- **the four laws** — the non-negotiable architecture: determinism
  (1), everything is an event (2), agents act on beliefs, never
  truth (3), the core is headless (4). Stated in full in
  [CLAUDE.md](../CLAUDE.md).
- **named stream** — a subsystem's private source of randomness,
  derived from `(seed, name)` alone, so a new feature never shifts
  another subsystem's draws. (post 0001)
- **canon** — a universe's untouched timeline: what happens when no
  god intervenes. (The word is reserved for this meaning; the module
  once called `canon.lua` was renamed `byteform.lua` to keep it so.)
- **apocrypha** — branches forked from canon by divine intervention.
  Interventions are recorded inputs, applied at tick boundaries.
  (card 121, future)

## The log and its readers

- **event** — the only thing that can happen. Nothing changes in a
  Sonder universe except by appending one. (post 0002)
- **envelope** — the fields every event of every era carries: id,
  tick, kind, location, magnitude, visibility, payload, causes.
  (post 0002)
- **kind** — an event's registered type (`market.drift`,
  `war.muster`), declared in the event vocabulary. (post 0002)
- **event vocabulary** — the versioned, declared list of every kind
  and the exact shape of its payload; a public API. "Vocabulary"
  unqualified usually means this. (post 0002)
- **visibility** — who could, in principle, come to know of an
  event: `public`, `regional`, or `secret`. Stamped honestly since
  day one; consumed for real when news stops being instant.
  (post 0002; card 122, future)
- **causes** — the ids of the events that caused this one. Required:
  markets don't just move, wars don't just start. Only genesis is
  uncaused. (post 0002)
- **genesis** — event 1 of every universe, tick 0, the seed on
  record; the event every cause chain terminates in. (post 0002)
- **annals** — the append-only event log; the source of truth every
  reader reads, and the SQLite table it becomes on disk.
  (posts 0002, 0004)
- **projection** — a pure function from a prefix of the annals to a
  view. All state, statistics, and displays are projections; the
  chronicle, the archive, the seal, and every belief store are the
  four we've built. (post 0002)
- **chronicle** — the readable feed: a viewer that renders the
  annals into sentences, tolerant of kinds it doesn't know because
  readers age and writes are forever. (post 0002)
- **viewer** — anything that reads the log without the power to
  write it. The sim runs identically whether zero or a thousand are
  attached (law 4). (post 0002)

## Agents and knowledge

- **system** — ambient physics: code that runs every tick with the
  universe in its hands and emits directly. A system is the world,
  not somebody in it — it has no perspective and cannot be wrong.
  (posts 0001, 0006)
- **faction** — somebody: an agent whose decision code is handed
  `(beliefs, stream, tick)` and nothing else, and acts by returning
  intents. The test: could this actor ever be *wrong* about
  something? Then it's a faction. (post 0006)
- **belief store** — what one faction knows, which is not the truth:
  a push-based memory of the events that have reached it. Ignorance
  is free — no events received, no rows. (post 0006)
- **courier** — the machinery that delivers events into belief
  stores. Today a pass-through (everyone briefly omniscient); the
  seam where news will learn to travel at ship speed, degrade, and
  be culturally interpreted. (post 0006; card 122, future)
- **intent** — an event spec a faction's decide() returns; the
  universe emits it through the same strict validation as
  everything else. Factions don't write history, they petition it.
  (post 0006)

## The universe file

- **universe file** (`universe.db`) — the SQLite database a run
  writes: the annals as rows, causes as a walkable graph,
  provenance, checkpoints. The save file is a database; the database
  is a history book. (post 0004)
- **archive** — the follower that writes the universe file: a cursor
  over the annals, one transaction per tick, never a live reference.
  (post 0004)
- **provenance** — the table of origins every universe file carries
  from birth: engine version, git commit, seed, config, schema
  version, intervention log. A log found on a beach can testify
  about where it came from. (post 0004)
- **byteform** (`byteform.lua`) — the one byte representation every
  event has: envelope fields in fixed order, payload fields in
  declaration order, total escaping. The archive stores these bytes;
  the seal hashes them. Formerly `canon.lua`; renamed so *canon*
  could mean exactly one thing (post 0005's prose keeps the old name
  forever at its tag). (posts 0004, 0005)
- **checkpoint** — a `(tick, events, hash)` row: the rolling seal as
  it stood when that tick completed, written every N ticks and at
  close. The substrate for finding where two universes first
  diverged. (post 0005)

## Verification

- **seal** — the rolling state hash: FNV-1a 64 folded over each
  event's canonical bytes. Two universes with the same seal lived
  the same history. Answers "same universe?" (post 0005)
- **fingerprint** — the hash of the *rendered feed* — the view, not
  the state. Rewording a chronicle template changes the fingerprint
  and not the seal. Answers "same feed?" (posts 0001, 0005)
- **golden master** — a spec pinning exact output (the seal of seed
  1893 × 500 ticks) so any accidental change to history fails the
  build. (post 0005)
- **re-cut ledger** — the comment block in `seal_spec.lua` recording
  every golden constant this project has pinned, and why each one
  moved. Constants are re-cut deliberately, loudly, never casually.
  (posts 0005, 0006)
- **gremlin** — the saboteur in the perturbation spec: one extra
  draw stolen from another actor's stream, proving one stolen random
  number forks a universe. (post 0005)
- **audit** — the independent fold in `toyworld_spec`: the whole
  annals reduced to per-civ books that every self-reported tally
  must match, cent for cent. Card 120's double-entry audit in
  miniature. (post 0007)
- **doctor** — `tools/doctor.lua`: verifies the properties
  determinism leans on (integer subtype, wrapping overflow, pinned
  toolchain) rather than just that programs exist.

## Worlds and their people

- **world** — content the engine hosts: temperaments compiled to
  constants and decide functions, living in `src/worlds/` (the
  engine/content line is a directory boundary). The lore shelf is
  the *expressibility* eval (authored story leads; the engine must
  host it); a world is the *emergence* eval (temperaments lead;
  history must precipitate). (post 0007)
- **the toy world** (`src/worlds/toy.lua`) — the first world: two
  civilizations, one commodity, one market, wars nobody plans. Also
  the shared spec fixture, via `tests/support/toy.lua`. (post 0007)
- **the Vessari** — the toy world's mercantile half: they price
  things — surplus sellers with a reserve, an undercut, and a floor
  below which they simply wait. (post 0007; lore:
  `the-vessari.md`)
- **the Khedrun** — the toy world's martial half: they cost them
  out — structural grain deficit, two patience fuses (price and
  hunger), and raiding as provisioning; plunder is how money flows
  back. (post 0007; lore: `the-khedrun.md`)

## The project's own artifacts

- **post** — the essay every increment ships with: excerpt → design
  → the CS underneath → what we got wrong. Pinned to a `post/NNNN`
  git tag at the exact code it describes.
- **notebook** — a branch's working log in `docs/notebooks/`:
  decisions, rejected alternatives, questions and the answers that
  stuck. The post's raw material; merges with the PR.
- **history** — narrative writing built on top of universes: posts,
  generated stories. (Distinct from the annals, which is the record
  itself.)
- **synopsis** — the future cross-version divergence report:
  forensic mode binary-searches checkpoints for the first fork;
  climate mode compares distributions across many seeds. (card 123)
- **seed report** — a community field report: "go look at seed N,"
  plus what you saw.
- **lore** — the authored stories and priors in `docs/lore/`; an
  eval suite the systems must be able to host — a floor, never a
  ceiling. (post 0003)
