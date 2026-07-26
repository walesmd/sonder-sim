# Notebook — 129-world-building

Card 129: *World-building: lore, cosmology, and historical priors
(docs, not code).* The first prose-only increment: documents that
future mechanics inherit instead of improvising flavor.

## Session 1 (2026-07-25, late) — the bedtime exchange

Three seed questions went to Mike; three answers came back:

- **How alien is alien?** Star Trek / Star Wars / Battlestar wide —
  humanoids, energy beings, AI creations that became races, anything
  dreamable. Standing deliverable: fantasize and schema out **at
  least 30 species** for the first real version.
- **Authored past?** Deferred, deliberately. Mike: "I'll get a bit
  more of a sense of pre-Genesis once I start to understand Genesis."
  Revisit when card 118 gives genesis content.
- **Whose voice is the chronicle?** Terminology clarified instead:
  *the annals is what happened; a chronicle is a window; history is
  an author.* The annals is the objective event database (sim-side,
  omniscient, SQLite after 115); a chronicle is a user-side viewer;
  perspective-bearing in-universe historians are downstream ("that's
  downstream bro" — preserved for the record).

Three species sketches offered as range-finders; Mike approved all
three as the starting cast: the Vess, the Continuance, the Marrow
Fleet.

## Session 2 (2026-07-26) — the deep profiles

Mike's brief: document the three, then think deeply — homeworld; the
organisms→civilization transition; economy; technology and societal
stage; religion; aggression; known civilization-threatening events.
Not to implement — to *consider the infrastructure* that would
account for such questions. Overriding constraint, his words: we are
modeling an entire universe together; be iterative and flexible;
don't design ourselves into a corner.

### What we built

- `docs/lore/README.md` — the shelf's charter and six flexibility
  principles: species are data, not code; axes are append-mostly;
  qualitative until a mechanic needs a number; everything reduces to
  three primitives (attributes, events, beliefs); authored archetypes
  vs emergent instances stays open; write the gaps down.
- `docs/lore/axes.md` — Mike's seven questions, each with an
  infrastructure account (how it eventually becomes data), a
  cross-cast reference table, and the gaps list.
- `docs/lore/civilizations/` — the three deep profiles, one template:
  portrait → the seven questions → rhymes-and-hooks (infrastructure
  notes) → open questions kept deliberately open.

### Design choices worth remembering

- **The cast triangulates the origin axis on purpose**: Vess are
  many→one, Continuance is one→many, Fleet is many-and-mobile. Three
  corners of the same parameter space, so the eventual schema gets
  stress-tested from birth.
- **Each archetype embodies a piece of Sonder's own architecture**:
  the Vess's religion is a conservation law (card 120's audit as
  liturgy); the Continuance is the annals personified (never delete,
  verify twice, notary services; the Calibration is a golden-master
  parable); the Fleet is law 3 at galactic scale (news travels on
  their ships; their own census is aging belief). Lore that rhymes
  with the physics it must run on will survive implementation;
  lore that fights it won't.
- **All three are sublight.** The no-FTL constant is now written
  lore-side (`lore/README.md`), matching the news-at-ship-speed
  plan. Any future species assuming instant communication is wrong
  by construction.
- **Gaps recorded rather than filled**: everyone in the cast is
  ancient, non-martial, religious, coherent, and likable. The road
  to 30 fills those holes first — notably a genuinely martial
  archetype, which card 118's toy world will need drawn from a real
  profile rather than a strawman.

### Working-agreement question (for Mike at PR review)

Every increment normally ships code AND a post. This card ships
prose only. Proposal: the lore docs are the artifact; no post number
is consumed and no `post/NNNN` tag is cut (post tags pin code that
posts describe; there is no code here). If the world-building method
itself deserves a post someday ("how to invent aliens without
cornering your simulator"), it can be written when the 30-species
push happens and there's a fuller story to tell. Mike ratifies or
overrules at review.

## Session 3 (2026-07-26) — the world library

Mike: "I imagine we'll need a library of types of planets that could
either sustain or be utilized by civilizations?" — note the two roles
in the question itself: *sustain* and *be utilized*. That split
became the catalog's structure (cradles / footholds / quarries and
graves) and one of its infrastructure findings ("originate" and
"sustain" are different columns; Holdfasts prove it).

