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

- Every increment ships twice: the work AND a post in `docs/posts/`.
  The work is usually code, but not always — architecture, system
  rules, and lore are engineering too (post 0003 shipped zero lines of
  code and some of the project's most consequential decisions); the
  post obligation stands either way. Post shape, in order: excerpt
  showing the new thing in the wild (a chronicle excerpt when there's
  code; the artifact itself when there isn't) → the design → the CS
  underneath → what we got wrong.
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
  with `complete.md`, confirm the does-this-need-a-visual question was
  asked, and fix any other documentation the change makes stale, in the
  same PR. Post tags are immutable once pushed, so
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
war as its front-door excerpt (card 119, tag `post/0000`). Next up:

- news at ship speed — the courier learns distance, delay, and
  degradation, and one spec finally fails on schedule (card 122)
- the road to thirty species, one lore card at a time (cards 133–146,
  each entry arriving with its eval note)

## Project management

`.fizzy.yaml` holds access details for the Fizzy board (Mike maintains it). 
Check the board at session
start for current tasks; capture new ideas from working sessions as cards.
