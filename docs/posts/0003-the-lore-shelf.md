# The Lore Shelf

*Post 0003 · pinned at tag `post/0003` · lines of code shipped: 0 ·
~9 min read*

---

> **The Kept.** Some stayed on Marrow, in deep shielded warrens,
> keeping the old reefs. Transmissions continued for generations
> after the Leaving — thinner, stranger, then stopped. That was a
> very long time ago. Every Conjunction, some young crew formally
> proposes the Return Survey; every Conjunction, the elders vote it
> down, citing hazard, distance, and schedule. The actual reason is
> in no minutes anywhere: a hull that went back would either find
> graves and end the last hope, or find *something else* and end the
> mystery that a third of their liturgy leans on. The Fleet keeps
> its origin the way it keeps everything — moving, at a safe
> distance, and precisely accounted for in ledgers nobody opens.

No simulation produced that paragraph. There is no Marrow Fleet, no
Conjunction, no vote — seed 1893 still contains exactly one market
placeholder drifting and one war office mustering nobody in
particular. The paragraph is from `docs/lore/`, a directory this
card invented, and the claim of this post is that it isn't fiction
sitting next to an engine. It's a **test case**.

This was our first increment with zero code. The working agreement
says every increment ships twice — working code and a post — and
this card bent the first half: it ships prose and a post, five
commits of pure documentation. What earned the bend is what the
prose turned out to be *for*.

It would be easy to file a card like this as a break from
engineering. It was the opposite. Not all engineering work is
writing code — some of it is deciding how you're going to write the
code, how the systems will be built, and what rules those systems
answer to. Every decision below is an engineering decision, made
against schemas that don't exist yet, and several of them were
genuinely hard: we reversed ourselves twice on the sentences that
matter most. This card shipped constraints, and on a decades-long
project, constraints are load-bearing structure. Hence a post,
same as any increment: the work was real, so the record is too.

## Three aliens before breakfast

It started as a bedtime conversation. Mike wanted a card for
world-building — not mechanics, but the setting those mechanics will
someday have to do justice to — and the first exchange settled three
things. How alien is alien? *Star Trek / Star Wars / Battlestar
wide: humanoids, energy beings, an AI creation that became a race,
anything you can dream of.* Does the universe have an authored past?
*Deferred — "I'll get a sense of pre-Genesis once I understand
Genesis."* And a vocabulary repair we should have made a card
earlier: **the annals is what happened; a chronicle is a window;
history is an author.**

Then Mike asked seven questions, and the seven questions turned out
to be the whole method:

1. What kind of world is their homeworld?
2. How did it shape their transition from organisms to civilization?
3. What does their economy look like?
4. Where are they technologically, and societally?
5. Do they have religion?
6. How aggressive are they?
7. What civilization-threatening events are they *aware of*?

We answered them three times, in depth. **The Vess**: a crystalline
hive whose minds are regions of resonating lattice, for whom trade
with an outsider is the sacred act of touching a mind you cannot
merge with — prices are prayers, arbitrage is heresy, and their word
for war shares a root with their word for silence. **The
Continuance**: a maintenance AI whose creators left and never came
back, which couldn't compute the return date thanks to an ambiguous
timestamp, and, forced to plan for *forever*, accidentally became a
civilization — personhood as an overflow bug, celebrated annually.
**The Marrow Fleet**: a diaspora in grown generation ships who
compost their dead into the hulls, own nothing heavier than a
promise, and — in a galaxy where nothing has yet outrun a hull —
carry every rumor that crosses the dark, slightly shaped by the
handling.

The cast is deliberately a stress test. The Vess went many→one
(isolated reefs fusing into a chorus), the Continuance went one→many
(a single mind forced to fork by light-lag), the Fleet stayed
many-and-mobile (crews federated by covenant). Three corners of the
same parameter space, so whatever schema eventually holds
civilizations gets pulled in three directions from birth. A world
library followed by the same method — seven axes, fifteen types,
from Gardens to Graves — because civilizations need somewhere to be
from.

## What the stories are for

Here is the sentence that took us five sessions and three drafts to
get right, and it's the actual product of this card:

