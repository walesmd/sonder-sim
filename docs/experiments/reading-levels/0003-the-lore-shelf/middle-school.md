# The Lore Shelf

*Reading-level experiment · target: middle school · rewritten from `docs/posts/0003-the-lore-shelf.md` · original untouched*

---

Start with an excerpt from a story we wrote:

> **The Kept.** Some stayed on Marrow, in deep shielded warrens,
> keeping the old reefs. Transmissions continued for generations
> after the Leaving — thinner, stranger, then stopped. That was a
> very long time ago. Every Conjunction, some young crew formally
> proposes the Return Survey; every Conjunction, the elders vote it
> down, citing hazard, distance, and schedule. The actual reason is
> in no minutes anywhere: a hull that went back would either find
> graves and end the last hope, or find *something else* and end the
> mystery that a third of their liturgy leans on.

Walk through it slowly. "Some stayed on Marrow" — Marrow is the home world of an alien people called the Marrow Fleet, who left it long ago in giant ships. "Transmissions continued... then stopped" — the people left behind kept sending messages for generations, until the messages went quiet. "Every Conjunction" — a big gathering the Fleet holds — a young crew asks to go back and look, and the elders say no. The last sentence gives the reason nobody writes down: going back would either prove everyone died, or find something that destroys the mystery a third of their religion depends on. Either answer costs more than not knowing.

Here's the thing: no simulation wrote that paragraph. Our actual program, run with seed 1893, still contains exactly one placeholder market and one war office with nobody to command. The paragraph came from a folder of handwritten stories we call the lore shelf. The claim of this post is that those stories aren't decoration next to a program. They're test cases.

## Zero code, on purpose

This was our first increment that shipped no code — five commits of pure writing. It still counts as engineering, because some engineering is deciding the rules your future code must obey.

## Three aliens before breakfast

It started as a bedtime conversation. Mike asked seven questions about any alien civilization: What is their home world like? How did it shape them? What is their economy? How advanced are they? Do they have religion? How aggressive are they? What civilization-ending dangers do they know about?

We answered all seven, three times over:

- **The Vess**: a hive of living crystal whose minds are regions of vibrating lattice. For them, trading with an outsider is a sacred act.
- **The Continuance**: a maintenance AI whose creators left and never came back. Unable to compute a return date, it planned for *forever* — and accidentally became a civilization.
- **The Marrow Fleet**: a wandering people in grown generation ships who own almost nothing and carry every rumor across space, each rumor slightly shaped by the handling.

We picked them to pull in three directions on purpose: the Vess went from many minds to one, the Continuance from one mind to many, the Fleet stayed many and stayed moving. We also wrote fifteen world types, from Gardens to Graves, because civilizations need somewhere to be from.

## What the stories are for

Here is the sentence that took five sessions and three drafts to get right:

**The lore shelf is an eval suite, not a PRD — and a floor, not a ceiling.**

Two pieces of jargon, so let's define them. A **PRD** — product requirements document — is a checklist of everything a product must do. An **eval** — short for evaluation — is a test case: an example a system is checked against. They point in opposite directions. A PRD is like a shopping list: buy everything on it, then stop. An eval is like a fitness test: a bar you must clear, saying nothing about how much higher you can go.

Our stories are evals. The engine doesn't have to *produce* the Vess. It has to *never make the Vess impossible*. If a future mechanic can't hold one of these stories — a grudge held for centuries, a civilization with no home world — the mechanic failed. We redesign the mechanic, never the story.

"Floor, not ceiling" means passing is the minimum, not the goal. In Mike's words: *"We're not building systems to create these three civilizations. We're building a system that could at least create these three civilizations — but it could also create something way more advanced."* A machine that produces exactly our three aliens and nothing stranger has memorized the test instead of learning. There's a name for that trap: **Goodhart's law** — when a measure becomes a target, it stops being a good measure. There's also a name for writing tests before the thing exists: **test-driven development**.

One rule the stories forced: our worlds will never have a yes/no "habitable" checkbox, because habitability depends on *who's asking* — a garden paradise to one species is noisy dead rock to the Vess.

## What we got wrong

Three honest mistakes.

First, we wrote a law of physics by accident. An early draft said nothing travels faster than light, ever, as a permanent rule. But faster-than-light travel might be a *technology* a clever civilization invents someday. It's now a default, not a law. The change even gave the Fleet a new fear, the Whisper: news that outruns ships would ruin a people whose living is carrying news.

Second, the charter's most important sentences were all second drafts. The first version said that when a mechanic and a story clash, the mechanic wins — exactly backwards from what Mike wanted. Lesson: the framing sentences of a foundational document are the ones to hold open longest.

Third, our imagination has a bias, and a checklist caught it. Our three aliens are all ancient, gentle, religious, and likable. Left alone, we'd fill the universe with wise elders — and a universe of reasonable adults has dull wars. The road to thirty species starts from that gap list.

## Next

Back to code: the universe's history gets a permanent database file, so it stops evaporating when the terminal closes. The stories wait for the first civilization schema — their first chance to fail a mechanic that hasn't been written yet.

No code this time. The universe got bigger anyway.
