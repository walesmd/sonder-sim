# CLAUDE.md — Sonder

Sonder is a universe simulator you read: many simulated civilizations with
distinct proclivities trading, scheming, allying, and warring across a
procedurally grown galaxy, observed by a player who is something between a
god and a subscriber. We are not building a game: we are building a system
of systems, and games and observability are the outcomes (card 160). The
universal space sim is the destination; two deliberately shallow eval
universes — a fantasy continent and an office — stand guard on the way,
and anything we build must serve all three or be filed as one world's
content. It is an educational project first — every mechanic
ships with a written lesson — and a decades-horizon labor of love with no
1.0, no roadmap, and no destination. A CS concept is introduced only when
the work in front of us requires it; nothing gets taught in the abstract.
We are doing this for the sake of learning and sharing. We are never in a
rush.

The name is John Koenig's coined word (*The Dictionary of Obscure
Sorrows*): the realization that each random passerby is living a life as
vivid and complex as your own. That is also the thesis of the simulation —
even the small civilization on the rim, which has never heard of the
warring empires, has a complete inner history.

Built in long conversations between Mike (human: decides, edits, owns the
consequences) and Claude (AI: drafts much of the code and prose). Mistakes
are jointly owned and published.

## The four laws (non-negotiable architecture)

1. **Determinism.** A `(code version, seed, intervention log)` triple
   defines exactly one universe, bit-for-bit, on every machine.
   - No wall-clock reads inside the sim. Never `os.time`/`os.clock`/`os.date`
     in simulation code.
   - Named RNG streams per subsystem (`rng.market`, `rng.war`, ...) so a new
     feature never shifts another subsystem's draws.
   - Never iterate a hash table where order can affect outcomes — `pairs()`
     order is unspecified. Use arrays, or sort keys first.
   - Outcome-affecting quantities are Lua 5.4 integers (money in cents;
     matter in discrete units). Never accumulate floats into outcomes.
2. **Everything is an event.** Nothing "happens" except an append to the
   annals (the event log). All state views, chronicles, and statistics are
   projections of it. Every event carries: tick, kind, location, magnitude,
   loudness, payload, and cause links (ids of the events that caused it).
3. **Agents act on beliefs, never truth.** Faction decision code reads only
   that faction's belief store — structurally, not politely: no reaching
   into world state. (v0.1 ships a pass-through belief store; the seam
   exists so news can later travel at ship speed, degrade in transit, and
   be culturally interpreted. Ignorance is free: a civ that has received no
   events about something simply has no rows about it.)
4. **The core is headless.** The sim never knows whether anyone is
   watching. UIs subscribe to it. Divine interventions are inputs: recorded
   in sim-time, applied at tick boundaries, appended to the log like any
   other event. Canon (untouched timeline) stays forever computable;
   interventions fork apocrypha branches.

## Day-one requirements (cheap now, brutal to retrofit)

- Every universe DB carries a provenance table: engine version, git commit,
  seed, config, schema version, intervention log.
- The event vocabulary is a public API: versioned schema, documented
  migrations, append-mostly kinds. Cross-version comparability is what the
  synopsis tool depends on.
- Rolling state hash checkpointed every N ticks (serves golden-master
  tests, first-divergence binary search, and integrity checks).
- Reproducible toolchain: Lua 5.4 pinned, dependencies locked.

## The living reference (read before re-deriving anything)

`docs/README.md` maps all documentation. Five pages are **living**
— they describe the system as it stands, and staleness in them is
a bug: `docs/architecture.md` (modules, the tick, the life of an
event — start here before touching the engine), `docs/api.md` (the
public surface and every contract a world or viewer relies on),
`docs/universe-file.md` (the database a run writes),
`docs/verification.md` (the seals and how to check one), and
`docs/glossary.md` (canonical vocabulary). Posts and notebooks are
**pinned era artifacts** — never retro-corrected; trust them about
then, not about now. Any card that changes what a living page
describes updates that page in the same PR (it's a docs-sweep
item). Built at card 166, post 0017.

## Working agreement

