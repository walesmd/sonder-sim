# News at Ship Speed

*Post 0011 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: our simulated universe has two nations, one grain
market, and a rule that every nation acts only on what it believes —
never on the truth directly. Until now, that rule was a formality,
because news traveled instantly. This post is about making news
slow, and what that broke, revealed, and made possible.*

---

Until this week, everyone in universe 1893 was omniscient. The
moment anything happened anywhere — a trade, a war, a bad harvest —
every nation knew it instantly. That was always meant to be
temporary. Real news crosses real distance, and this card finally
made it do so.

The world got a map. The Vessari's farmlands are three days from
the grain exchange; the Khedrun's holds are five days out on the
other side; the two nations are eight days apart. News now travels
those roads at a fixed speed, so every piece of knowledge arrives
late — a little late if it happened nearby, over a week late if it
happened across the map.

Each nation's newspaper now prints two dates on every line: when
they *learned* a thing, and when it actually *happened*. Here is
the moment the Vessari found out a war had been declared on them:

```
tick   90 ← tick   82 · the khedrun declare war on the vessari
tick   91 ← tick   83 · a khedrun war party rides out (force 12)
tick   91 ← tick   91 · a khedrun war party falls on the vessari granaries
```

Read that middle pair closely. On day 91, the Vessari learn that a
war party left the Khedrun capital eight days ago — and that same
morning, that same party arrives at their granaries. The warning
arrived with the sword. In a universe where everything moves at one
speed, no messenger can outrun an army, so wars simply cannot be
seen coming. (Someday, when spies and faster ships exist, warnings
will beat armies. That's a future card.)

The war looks even stranger from the other side. The Khedrun
declared it, sent out a war party every day for ten days, and then
made peace — and in their entire newspaper there is not a single
battle. The news of what their own war parties did was still on the
road home. They ended their war without ever hearing whether they
were winning it; the first word of their own victories arrived
seven days *after* their peace. And because armies can't be
recalled — a rider can't catch a war party moving at the same
speed — six parties were still marching when peace was signed, and
raids kept landing for six more days. A war that ended before its
last battle, produced by nothing but geometry.

Slow news also changed what the nations' bookkeeping *means*. Every
day, each nation writes down what it believes it owns. An
independent auditor refolds the whole history and checks those
claims against the truth — and now the claims are always a little
wrong, because a nation that sold grain three days ago hasn't heard
the sale went through. That used to be forbidden; now it's the
point. So the auditor got smarter instead of stricter: it knows the
map too, computes exactly which news was still on the road at the
moment of every claim, and demands that the books be wrong by
*precisely that much and nothing more*. Over 300 days: 296 wrong
claims, 296 explained to the cent, zero unexplained. Honest
ignorance passes. And a new test proves the other case: we forged a
nation's claim outright, and it landed in a third category —
unexplained — because no road could account for it. The auditor now
tells ignorance from lying, using arithmetic.

We made two mistakes worth confessing. First, the word `visibility`
had been stamped on every event since long before this card, and we
spent a morning building rules on top of it before Mike pointed out
the word claims something impossible: whether a thing stays secret
isn't a property of the thing — it's the behavior of whoever knows
it. Two spies talking is a secret only until one of them talks. So
the field was renamed to what an event can honestly carry —
`loudness`, how noisy the act itself was — and all the machinery
built on the old reading went in the bin the same day.

Second, a bug: each nation's bookkeeping quietly threw away any
news that arrived late — which, once all news arrived late, meant
the Khedrun's believed treasury sat frozen at its founding value
for sixty days while imaginary hunger pushed them into real wars.
We caught it in review, and the fix used a small feature we'd built
for an entirely different reason: every belief is stamped with the
day it arrived, and the books now ask "when did I learn this?"
instead of "what number does it carry?"

One more change, our favorite. You can now open any nation's
newspaper directly: `--believes vessari` replays the whole feed as
the Vessari received it — late, partial, and completely coherent
from the inside — and you can ask for any past day, because a
mind's history is fully reconstructable from the universe's log.
Run the same universe three ways — the truth, the Vessari's
picture, the Khedrun's — and you get three different feeds with one
identical seal, `a3b626e777c0eaff`, proving they're three views of
a single history.

This project is named after the realization that every passerby has
an inner life as vivid as your own. As of this card, that's a
command-line flag.
