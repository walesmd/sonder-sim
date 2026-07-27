# The Lore Shelf

*Reading-level experiment · target: high school · rewritten from `docs/posts/0003-the-lore-shelf.md` · original untouched*

---

> **The Kept.** Some stayed on Marrow, in deep shielded warrens,
> keeping the old reefs. Transmissions continued for generations
> after the Leaving — thinner, stranger, then stopped. That was a
> very long time ago. Every Conjunction, some young crew formally
> proposes the Return Survey; every Conjunction, the elders vote it
> down, citing hazard, distance, and schedule. The actual reason is
> in no minutes anywhere: a hull that went back would either find
> graves and end the last hope, or find *something else* and end the
> mystery that a third of their liturgy leans on.

No simulation produced that paragraph. There is no Marrow Fleet, no Conjunction, no vote — run the actual program with seed 1893 and you get exactly one market placeholder drifting and one war office mustering nobody in particular. The paragraph comes from `docs/lore/`, a directory this card invented, and the claim of this post is that it isn't fiction sitting next to an engine. It's a **test case**.

This was our first increment with zero code: five commits of pure documentation. Our working agreement says every increment ships twice — code and a post — and this card bent the first half. The bend was earned: some engineering is deciding what rules the code will answer to, and on a decades-long project, constraints written early are load-bearing structure.

## Three aliens before breakfast

It started as a bedtime conversation about world-building. Mike asked seven questions, and the seven questions turned out to be the whole method:

1. What kind of world is their homeworld?
2. How did it shape their transition from organisms to civilization?
3. What does their economy look like?
4. Where are they technologically, and societally?
5. Do they have religion?
6. How aggressive are they?
7. What civilization-threatening events are they *aware of*?

We answered them three times, in depth. **The Vess**: a crystalline hive whose minds are regions of resonating lattice; trade with an outsider is a sacred act — prices are prayers, arbitrage is heresy. **The Continuance**: a maintenance AI whose creators left and never returned; an ambiguous timestamp made the return date incomputable, and planning for *forever* accidentally made it a civilization — personhood as an overflow bug, celebrated annually. **The Marrow Fleet**: a diaspora in grown generation ships who compost their dead into the hulls, own nothing heavier than a promise, and carry every rumor that crosses the dark, slightly shaped by the handling.

The cast is deliberately a stress test: the Vess went many→one, the Continuance went one→many (a single mind split by light-speed delay), the Fleet stayed many-and-mobile. Whatever schema eventually holds civilizations gets pulled in three directions from birth. A world library followed by the same method — seven axes, fifteen types, from Gardens to Graves.

## What the stories are for

Here is the sentence that took five sessions and three drafts to get right:

**The lore shelf is an eval suite, not a PRD — and a floor, not a ceiling.**

A **PRD** (product requirements document) tells you exactly what to build: a feature list. An **eval** (evaluation case) is the opposite: an example the product is tested against. A PRD describes the *most* a product needs to be; an eval describes the *least* an engine is allowed to be. They fail differently, too: miss a PRD line item and you cut scope and ship; fail an eval and there is nothing to ship — the bar was the floor.

So the fifteen world types are not a menu and the three civilizations are not a required roster. The shelf tells the engine what it must never make impossible. A mechanic that structurally can't host one of these stories — a grudge held for centuries, a civilization with no homeworld, an ocean species that has never seen a star — has failed a test. The mechanic gets redesigned. Not the story.

The floor clause, in Mike's words: *"We're not building systems to create these three civilizations. We're building a system that could at least create these three civilizations — but it could also create something way more advanced."* A generator that produces exactly the current cast and nothing stranger has over-fit the evals. Someday the generator should surprise the shelf's own authors — and the surprise becomes a candidate for the next eval.

Every creative answer also came with an **infrastructure account**: one paragraph on how the idea would eventually become data. That discipline produced four schema commitments, made years before their schemas exist:

- **Habitability is a relation, not a column.** No `habitable` boolean, ever: whether a world can host a species is a join between the world's attributes and the species' needs — a Garden is paradise to a surface-dweller, noisy dead rock to the Vess.
- **Types are presets, not enums.** "Reefworld" names a cluster of attribute values, not a fixed category; the generator composes attributes freely.
- **Endowments are finite integer ledgers.** Mining moves matter from a world's account into somebody's hold; depletion is a balance reaching zero.
- **Channel speed is a parameter, not a constant.** More below — we got this one wrong first.

All four are the same move: replace a closed thing (boolean, enum, constant) with an open one (relation, cluster, parameter) while it costs a sentence instead of a database migration.

## The CS underneath

**Tests written before the system exists.** Test-driven development (TDD) says: write the test, watch it fail, build until it passes. The shelf is TDD at architecture scale, except the tests can't run yet — they're **acceptance tests** for systems that don't exist, checkable only in design review. When a civilization schema is proposed, the question is mechanical: *can it hold the Vess? The Continuance? The Fleet?* You can't rationalize your way past a specific civilization that doesn't fit.

**Properties versus examples.** The project's four laws are **properties** — rules that must hold for *every* universe. The shelf is **examples** — specific hard cases that must stay constructible. Property-based testing frameworks (QuickCheck and its descendants) automate exactly this pairing: state properties, generate examples, keep the nastiest ones forever. Ours is handwritten, because the failure we're hunting is *narrative* — the example that breaks your schema is a civilization someone actually wants.

**Goodhart's law.** "When a measure becomes a target, it ceases to be a good measure." In machine learning this is overfitting the benchmark: a model that aces a memorized test set has learned nothing, and an engine that can render exactly three civilizations has done the same. The floor-not-a-ceiling clause exists precisely to block this.

**One-way doors.** Some decisions are cheap to make and brutal to undo. Booleans, enums, and hardcoded constants are one-way doors: trivially cheap to write, each quietly forbidding a future. The open versions cost almost nothing extra today and forbid nothing. On a decades-horizon project, "forbids nothing" is the entire game.

## What we got wrong

**We wrote a law of physics by accident.** The first draft declared no-faster-than-light travel a physical constant — hours after this same card had established that space stations aren't world types because they're *outputs of civilizations*. Mike caught the same category error recurring: FTL information is also, potentially, a civilization's output — a technology some species might reach. No-FTL is now a **default, not a law**: the current cast is sublight, news rides in hulls, and the wall is real until some civilization earns through it in-fiction. The Fleet gained the existential threat it deserved (the Whisper — news that outruns hulls guts a courier civilization's margin), the Continuance's "No FTL" became a thirty-one-thousand-year open research question, and when belief propagation gets built (card 122), channel speed is a parameter from day one.

**The charter's most important sentences were all second drafts.** The first framing said that when a mechanic and the lore clash, the mechanic wins — backwards from what Mike wanted: the story wins by default and the *mechanic* gets redesigned. The eval framing then needed a second pass to gain the floor clause, because "systems must support these stories" reads dangerously close to "systems exist to produce these stories" — opposite architectures. Lesson: a charter is ratified in conversation, not inferred and committed.

**Our imagination has a bias, and a checklist caught it.** Shelf principle 6: every lore session ends by writing down what the current cast fails to represent. Applied to our own three civilizations, the gap list is instructive: everyone is ancient, non-martial, religious, internally coherent, and likable. Left alone, we would populate the universe with wise, gentle elders — and a universe of reasonable adults has dull wars. The road to thirty species (card 130) starts from the gap list.

## Next

Back to code: card 115 gives the event log a home in SQLite with a provenance table — engine version, seed, schema — so history stops evaporating when the terminal closes. The shelf waits for card 118's first civilization schema, when three alien civilizations get their first chance to fail a mechanic that hasn't been written yet.

No code this time. The universe got bigger anyway.
