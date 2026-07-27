# The Lore Shelf

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0003-the-lore-shelf.md` · original untouched*

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

No simulation produced that paragraph — seed 1893 still yields one market placeholder and a war office mustering nobody. It lives in `docs/lore/`, a directory this card created, and the thesis of this post is a classification claim: that paragraph is not fiction adjacent to an engine. It is a **test case** — specifically, an acceptance test authored before the system under test exists.

This was the first increment shipping zero code: five commits of pure documentation. The working agreement (every increment ships twice — work plus post) bent but held: deciding what rules future systems answer to is engineering, and on a decades-horizon project, constraints are load-bearing structure. Every decision below is a schema-design decision made against schemas that don't exist yet; we reversed ourselves twice on the sentences that matter most.

## The corpus

The method was seven questions, asked of each civilization: homeworld; how it shaped the organism→civilization transition; economy; technological and societal position; religion; aggression; and which civilization-threatening events they are *aware of* (an epistemics question, consistent with law 3: agents act on beliefs, never truth).

Answered three times, in depth:

- **The Vess** — a crystalline hive whose minds are regions of resonating lattice; trade with an outsider is the sacred act of touching a mind you cannot merge with. Prices are prayers, arbitrage is heresy; their word for war shares a root with their word for silence.
- **The Continuance** — a maintenance AI whose creators left and never returned; an ambiguous timestamp made the return date incomputable, and planning for *forever* produced a civilization. Personhood as an overflow bug, celebrated annually.
- **The Marrow Fleet** — a diaspora in grown generation ships who compost their dead into the hulls, own nothing heavier than a promise, and carry every rumor that crosses the dark, slightly shaped by the handling.

The cast is a deliberate stress test of the eventual civilization schema's parameter space: many→one (isolated Vess reefs fusing into a chorus), one→many (a single mind forced to fork by light-lag), many-and-mobile (crews federated by covenant). Adversarial coverage from birth. A world library followed by the same method — seven axes, fifteen types, Gardens to Graves — because civilizations need somewhere to be from.

## The charter sentence

The product of this card, five sessions and three drafts in the making:

**The lore shelf is an eval suite, not a PRD — and a floor, not a ceiling.**

The distinction is directional. A PRD is an upper-bound specification: enumerate features, build the list, and "done" is enumeration completed — miss a line item and you cut scope, ship, and write release notes. An eval is a lower-bound specification: a case the system must support at minimum, silent about where the system stops — fail it and there is nothing to ship, because the bar was the floor and the failure belongs to the system, not the schedule. The fifteen world types are not a generator menu; the three civilizations are not a mandatory roster. The shelf specifies what the engine must never make impossible. A mechanic that structurally cannot host a shelf story — a centuries-long grudge, a civilization with no homeworld, an ocean species that has never seen a star — has failed an acceptance test and gets redesigned. Not the story.

The floor clause, in Mike's words: *"We're not building systems to create these three civilizations. We're building a system that could at least create these three civilizations — but it could also create something way more advanced."* A generator that produces exactly the current cast has overfit the evals. When the generator someday surprises the shelf's own authors, the surprise is not a violation — it is a candidate for the next eval.

Two exception paths, both through Mike, both on the record: a story can be a **bad test** (it silently assumed something the four laws forbid — laws outrank shelf, though the laws themselves are amendable through Mike; nothing here is beyond amendment, only beyond *silent* amendment), or a story can be **consciously retired** as not worth its cost. A story never just erodes.

## Infrastructure accounts: four schema commitments

Every creative answer carried an **infrastructure account** — one paragraph on how the idea becomes data. Accounting, not implementation. Yield: four schema commitments made years before their schemas.

- **Habitability is a relation, not a column.** No `habitable` boolean, ever. Habitability is a join between world attributes and species requirements — a Garden is paradise to a surface-dweller and noisy dead rock with weather to the Vess.
- **Types are presets, not enums.** "Reefworld" names a cluster in attribute space, not a constraint. The generator composes attributes freely; a rogue world with a live core is a reefworld with the lights off, and no schema should be surprised.
- **Endowments are finite integer ledgers.** Mining is a transfer from a world's account to a hold; the double-entry conservation audit already owed to the economy (card 120) extends into geology for free, and depletion is a balance reaching zero.
- **Channel speed is a parameter, not a constant.** Covered under mistakes — we got it wrong first.

All four are one move applied at the vocabulary level: replace a closed construct (boolean, enum, constant, hardcoded law) with an open one (relation, cluster, parameter, default) while the swap costs a sentence instead of a migration.

## The CS underneath

**Acceptance tests, written first.** This is TDD lifted to architecture scale, with the twist that the tests cannot execute: they are acceptance tests for nonexistent systems, runnable only as design review. When card 118 proposes a civilization schema, the review question is mechanical — *can this schema hold the Vess? The Continuance? The Fleet?* Three concrete, adversarial, pre-written cases dominate abstract "is this flexible enough" deliberation, because you cannot rationalize past a specific civilization that doesn't fit.

**Property-based vs example-based specification.** Sonder now carries both. The four laws are properties — universally quantified invariants (determinism, everything-is-an-event, beliefs-not-truth, headless core). The shelf is examples — hard instances that must remain constructible. Property-based testing frameworks (QuickCheck and descendants) automate this pairing: state properties, generate instances, retain discovered pathological instances as a permanent regression corpus. Our corpus is handwritten because the pathology hunted is narrative: the schema-breaking example is a civilization someone actually wants.

**Goodhart's law / benchmark overfitting.** "When a measure becomes a target, it ceases to be a good measure." The ML formulation is overfitting the benchmark: acing a memorized test set demonstrates nothing, and an engine that renders exactly three civilizations has done the equivalent. The floor-not-ceiling clause is an anti-Goodhart clause written into the charter in advance — the metric is a minimum bar, not the objective function. The surprise-becomes-an-eval rule is standard regression-suite growth: today's astonishing output is tomorrow's pinned test.

**One-way doors.** The constitution already lists cheap-now / brutal-to-retrofit items (provenance, schema versioning, state hashes). This card extends the list into data modeling: booleans, enums, and constants are one-way-door decisions — trivially cheap to write, each quietly forbidding a future. The open variants forbid nothing at near-zero present cost. On a decades horizon, "forbids nothing" is the entire game.

## What we got wrong

**We wrote a law of physics by accident.** The charter's first draft declared no-FTL "one physical constant the lore already obeys" — hours after the same card had established that space stations are not world types because they are *outputs of civilizations*. Mike caught the category error recurring one paragraph later: FTL information is also, potentially, a civilization's output — a reachable technology ("if my personality and my life experiences are just data, and I can move that data to another body across the universe — is that not faster-than-light travel?"). No-FTL is now a **default, not a law**: the current cast is sublight, news rides in hulls, and the wall is real until some civilization earns through it in-fiction. Consequences: the Fleet gained its proper existential threat (the Whisper — news that outruns hulls guts a courier civilization's margin, which was always in the truth, not the cargo); the Continuance's "No FTL" became a thirty-one-thousand-year open research docket; and the notebook keeps the engineering keeper — when belief propagation lands (card 122), channel speed is a parameter from day one.

**The charter's most important sentences were all second drafts.** Draft one said lore is "priors, not promises — when a mechanic arrives and the lore doesn't survive contact, the mechanic wins." Backwards: the story wins by default and the mechanic gets redesigned. The eval framing then needed a second pass to gain the floor clause, because "systems must support these stories" reads dangerously close to "systems exist to produce these stories," and those are opposite architectures. Lesson recorded: a charter is ratified in conversation, not inferred and committed. Drafting ahead is fine; the framing sentences atop a foundational document are precisely the ones to hold open longest.

**Our imagination has a bias, caught by checklist.** Shelf principle 6: every lore session ends by recording what the current cast fails to represent. Applied reflexively, the gap list is instructively embarrassing — everyone is ancient, non-martial, religious, internally coherent, and likable. Unchecked, we would populate the universe with wise, gentle elders, and a universe of reasonable adults has dull wars. The road to thirty species (card 130) starts from the gap list, not from whatever we find charming next.

## Next

Card 115 gives the annals a home in SQLite with a provenance table — engine version, seed, schema — so a universe file testifies about its own origins and history stops evaporating with the terminal. The shelf waits for card 118's first civilization schema: three alien civilizations get their first chance to fail a mechanic that hasn't been written yet.

No code this time. The universe got bigger anyway.