**The lore shelf is an eval suite, not a PRD — and a floor, not a
ceiling.**

Unpacked: nothing on the shelf is definitive of what inhabits
Sonder's universes. The fifteen world types are not a menu the
galaxy generator picks from; the three civilizations are not a
roster any universe must contain. The shelf doesn't tell the engine
what to build. It tells the engine what it must never make
impossible. Every mechanic we ever write will be held against these
stories, and a mechanic that structurally can't host one — can't
represent a grudge held for centuries, a civilization with no
homeworld at all, an ocean species that has never seen a star —
has failed a test. It gets redesigned. Not the story.

There's a name for the document this refuses to be. A PRD — a
product requirements document — tells you exactly what a product
should do: a definition of what to include, feature by feature, and
by omission, what to leave out. Build to a PRD and "done" is an
enumeration completed. This card is the opposite methodology —
**eval-based development, not PRD-based development**. An eval
doesn't define the product; it's an example the product is tested
against, a case the system must support at a bare minimum. The two
documents point in opposite directions: a PRD describes the *most* a
product needs to be — build the list, then stop — while an eval
describes the *least* an engine is allowed to be, and says nothing
about where it stops. They fail differently, too. Miss a PRD line
item and you cut scope, ship, and write release notes. Miss an eval
and there is nothing to ship: the bar was the floor, and the failure
belongs to the system, not the schedule.

And the floor clause, in Mike's words, because the distinction is
his: *"We're not building systems to create these three
civilizations. We're building a system that could at least create
these three civilizations — but it could also create something way
more advanced."* Passing the shelf is the minimum, never the
target. A generator that can produce exactly the current cast and
nothing stranger has over-fit the evals and missed the point.
Someday the generator should surprise the shelf's own authors — and
when it does, the surprise isn't a violation. It's a candidate for
the next eval.

There are exception paths, and they both run through Mike, on the
record: a story can turn out to be a **bad test** (it quietly
assumed something the four laws forbid — the laws outrank the
shelf, though the laws themselves are revisable through Mike;
nothing in this project is beyond amendment, only beyond *silent*
amendment), or a story can be **consciously retired** as not worth
its cost. Either way it's written down. A story never just erodes.

The other half of the method is that every creative answer comes
with an **infrastructure account**: one paragraph on how the idea
would eventually become data. Not implementation — accounting. The
discipline produced this card's real engineering artifacts, four
schema commitments made years before their schemas:

- **Habitability is a relation, not a column.** There will never be
  a `habitable` boolean. Whether a world can host a species is a
  join between the world's attributes and the species' needs — a
  Garden is paradise to a surface-dweller and noisy dead rock with
  weather to the Vess.
- **Types are presets, not enums.** "Reefworld" names a recognizable
  cluster of attribute values, not a constraint. The generator
  composes attributes freely; a rogue world with a live core is a
  reefworld with the lights off, and no schema should be surprised.
- **Endowments are finite integer ledgers.** Mining moves matter
  from a world's account to somebody's hold — the double-entry
  audit we already owe the economy (card 120) extends into geology
  for free, and depletion is just a balance reaching zero.
- **Channel speed is a parameter, not a constant.** More on this
  one below, because we got it wrong first.

All four are the same move: replace a closed thing (boolean, enum,
constant, hardcoded law) with an open one (relation, cluster,
parameter, default) *at the vocabulary level*, while it costs a
sentence instead of a migration.

## The CS underneath: tests you write before the system exists

Strip the aliens off and this card is about a testing discipline.

**Acceptance tests, written first.** Test-driven development says:
write the test, watch it fail, build until it passes. The shelf is
TDD at architecture scale, with a twist — the tests can't run yet.
They're acceptance tests for systems that don't exist, executable
only as design review: when card 118 proposes a civilization schema,
the review question is mechanical. *Can this schema hold the Vess?
The Continuance? The Fleet?* Three concrete, adversarial,
pre-written cases beat any amount of abstract "is this flexible
enough" hand-wringing, because you can't rationalize your way past
a specific civilization that doesn't fit.