`docs/lore/worlds.md`: seven world axes (energy budget, habitability
envelope, signal medium, gravity/escape cost, endowment, hazard
profile, stability horizon), each with an infrastructure account,
then fifteen types. Decisions worth remembering:

- **Types are presets, not enums.** The generator (125) composes
  attributes; named types are recognizable clusters for lore and
  chronicle prose. Hybrids legal by construction (canonical example:
  a rogue with a live core is a reefworld with the lights off).
- **Habitability is a relation, not a column.** No `habitable`
  boolean, ever — it's a join between species needs and world
  attributes. A Garden is paradise to a surface-dweller and noisy
  dead rock with weather to the Vess.
- **Endowments are finite integer ledgers.** Mining moves matter
  from the world's account to somebody's hold — card 120's audit
  extended into geology for free. Depletion is a balance hitting
  zero, and it is history.
- **Hazard profile = distribution over future event kinds** — the
  world-side half of civilization question 7. Real hazards live on
  the world; awareness lives in belief stores; tragedy is the gap.
- **Artificial habitats deliberately excluded** — they're outputs of
  civilizations (built entities), not world types the galaxy deals
  out. The Fleet lives entirely in the excluded category, which is
  why the boundary matters.
- Cast homeworlds land in the catalog: the Instrument is a
  reefworld, Marrow a sleetworld, the Elyr homeworld a curated
  grave.
- Gaps recorded: shared biospheres, living worlds (world-as-
  civilization boundary case), and a wet-and-warm cradle skew to
  either ratify as cosmology or fix on the road to thirty.

## Session 4 (2026-07-26) — FTL is a technology, not a wall

Mike reversed session 2's "no-FTL constant," and the reasoning is
the same category insight as the habitats exclusion: FTL is an
*output of civilizations*, like a space station or a satellite — a
technological achievement some civilization might reach — not a rule
the universe enforces. His sketch: a civilization that truly
embraces the quantum might move information faster than light via
entanglement; and if a personality and its lived experiences are
just data, downloading that data into another body across the
universe *is* faster-than-light travel by any name that matters.
No lore about mechanisms yet, deliberately. His words for the
stance: "we just don't agree that it is the limitation of the
universe."

