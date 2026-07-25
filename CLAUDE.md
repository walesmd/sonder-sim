# CLAUDE.md — Sonder

Sonder is a universe simulator you read: many simulated civilizations with
distinct proclivities trading, scheming, allying, and warring across a
procedurally grown galaxy, observed by a player who is something between a
god and a subscriber. It is an educational project first — every mechanic
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
   visibility, payload, and cause links (ids of the events that caused it).
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

## Working agreement

- Every increment ships twice: working code AND a post in `docs/posts/`.
  Post shape, in order: chronicle excerpt showing the new behavior in the
  wild → the design → the CS underneath → what we got wrong.
- Each published post pins a git tag `post/NNNN` at the exact code it
  describes. Posts live in the repo, next to the code they explain.
- A post is not done until Mike can explain, unaided: every concept in it,
  the decision-making that led to it, the pros and cons of what we chose,
  and what the code does — line by line if need be. Mike does not go along
  with what Claude provides; nothing merges that Mike can't defend without
  Claude in the room.
- Feature work follows a fixed rhythm, one branch per card: branch → build
  shared understanding of the card → implement → Mike interrogates the
  code until he owns it → write the post together → pull request.
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

| term | meaning |
|---|---|
| annals | the append-only event log (also the SQLite table name) |
| chronicle | a rendered, readable feed projected from the annals |
| history | narrative writing built on top (posts, generated stories) |
| canon | a universe's untouched timeline |
| apocrypha | intervention branches forked from canon |
| synopsis | cross-version divergence report: forensic mode finds the first fork (binary search over checkpoint hashes); climate mode compares distributions across many seeds |
| seed report | a community field report: "go look at seed N" plus what you saw |
| notebook | per-branch working log of what we learned building a feature; the post's raw material |

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

**Pre-0.1. Nothing runs yet.** Next up — Session 1, the walking skeleton:

- deterministic tick loop + named RNG streams
- event bus with a terminal chronicle
- SQLite annals + provenance table
- toy world: two civilizations with opposed proclivities (mercantile vs
  martial), one commodity, one market with naive price adjustment
- visibility fields on events; pass-through belief store
- first posts: 0001 *Ticks & Determinism*, 0002 *The Event Log*,
  0003 *Truth & Belief (the seam)*

A draft of post 0000 (*First Tick*) is in `docs/posts/` — written before
any code existed; its chronicle excerpt and install steps are aspirational
until v0.1 ships.

## Project management

`.fizzy.yaml` holds access details for the Fizzy board (Mike maintains it). 
Check the board at session
start for current tasks; capture new ideas from working sessions as cards.