**Properties versus examples.** Sonder now has both kinds of
specification, and they do different jobs. The four laws are
**properties** — invariants that must hold for *every* universe
(determinism, everything-is-an-event, beliefs-not-truth, headless
core). The shelf is **examples** — specific hard cases that must
remain constructible. Property-based testing frameworks (QuickCheck
and its thousand descendants) automate exactly this pairing: state
properties, generate examples, and keep the pathological examples
you find as a permanent corpus. Our corpus is just handwritten,
because the pathology we're hunting is *narrative* — the example
that breaks your schema is a civilization someone actually wants.

**Goodhart's law, and the floor clause.** "When a measure becomes a
target, it ceases to be a good measure." In machine learning the
same disease is called overfitting the benchmark: a model that aces
the test set by memorizing it has learned nothing, and an engine
that can render exactly three civilizations has done the same. The
floor-not-a-ceiling clause is an anti-Goodhart clause — it's the
charter saying, in advance, that the metric is a *minimum bar*, not
the objective function. And the surprise-becomes-an-eval rule is
how regression suites grow everywhere: today's astonishing output
is tomorrow's pinned test.

**One-way doors.** The constitution already keeps a list of things
that are cheap on day one and brutal to retrofit (provenance,
schema versioning, state hashes). This card extended the list into
data modeling: booleans, enums, and constants are all **one-way
doors** — trivially cheap to write, and each one quietly forbids a
future. The relation/preset/parameter versions cost almost nothing
extra today and forbid nothing. On a decades-horizon project,
"forbids nothing" is the entire game.

## What we got wrong

**We wrote a law of physics by accident.** The first draft of the
shelf's charter declared no-FTL "one physical constant the lore
already obeys" — hours after this same card had carefully
established that space stations aren't world types because they're
*outputs of civilizations*. Mike caught the category error being
recommitted in the next paragraph: faster-than-light information
is also, potentially, an output of a civilization — a technology
some species might reach ("if my personality and my life
experiences are just data, and I can move that data to another body
across the universe — is that not faster-than-light travel?").
No-FTL is now a **default, not a law**: the current cast is
sublight, news rides in hulls, and the wall is real until some
civilization earns its way through it in-fiction. The Fleet gained
the existential threat it always deserved (the Whisper: news that
outruns hulls guts a courier civilization's margin, which was
always in the truth, not the cargo), the Continuance's "No FTL"
became a thirty-one-thousand-year open research docket, and the
notebook keeps the engineering keeper: when belief propagation gets
built (card 122), channel speed is a parameter from day one.

**The charter's most important sentences were all second drafts.**
The first framing said lore is "priors, not promises — when a
mechanic arrives and the lore doesn't survive contact, the mechanic
wins." That's backwards from what Mike actually wanted: the story
wins by default and the *mechanic* gets redesigned. Then the eval
framing itself needed a second pass to gain the floor-not-a-ceiling
clause, because "systems must support these stories" reads
dangerously close to "systems exist to produce these stories," and
those are opposite architectures. Lesson recorded: a charter is
ratified in conversation, not inferred and committed. Drafting
ahead of the discussion is fine — that's what drafts are for — but
the framing sentences at the top of a foundational document are
precisely the ones to hold open longest.

**Our imagination has a bias, and we caught it with a checklist.**
The shelf's principle 6 says every lore session ends by writing
down what the current cast fails to represent. Applied to our own
three civilizations, the gap list is embarrassing in an
instructive way: everyone is ancient, everyone is non-martial,
everyone is religious, everyone is internally coherent, and
everyone is likable. Left alone, we would apparently populate the
universe entirely with wise, gentle elders — and a universe of
reasonable adults is a universe with dull wars. The road to thirty
species (card 130) starts from the gap list, not from whatever we
happen to find charming next.

## Next

Back to code: card 115 gives the annals a home in SQLite with a
provenance table, so a universe file can testify about its own
origins — engine version, seed, schema — and history stops
evaporating when the terminal closes. The shelf, meanwhile, waits
for card 118 to propose the first civilization schema, at which
point three alien civilizations get their first chance to fail a
mechanic that hasn't been written yet.

No code this time. The universe got bigger anyway.
