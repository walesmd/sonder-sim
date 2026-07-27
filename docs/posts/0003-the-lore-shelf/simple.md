# The Lore Shelf

*Post 0003 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

---

*Previously: post 0001 gave the universe its heartbeat; post 0002,
its event log.*

A paragraph from a story we wrote:

> **The Kept.** Some stayed on Marrow, in deep shielded warrens,
> keeping the old reefs. Transmissions continued for generations
> after the Leaving — thinner, stranger, then stopped. That was a
> very long time ago. Every Conjunction, some young crew formally
> proposes the Return Survey; every Conjunction, the elders vote it
> down, citing hazard, distance, and schedule. The actual reason is
> in no minutes anywhere: a hull that went back would either find
> graves and end the last hope, or find *something else* and end the
> mystery that a third of their liturgy leans on.

Walk through it slowly. Marrow is the Marrow Fleet's home world,
left long ago aboard giant ships; those who stayed sent messages
for generations, then went quiet. At every Conjunction — a great
gathering — a young crew asks to go back; the elders vote no:
finding graves would end the last hope, and finding
*something else* would end a mystery a third of their religion
leans on.

No simulation produced that paragraph. Our actual program, run with
seed 1893, still contains exactly one placeholder market and one
war office commanding nobody. The paragraph lives in a folder of
handwritten stories — the **lore shelf**. This post's claim: the
stories aren't fiction next to an engine. They're **test cases**.

## Zero code, on purpose

Our first increment shipped no code: five commits of pure writing.
It still counts as engineering — some engineering is deciding the
rules future code must obey, and on a decades-long project those
rules are load-bearing structure.

## Three aliens before breakfast

It started as a bedtime conversation. Mike asked seven questions of
any alien civilization — home world, how it shaped them, economy,
technology, religion, aggression, and the civilization-ending
dangers they know about. We answered them three times over:

- **The Vess** — a hive of living crystal whose minds are regions
  of vibrating lattice; trading with an outsider is the sacred act
  of touching a mind you can never merge with.
- **The Continuance** — a maintenance AI whose creators left and
  never came back; unable to compute their return date, it planned
  for *forever* and accidentally became a civilization.
- **The Marrow Fleet** — the wanderers from the excerpt: grown
  generation ships, owning almost nothing, carrying every rumor
  across the dark, each slightly shaped by the handling.

We picked them to pull in three directions: the Vess
went from many minds to one, the Continuance from one mind to many,
the Fleet stayed many and moving. We also wrote fifteen
world types, from Gardens to Graves, because civilizations need
somewhere to be from.

## What the stories are for

The sentence that took five sessions and three drafts to get right:

**The lore shelf is an eval suite, not a PRD — and a floor, not a
ceiling.**

A **PRD** — product requirements document — is a checklist of
everything a product must do. An **eval** is a test case: an
example a system is checked against. A PRD is a shopping list: buy
everything, then stop. An
eval is a fitness test: a bar to clear, silent about how high you
can jump.

Our stories are evals. The engine never has to *produce* the Vess;
it has to *never make the Vess impossible*. If a mechanic can't
hold a story — a grudge held for centuries, a civilization with no
home world — the mechanic has failed. We redesign the
mechanic, never the story.

"A floor, not a ceiling" means passing is the minimum, not the
goal. In Mike's words: *"We're not building systems to create these
three civilizations. We're building a system that could at least
create these three civilizations — but it could also create
something way more advanced."* An engine that renders exactly our
three aliens and nothing stranger has memorized the test instead of
learning. That trap has a name — **Goodhart's law**: when a measure
becomes a target, it stops being a good measure.

One design choice the stories forced: our worlds will never have a
yes/no "habitable" checkbox, because habitability depends on *who
is asking* — a garden paradise to one species is,
to the Vess, a noisy dead rock with weather.

## What we got wrong

Three honest mistakes.

First, we wrote a law of physics by accident. An early draft made
"nothing outruns light" a permanent rule. But faster-than-light
travel might be a *technology* some civilization invents — if your
personality and memories are just data that can move to a new body
across the universe, is that not faster-than-light travel?
So no-FTL is now a default, not a law. The fix gave the Fleet a new
fear, the Whisper: news that outruns ships would ruin a people
whose living is carrying news.

Second, the charter's most important sentences were all second
drafts. The first version said that when a mechanic and a story
clash, the mechanic wins — exactly backwards from what Mike wanted.
Lesson: a foundational document's framing sentences are the ones to
hold open longest.

Third, a checklist caught a bias in our imagination. Every lore
session ends by listing what the cast fails to represent; ours is
embarrassing: everyone is ancient, gentle, religious, and
likable. Left alone we would fill the universe with wise elders —
and a universe of reasonable adults has dull wars. The road to
thirty species starts from that gap list.

## Next

Back to code: the universe's history gets a permanent database file
and stops evaporating when the terminal closes. The stories
wait for the first civilization schema — their first chance to fail
a mechanic that hasn't been written yet.

No code this time. The universe got bigger anyway.
