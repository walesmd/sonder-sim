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
  tick, kind, location, magnitude, loudness, payload, causes.
  (post 0002)
- **kind** — an event's registered type (`market.drift`,
  `war.muster`), declared in the event vocabulary. (post 0002)
- **event vocabulary** — the versioned, declared list of every kind
  and the exact shape of its payload; a public API. "Vocabulary"
  unqualified usually means this. (post 0002)
- **loudness** — how loudly an act was performed: `loud`, `local`,
  or `quiet`. The signal an event emitted at its origin, chosen by
  the emitter as part of acting — never who may come to know, which
  is the behavior of whoever holds the information (retellings,
  silence), not event state. Stamped honestly since day one; named
  `visibility` until card 122 caught the word claiming too much.
  (post 0002; post 0011)
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
  stores, on the mechanism rows the world declares (the carriage,
  card 150): arrival is the earliest reaching row's answer, each
  believed copy stamped with the tick it landed — and when no row
  reaches a faction, the event is never delivered (the witness
  rule). Since card 151 the courier also rolls the roads' dice, on
  its own reserved stream: rows with an encounter profile can lose
  what they carry. Interpretation will arrive through the same
  door. (posts 0006, 0011, 0015, 0016)
- **channel speed** — the divisor that turned distance into delay
  in the field era. Since card 150, each mechanism row carries its
  own speed; this parameter survives as the *default field row's*
  speed and as a legacy field the roads and audit still read (a
  card-166 review finding). (posts 0011, 0015)
- **learned** — the arrival stamp on a believed copy: the tick the
  news actually reached its owner. The event is a photograph; this
  is the date written on the back. The left-hand date on every
  believes-feed line. (post 0011)
- **private chronology** — the order news reached one faction: its
  belief store's diary, rendered double-dated by `--believes`
  (learned ← happened). Same templates as the chronicle — what
  differs is never the words, only the dates and the order.
  (post 0011)