- Every increment ships twice: the work AND a post in `docs/posts/`.
  The work is usually code, but not always — architecture, system
  rules, and lore are engineering too (post 0003 shipped zero lines of
  code and some of the project's most consequential decisions); the
  post obligation stands either way. Post shape, in order: excerpt
  showing the new thing in the wild (a chronicle excerpt when there's
  code; the artifact itself when there isn't) → why now (why this
  card, in this moment — what debt or door opened, what's queued
  behind it; added at post 0014 after twelve posts shipped without
  it) → the design → the CS underneath → what we got wrong.
- A post is a directory with two public tracks (ADR 0003, card 147):
  `docs/posts/NNNN-slug/complete.md` — the canonical collegiate essay —
  and `simple.md` — a plain-language companion, ~950 words, at most one
  excerpt, mistakes kept. Same facts, numbers, seeds, and hashes in
  both; simple simplifies by omission and analogy, never distortion.
  When a post explains a CS algorithm or mathematical argument, ask
  explicitly: *does this need a visual?* Diagrams are Mermaid, inline
  in the post source — the source is canonical, a rendering is a
  projection. Posts that lean on earlier posts open with a one-line
  *Previously* note; second-order arguments go in labeled asides.
- Each published post pins a git tag `post/NNNN` at the exact code it
  describes. Posts live in the repo, next to the code they explain.
- A post is not done until Mike can explain, unaided: every concept in it,
  the decision-making that led to it, the pros and cons of what we chose,
  and what the code does — line by line if need be. Mike does not go along
  with what Claude provides; nothing merges that Mike can't defend without
  Claude in the room.
- Feature work follows a fixed rhythm, one branch per card: branch → build
  shared understanding of the card → implement → Mike interrogates the
  code until he owns it → write the post together → docs sweep → pull
  request.
- The docs sweep, before every pull request: update the README (status,
  install steps), add any newly coined reader-facing terms to
  `docs/glossary.md`, confirm the post's `simple.md` exists and agrees
  with `complete.md` (and carries a diagram when `complete.md` does,
  or records why not — the simple track lost its visuals for ten
  posts before card 166 noticed), confirm the does-this-need-a-visual
  question was asked, update the living reference pages the change
  touches (`docs/architecture.md`, `docs/api.md`,
  `docs/universe-file.md`, `docs/verification.md`, `docs/README.md` —
  staleness there is a bug, unlike posts, which are era artifacts),
  add the new post to `docs/posts/README.md`'s index, and fix any
  other documentation the change makes stale, in the same PR. Post tags are immutable once pushed, so
  documentation that misses the PR stays wrong at that tag forever
  (learned the hard way after card 113).
- Branch names always start with the Fizzy card number, then a short
  summary of the card: card 112 → `112-toolchain`. The branch's notebook
  uses the same name: `docs/notebooks/112-toolchain.md`.
- Every feature branch keeps a notebook in `docs/notebooks/` (one file per
  branch, named after it): decisions made, alternatives rejected, questions
  Mike asked and the answers that stuck. Claude reads it at the start of
  every session on that branch and appends as the work happens; the post is
  distilled from it, and it merges with the PR so the raw back-and-forth
  stays part of the record.
- Architecture decisions get a short record in `docs/adr/`.
- Schemas harden from the edges inward: events and persistence are strict
  from day one; interior entity tables start loose and tighten when the
  first shape-drift bug earns the lesson (that bug becomes a post, not a
  cover-up).
- Verification we owe the universe: golden-master replay tests (same seed,
  N years, same hash), and a double-entry audit once the economy exists —
  every credit leaving one treasury must arrive in another; total matter is
  conserved unless explicitly mined or burned.
- Long-lived universes cross engine versions as a lineage: run under vX to
  a snapshot, upgrade, continue under vX+1. Replays are exact per segment;
  the chronicle records the day the constants shifted.
- Mike decides; Claude drafts. When in doubt, do the slower, more
  teachable thing.

## Vocabulary (use it consistently, in code and prose)

The project's vocabulary — annals, chronicle, faction, courier, seal,
and the rest — lives in **`docs/glossary.md`**: one definition per
term, each pointing at the post that earned it. That file is
canonical; use its words consistently in code, posts, and
conversation, and never coin a synonym for a thing the glossary
already names. A card that introduces a term a reader would need
adds it to the glossary **in the same PR** (it's a docs-sweep item).

One entry keeps its long form elsewhere: lore is chartered in
`docs/lore/README.md` — an eval suite, not a PRD; every system must
be able to host the shelf's stories, and a mechanic that blocks one
has failed a test (exceptions: bad test, or consciously retired —
Mike's call, on the record).

Perspective hierarchy (zoom levels): universe → civilization → (later)
notable figures, crystallized from aggregates on demand.

## Tech

- Lua 5.4, deliberately not 5.5 (the integer subtype is load-bearing for
  determinism; the staying-put decision is `docs/adr/0001`).
- lsqlite3 for the annals; busted for tests when tests arrive; LuaRocks
  for dependencies.
- License: MIT (code), CC BY 4.0 (posts and docs).
- Voice for posts and docs: warm, precise, a little wry. Story before
  theory. Concrete numbers over adjectives. Admit mistakes plainly. No
  hype, no filler, no "in this post we will".

## Status

**v0.1 — session 1's walking skeleton — is cut.** Done:
deterministic tick loop + named RNG streams (card 113, post 0001
*Ticks & Determinism*); event bus + event vocabulary v1 + terminal
chronicle, visibility stamped on every event (card 114, post 0002
*The Event Log*); the lore shelf — world-building chartered as an
eval suite, a floor not a ceiling (card 129, post 0003 *The Lore
Shelf*); SQLite annals + provenance table — every run archives to a
universe file that is append-only by trigger and self-describing
(card 115, post 0004 *The History Book*); rolling state hash +
golden-master replay — the seal, checkpointed into every universe
file, with the gremlin spec proving one stolen draw forks history
(card 116, post 0005 *The Tamper Seal*); pass-through belief store —
law 3 as capabilities, decide(beliefs, stream, tick) returning
intents, the courier as the card-122 seam, the war office as first
believer (card 117, post 0006 *Truth & Belief*); the toy world —
the Vessari and the Khedrun in src/worlds/ (content, not engine),
stateless minds projected from beliefs, money circulating through
trade one way and plunder the other, and twenty unplanned wars per
thousand days (card 118, post 0007 *A War Nobody Planned*);
two-track posts — every post now ships as `complete.md` + `simple.md`
with Mermaid visuals as a standing question, earned by the
reading-level experiment in `docs/experiments/reading-levels/`
(card 147, ADR 0003, post 0008 *Simple & Complete*); eval notes on
every shelf entry — the three story-first civilizations backfilled,
the world library's collective note, the practice chartered as
flexibility principle 7 (card 148, post 0009 *What Failure Looks
Like*); and the v0.1 cut itself — engine version 0.1.0, post 0000
(*First Tick*) re-cut from aspiration to fact with the real day-86
war as its front-door excerpt (card 119, tag `post/0000`); the double-entry audit — audit.lua as a
projection, money with no doors, matter with two recorded ones,
violations kept structurally apart from the belief-drift mismatches
card 122 will legitimize, and a counterfeiter spec proving the annals
checks grammar while the audit checks arithmetic (card 120, post 0010
*Double Entry*); and news at ship speed — the toy world gained a map
(distance as content behind `distance(from, to, tick)`, the unused
tick the moving-map door), the courier delivers every event
ceil(distance ÷ channel speed) ticks late and stamps each believed
copy with the tick it was `learned`, visibility became loudness
(vocabulary v3 — who may know is behavior, never event state),
armies take the road (`war.march` departs, `war.raid` arrives, no
recall — a war ended before its last battle on the first try), the
exchange hears orders at arrival day, the audit certifies drift with
the road (reported + in-flight = audited to the cent; explained
mismatches are the product, unexplained are lies, violations stay
zero), and `--believes NAME [--as-of T]` renders any faction's
private chronology double-dated — three fingerprints, one seal
(card 122, post 0011 *News at Ship Speed*); nothing teleports —
the travel scheduler extracted (sonder/travel.lua, one calendar per
owner, adopted by the courier with a bit-identical seal proof),
goods and payment riding the roads as paired departure/arrival
kinds (cargo.*, payment.*, war.returned; the trade is just the
agreement now), the audit keeping a road ledger with conservation
reading founded = held + on-road, and the drift card 122
legitimized dying honestly — every book-moving event happens at its
owner's gates, so self-knowledge is exact and mismatches are zero,
earned (card 153, post 0012 *Nothing Teleports*); and the engine
became a framework in fact — the toy world renamed to space (its
real name: the destination), the world interface written down (ADR
0004: a world supplies its vocabulary, cast, systems, map,
sentences, audit legs and identities, and its own golden seal; the
engine demands only universe.genesis), four leaks extracted with
the space seal as regression anchor (vocabulary, audit legs,
chronicle templates, and the roads system — rule of three, cashed),
and two eval universes built against their charters: Bellwether &
Co. (ten person-tier minds, the org chart as the map, an open
economy, the rumor cascade firing unprompted) and Harrow (five
civilizations, adjacency-graph interior, four-column books, no
exchange — bilateral trade as four journeys with single-fire
settlement: act the morning you learn). Three worlds, three golden
seals, 162 specs, one engine that got smaller with every world it
gained (card 160, post 0013 *Whatever That Universe May Be*); and
the carrier taxonomy, designed on paper for all three worlds at
once — movement as a system (five columns: speed, coverage, failure
profile with a declared threat surface, cost, owner), net-zero
versus copyable payloads, addressed and radiated as the only
delivery shapes with rumor demoted to behavior (one plus
shipments), the witness rule (an event's news exists only in the
minds that caught it; the annals still hears every tree), carriage
as trade with custody and manifests, per-world migration off the
field row, and a build map assigning cards 150–159 their pieces —
zero code, on purpose (card 161, ADR 0005, post 0014 *The Witness
Rule*); and the carriage — mechanism rows in the engine
(sonder/carriage.lua: radiated and addressed shapes, strict
validation, earliest arrival wins, nil is the witness rule), the
field row declared as data in space and the office (rung 1), and
Harrow piloting rung 2 with earshot and letters — where the golden
seal famously did not move, because no Harrow mind ever read the
field's over-delivery: history stood still while belief stores
shrank to what was witnessed or carried (card 150, post 0015 *The
Seal That Didn't Move*); and the roads are not safe — Harrow's
letters carry an encounter profile (one chance per fifty
rider-days on the courier's own reserved stream, exposure not
fate), losses land on their true day at the-roads, reason-free
(the universe does not fake knowledge it lacks — causes await the
encounter engine, card 165) and witnessed by no one, the
half-settled trade (paid, never shipped) lives as chartered
settlement risk, the warned-of audit relaxation did not bite
(loss changes behavior, never book accuracy), and the golden
continent seal re-cut deliberately for the first time — engine
0.2.0, the version convention's first minor bump (card 151, post
0016 *The Roads Are Not Safe*); and the beat — a comprehensive
two-hat review (thirty findings, ranked in notebook 166, none
applied: identify first, Mike decides), plus the living reference
shelf built beside the pinned posts (docs/architecture.md,
docs/universe-file.md, docs/api.md, docs/verification.md,
docs/README.md — staleness there is a bug, and the docs sweep now
names them) (card 166, post 0017 *Success Debt*); and the world row —
provenance grew to nine rows, ADR 0004's oldest unpaid requirement
paid, a world's version ruled to be its vocabulary's version,
engine 0.2.1 (card 167, post 0018 *The File That Knows Its Name*).
Next up:

- the card-166 findings menu (cards 168–172): the courier
  extraction (before 152 cuts through the heartbeat), the
  believed-books cluster (the big one), road-day arithmetic and
  channel_speed's retirement, the vocabulary module, and the
  hygiene sweep

- the courier's remaining successors, cards 152–159, each with its
  piece of the carrier taxonomy assigned by ADR 0005's build map —
  interpretation, exchanges in the plural, counterfeiting as
  content, reception-side loudness plus the stamp re-judgment
  punted there, in-flight actors, and money grown up; the
  encounter engine research card (165) that gives losses their
  reasons; the space world's own rung-2 migration awaits a card
  that must answer for the Fleet (163) and teach the audit's
  in-flight explainer the carriage
- the road to thirty species, one lore card at a time (cards 133–146,
  each entry arriving with its eval note)

## Project management

`.fizzy.yaml` holds access details for the Fizzy board (Mike maintains it). 
Check the board at session
start for current tasks; capture new ideas from working sessions as cards.