What changed: `lore/README.md`'s constant section became "The speed
of truth (a default, not a law)"; the Fleet's two universal-sublight
phrasings became "nothing has *yet* outrun a hull"; the Fleet gained
the threat it always deserved (**the Whisper** — news that outruns
hulls guts their margin, which was always in the truth, not the
cargo); the Continuance's "No FTL" became a 31,000-year open
research docket ("the Calibration taught them the difference
between *verified* and *true*").

What deliberately did not change: law 3 — however fast the channel,
what arrives is belief, aged and interpreted; beating lightspeed
beats latency, not epistemology. And card 122 is unaffected: it
models the *default* channel (ships).

**Infrastructure implication, the keeper:** information channel
speed must be a **parameter, not a constant** — per-channel,
eventually tech-gated per-civilization — everywhere the belief
machinery touches it. Card 122 should be built with channel speed
as data from day one; baking lightspeed into the propagation code
would be exactly the cheap-now-brutal-later retrofit CLAUDE.md
warns about. A civ with a faster channel then needs zero new
mechanics — just a bigger number on its channel row.

Caveat filed for honesty: real-world quantum mechanics (the
no-communication theorem) holds that entanglement alone carries no
information. Sonder's cosmology is not obliged to agree, and by
writing no mechanism we haven't yet had to decide. If a mechanism
ever becomes a mechanic, that decision becomes a post.

## Session 5 (2026-07-26) — the shelf is an eval suite

Mike, defining how lore is to be treated (and reversing this
notebook's own session-2 framing of "priors, not promises — the
mechanic wins"): this lore is **not definitive** of the worlds,
species, and civilizations of Sonder's universes. It isn't a PRD.
It's an **eval**: whatever systems we build must be able to support
these stories, and we never build something that would block one.
"These are almost the test cases for all of the systems we'll be
building."

The presumption therefore flips. Old: mechanic wins, lore revises.
New: a mechanic that can't host a story has **failed a test** and
gets redesigned. Two exception paths, both Mike's call, both on the
record: a story was a bad test (it assumed something the four laws
forbid — laws outrank the shelf), or a story is consciously retired
as not worth its cost. Stories never just erode.

Written into `lore/README.md` (new "eval suite, not a PRD" section)
and the CLAUDE.md vocabulary row. Someday, "the engine can host
every story on the shelf" may even be checkable in part — the lore
conformance cousin of card 128 — but that's a thought, not a card,
yet.

Clarified by Mike, same day, and now in the charter: **the shelf is
a floor, not a ceiling.** The systems we build shouldn't take only
these evals into account — there is absolutely a world where the
systems create use cases nobody considered. His words: "We're not
building systems to create these three civilizations. We're building
a system that could at least create these three civilizations, but
it could also create something way more advanced." Over-fitting the
evals is its own failure mode; a generator that can only produce the
current cast has missed the point, and a genuine surprise out of the
generator is a candidate for the next eval, not a violation. He also
noted the four laws themselves are open to change — through him,
loudly, never silently — if a story ever makes a strong enough case.

Also decided: this card merges now rather than staying open as a
standing branch — the shelf is useful, long-lived doc branches
collect conflicts, and evals sharpen fastest against real systems.
Ongoing lore work (the road to thirty, commodities, naming) moves to
a new standing card. Next up: back to technical cards (115).

## Session 6 (2026-07-26) — the post, and the principle behind it

Mike reversed the session-5 no-post proposal and asked for a draft:
this card *does* ship a post. His reasoning, now written into the
working agreement itself: we may have "technically" written no code,
but we touched a lot of code-adjacent things — architectural
decisions and work-process decisions that weren't easy and needed
documenting. "Not all engineering work is writing code. Sometimes
it's thinking about how you're going to write the code or how you're
going to build the systems. What are the rules around the systems
that you want to build?"

Drafted `docs/posts/0003-the-lore-shelf.md`: the Kept as the excerpt
(the artifact itself, since there's no chronicle to excerpt) → the
bedtime conversation, the seven questions, the cast, the eval-not-
PRD / floor-not-ceiling charter, the four schema commitments → CS
(acceptance tests before the system exists; properties vs examples;
Goodhart and benchmark overfitting; booleans/enums/constants as
one-way doors) → what we got wrong (the accidental law of physics;
the charter's framing sentences all being second drafts; the
gap-list catching our bias toward wise gentle elders).

Expanded at Mike's direction: the post now names the methodology
head-on — **eval-based development, not PRD-based development**. A
PRD defines what to include (the most a product needs to be; build
the list, then stop); an eval is an example tested against the
product (the least the engine is allowed to be, silent about where
it stops). They fail in opposite directions: a missed PRD item cuts
scope and ships; a missed eval means there is nothing to ship.

Docs sweep for the amended scope: CLAUDE.md working-agreement bullet
now says increments ship "the work AND a post" with the
prose-is-engineering-too clause; CLAUDE.md status and README status
gained card 129 / post 0003; README's bets gained lore-as-evals.

### Open threads for future lore sessions

- 27 more species, gap-list first.
- The archetype-vs-instance binding (with pre-genesis, when genesis
  has content).
- Naming conventions doc (worlds, polities, figures, commodities) —
  none of the three profiles needed one yet, but 30 will.
- The Vess/Fleet arbitrage dispute is a ready-made first
  inter-civilization storyline the moment two civs and a market
  exist (card 118 could do worse than mercantile-Fleet-ish vs
  Vess-ish-slow traders).