- **shipment** — matter or money between places: a departure event
  (the actor's act, at the origin) paired with an arrival event
  (physics' verdict, at the destination) by cause id. Its identity
  is the departure event; its position is a projection; its
  arrival is never a promise. Transfers are net zero — grain
  leaving A arrives at B — where news only ever copies. (post 0012)
- **world** — a module that builds a universe from a seed, supplying
  everything the engine refuses to contain: a vocabulary, a cast,
  systems, a map, mechanisms, sentences, audit legs and conservation
  identities, and its own golden seal (ADR 0004, amended card 150).
  The engine demands exactly one thing of every world:
  universe.genesis, because the engine emits it. Three exist: space
  (the destination), the continent and the office (evals). Worlds
  are content — the engine/content line is a directory boundary —
  and each is an *emergence* eval (temperaments lead; history must
  precipitate) where the lore shelf is the *expressibility* eval.
  (posts 0007, 0013)
- **the litmus** — card 160's standing law: what we build must serve
  all three universes; if it cannot, it is world content, and if it
  can — like the random number generator — it is a framework-level
  addition. (post 0013)
- **road ledger** — the audit's account for what is between places:
  every departure books onto it under its own event id, every
  arrival drains it exactly, and the conservation identities read
  founded = held + on-road, to the sack and the cent. Real
  accounting calls it goods in transit. Punctuality is never
  audited — only conservation. (post 0012)
- **travel calendar** — the shared scheduler (one per owner:
  courier, battlefield, exchange, roads) that holds every traveling
  thing until its arrival tick. Cargo-blind: what an arrival means
  belongs to the owner. (post 0012)
- **intent** — an event spec a faction's decide() returns; the
  universe emits it through the same strict validation as
  everything else. Factions don't write history, they petition it.
  (post 0006)

## Carriage (designed at post 0014; landing since card 150)

- **mechanism** — one way of moving anything across distance: a row
  in the carrier taxonomy — speed, coverage (which destinations,
  named how, available *when*), a failure profile with a declared
  threat surface, cost, and owner. Rows are state (events can change
  every cell; mechanisms are born, improve, and die), mechanisms are
  data never code, and no fallback row covers the world. In the
  engine since card 150: `sonder/carriage.lua`, consuming speed and
  coverage; the remaining columns arrive with their owning cards.
  (posts 0014, 0015)
- **net-zero / copyable** — the two payload disciplines, and the
  only split the taxonomy makes: conserved cargo (grain that leaves
  the granary is gone from it; the road ledger watches) versus
  reproducible cargo (telling costs the teller nothing; belief
  semantics watch). One taxonomy carries both. (post 0014)
- **addressed / radiated** — the two delivery shapes: to a name the
  world's map can price (and an address can sail), or into a
  neighborhood of the map, whatever that map means by nearness.
  Relay is deliberately not a shape — a rumor is one *plus*
  shipments. (post 0014)
- **retelling** — a fresh emission composed from the teller's
  beliefs and agenda, cause-linked to the news that prompted it; how
  information travels beyond its witnesses without freight.
  (post 0014)
- **the witness rule** — an event's news exists only in the minds
  that caught it: natural media are how witnesses witness,
  everything after the catch is somebody carrying, and no witness
  means no news, forever. Law 2 untouched — the annals still records
  every tree that falls. (post 0014)
- **encounter profile** — what a mechanism's travelers meet on the
  way: one chance-in-N drawn per day of exposure on `rng.courier`,
  so longer roads are riskier purely by being longer. Today's sole
  outcome is loss — the letter that never arrives, recorded on its
  true day, reason-free (the universe does not fake knowledge it
  lacks; causes await the encounter engine, card 165), witnessed by
  no one. The generalization of ADR 0005's failure-profile column,
  renamed by Mike's ruling: encounters are not all bad. (post 0016)
- **custody** — whose hands a payload sits in while carried; what
  the road ledger's on-road column names when the carrier is
  somebody. (post 0014)
- **manifest** — what a carrier knows it hauls: total knowledge for
  net-zero cargo, but for copyable cargo the manifest stops at the
  envelope — reading the contents is a behavior, never a schema
  default. (post 0014)
- **the field row** — the licensed placeholder, named at last:
  the old courier re-read as a natural medium with infinite range,
  no owner, no failure, no cost. Doctrinally retired by the witness
  rule; each world retires it in code on its own schedule — since
  card 150 it is data the world declares (`Carriage.field`), still
  standing in space and the office, retired on Harrow for earshot
  and letters. (posts 0011, 0014, 0015)

## The universe file

- **universe file** (`universe.db`) — the SQLite database a run
  writes: the annals as rows, causes as a walkable graph,
  provenance, checkpoints. The save file is a database; the database
  is a history book. (post 0004)
- **archive** — the follower that writes the universe file: a cursor
  over the annals, one transaction per tick, never a live reference.
  (post 0004)
- **provenance** — the table of origins every universe file carries
  from birth — nine rows: engine version, git commit, seed, config,
  which world wrote it (card 167), that world's vocabulary version,
  the intervention log, plus the Lua and SQLite versions doing the
  writing. A log found on a beach can testify about where it came
  from. Full reference: [`universe-file.md`](universe-file.md).
  (posts 0004, 0018)
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
- **re-cut ledger** — the comment block beside each world's golden
  constant recording every value it has ever held, and why each one
  moved: space's in `seal_spec.lua`, the continent's in
  `continent_spec.lua` (holding the first deliberate re-cut, card
  151), the office's in `office_spec.lua`. Constants are re-cut
  deliberately, loudly, never casually — and since card 150, never
  without a minor version bump. (posts 0005, 0006, 0016)
- **determinism epoch** — what the engine's minor version names
  (card 150's convention): the version tracks the universe, not the
  code. Minor bumps when a golden seal moves; patch bumps when the
  engine changes but every seal stands; docs, worlds, and specs
  bump nothing. Precise identification is always the git commit in
  provenance. (posts 0015, 0016)
- **gremlin** — the saboteur in the perturbation spec: one extra
  draw stolen from another actor's stream, proving one stolen random
  number forks a universe. (post 0005)
- **audit** — the double-entry projection (`src/sonder/audit.lua`):
  the whole annals refolded into per-civ books, checked against two
  conservation laws — money has no doors; matter has two, both
  recorded. Violations (impossible arithmetic) are zero forever.
  Mismatches (self-reports drifting from the fold) were legitimized
  by card 122 — explained by news still on the road — then died
  honestly at card 153, when every book-moving event moved to its
  owner's gates: zero, earned. Card 151 confirmed loss doesn't
  revive them (a lost letter changes behavior, never books). Born
  as a spec-local fold in post 0007. (posts 0007, 0010, 0011, 0012,
  0016)
- **doctor** — `tools/doctor.lua`: verifies the properties
  determinism leans on (integer subtype, wrapping overflow, pinned
  toolchain) rather than just that programs exist.

## Worlds and their people

- **the space world** (`src/worlds/space.lua`) — the first world,
  born as "the toy world" and renamed at card 160 to its real name,
  the destination: two civilizations, one commodity, one market,
  wars nobody plans. Also the shared spec fixture, via
  `tests/support/space.lua`. (posts 0007, 0013)
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
  git tag at the exact code it describes. Since card 147 a post is a
  directory with two tracks: **complete** (the canonical collegiate
  essay) and **simple** (a plain-language companion — same facts,
  fewer of them). (ADR 0003)
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
- **eval note** — the closing section every shelf entry carries:
  what the entry exists to prove, and what would fail it — an
  expressibility claim for story-first entries, an emergence claim
  for engine-first ones. Two to four sentences, one falsifiable
  minimum, never a feature list. (posts 0007, 0009)
