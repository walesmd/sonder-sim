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
