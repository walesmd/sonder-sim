# Notebook — card 148: eval notes on every shelf entry

Branch: `148-eval-notes`. A lore card, worked by Claude on Mike's
explicit instruction ("go ahead and work card 148, while I focus on
meetings") — a departure from the board convention that lore cards
are Mike's to work remotely, on the record here.

## Where the card came from

Mike, reviewing card 118's lore files: the Vessari and Khedrun end
with an "Eval notes" section — should the other civilizations get
one, and should this become a standing practice as more kinds join
the shelf? Claude's assessment (previous session turn): yes to both.
The card-118 entries state a falsifiable assertion — "exists to prove
X; systems that cannot Y fail this entry" — while the card-129
story-first entries leave their pass/fail criteria implicit across
nineteen paragraphs of portrait. The difference between a pile of
examples and a test suite is that each test states its assertion.

## Decisions

- **Backfill, don't rewrite.** The three story-first profiles gain a
  final `## Eval notes` section; nothing else in them changes. The
  notes assert only what the portraits already claim.
- **Eval notes ≠ infrastructure notes.** "Rhymes and hooks" stays:
  it accounts for how ideas become data. Eval notes state what the
  entry tests and what failure looks like. Complements, not rivals.
- **The shape rule is charter now** (lore README, new flexibility
  principle 7): last section in the file, 2–4 sentences, one
  falsifiable minimum capability, never a feature list. Story-first
  entries make an expressibility claim; engine-first entries an
  emergence claim (vocabulary from post 0007 / the glossary).
- **The floor clause applies to the notes themselves** — an eval note
  that enumerates features is the PRD sneaking back in through the
  annex. This sentence is in the charter on purpose.
- **worlds.md gets one collective note**, not fifteen. The library's
  assertions were always collective (habitability-as-relation,
  types-as-presets, the shellsea's ceiling); per-type notes would
  have been padding. Judgment call, reversible if a type ever grows
  an assertion of its own.
- **The quality-gate corollary** (recorded in the charter's last
  sentence): an entry whose eval note cannot be written is not
  shelf-ready. This is card 130's filter against the gap-list bias —
  wise-gentle-likable pitches that prove nothing.

## The three assertions, as shipped

- **Vess**: a mind without a census — plural fuzzy-edged agents,
  consensus-speed decisions, unexpiring memory, war as severed
  connection. Fails: countable-individuals-only, forced market-tempo
  repricing, combat-only aggression.
- **Continuance**: a civilization that is an artifact — one mind to
  many forks, personhood as policy. Fails: civilization-equals-
  biological-species, polity granularity forced to one-or-unrelated-
  many, ledgers permitted to forget.
- **Marrow Fleet**: a civilization that stands nowhere — no
  homeworld, location as trajectories, wealth as rights and
  reputation. Fails: mandatory homeworld, location as fixed point,
  material-goods-only markets. Plus the card-122 rider: the carrier
  of news can be somebody.

## Docs sweep notes

- Lore README shelf-contents list predated card 118 (didn't list the
  Vessari/Khedrun files) — fixed in passing.
- Glossary gains **eval note**.
- Does the post need a visual? Asked, answered no: post 0003's
  complete track already carries the eval-loop diagram (shelf →
  mechanic → redesign/floor → surprise → next eval), and this post's
  contribution is a *writing form*, not a new mechanism. The post
  points at 0003's diagram instead of duplicating it.

## Owed / open

- Mike's interrogation of the three assertions — especially whether
  each fail-condition is one he'd actually enforce in a schema
  review. These are Claude's drafts of *Mike's* acceptance criteria;
  the working agreement's bar (defensible without Claude in the
  room) applies with extra force to a lore card.
- Post 0009 (*What Failure Looks Like*) drafted in both tracks;
  needs the joint pass before PR.
- PR after Mike's review — nothing committed yet, per the standing
  rule.
