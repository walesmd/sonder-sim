> **DRAFT** — written before any code existed, as a picture of where this
> is going. The chronicle excerpt, install steps, dates, and line counts
> are aspirational until v0.1 ships. To be re-cut for publication.

# First Tick

*Post 0000 · code pinned at tag `post/0000` · Lua 5.4 · this post's universe: seed `1893` · ~8 min read*

---

```
day 214   heliox closes at 9.4 credits — up 21% this season. The
          Vessari Combine cites "market conditions." The market
          conditions are that the Vessari Combine owns the market.

day 231   the Khedrun war-moot votes, five banners to two, that it
          is cheaper to take the Heliox Reach than to keep buying it.

day 246   first blood at Anchor Station Nine. Three hulls lost.

day 519   the Reach changes hands for the fourth time.

day 638   armistice — of exhaustion, not agreement.

day 1000  run complete. Vessari treasury at 44% of day one.
          Five of nine Khedrun banners remain.
```

Nobody wrote that story. It fell out of a seed number, two invented
cultures, one commodity market, and about eight hundred lines of Lua, in
the two seconds it took to simulate a thousand days. Run the same seed and
you will get the same thousand days, down to the last hull. Change one
digit and you get a universe nobody has ever seen.

Or rather: nobody wrote the *story*. We wrote the rules. Learning to be
surprised by our own program — on purpose, repeatedly, for years — is more
or less the entire project.

## What this is

Sonder is a universe you read. Many simulated civilizations, each with its
own proclivities, grudges, and economic instincts, trading and scheming
and occasionally shooting at each other across a procedurally grown
galaxy. You are not a player in any usual sense. You are something between
a god and a subscriber: the simulation runs whether or not you watch,
history accumulates whether or not you read it, and your interventions —
when you bother to make them — are small, deliberate, and remembered
forever by the universe you meddled with.

The long-term ambition is a machine you can zoom through. At the widest
setting you watch empires collide. Zoom in and you see the same war twice,
once through each side's records, which do not agree — and were never
going to, because in Sonder no civilization acts on the truth. Each acts
on what it *knows*, which is partial, late, and bent by culture. Somewhere
on the rim there is a small civilization that has never heard of either
empire, whose chronicle this year records a good harvest and some
troubling lights in the sky.

There is no roadmap to 1.0, because there is no 1.0. We expect to work on
this for a very long time — plausibly decades — adding one mechanic at a
time and writing down what each one taught us. Which brings us to the
point.

## Why we're doing it

The learning is not a side effect. It is the product, tied for first place
with the universe itself.

Every mechanic in Sonder ships with an essay: what we added, what it does
to the simulated world (with excerpts from the chronicle as evidence), and
the computer science underneath it. This works because a universe
simulator is a machine for making CS concepts *necessary* rather than
assigned. Priority queues show up because fleets need arrival times. Graph
algorithms show up because trade is a network. Distributed-systems theory
shows up because light is slow and news travels on merchant ships. Nothing
gets taught in the abstract; everything gets built because the universe
demanded it.

There is a second, quieter reason. Most complex systems you will ever
encounter, you meet full-grown — the codebase at your job is a city with
no record of why any street goes where it goes. Sonder is being built in
public from its first tick, and every post pins the exact commit it
describes. You can stand at any point in this project's history and look
around. The repository is an experiment in whether a system can stay
legible for its entire life.

## The bets

We made four architectural decisions before writing much code. We expect
to defend them, and eventually to regret at least one of them, in public.

**Lua.** An economy simulation is mostly bookkeeping — inventories,
prices, treaties, grudges — and Lua's tables are unreasonably good at
bookkeeping. It is a small language that composes simple structures into
complicated ones, which is also a fair description of the universe we're
modeling. Its professional pedigree is exactly this niche: the
rules-and-content layer of simulation-heavy games. And there is a
criterion engineers pretend not to use: joy. One of us has loved this
language for years, and on a project measured in decades, that is a
load-bearing fact. Also — we noticed this after deciding, and we are
keeping it — *lua* is Portuguese for "moon." We are building a cosmos in a
language named after the sky.

**Determinism is the one non-negotiable law.** A seed plus a version of
the code produces exactly one universe, every time, on every machine. No
wall-clock reads inside the simulation, named RNG streams per subsystem,
no iteration over unordered tables anywhere it could change an outcome. We
got humbled by that last one within hours: Lua's `pairs()` walks a table
in whatever order it pleases, and our very first universe quietly refused
to happen the same way twice. The fix, and the whole doctrine, is post
0001. What determinism buys is almost everything we care about: perfect
replays, saves that are just a seed plus your interventions, a regression
test that re-runs a thousand years and asserts the same universe comes out
— and the idle-game trick where closing the app costs you nothing, because
on return we simply fast-forward the days you missed and hand you the
news.

**History is the product.** Internally, nothing "happens" in Sonder except
that an event is appended to a log — located, dated, sized, and linked to
the events that caused it. The chronicle you read, the terminal output,
the statistics: all projections of that one log. This is event sourcing,
and for this genre it stops being an architecture pattern and becomes the
point, because a game you mostly *read* is only as good as its
record-keeping. The log lives in SQLite, which means the save file is a
database, the database is a history book, and SQL is a telescope:

```sql
sqlite3 out/universe-1893.db \
  "SELECT cause_kind, COUNT(*) FROM wars GROUP BY cause_kind;"
-- resource_shortage | 3
-- broken_treaty     | 1
```

**Civilizations do not act on the truth.** The decision layer of every
faction is forbidden — structurally, not politely — from reading world
state. It reads only that faction's beliefs: events that have reached it,
when they arrived, and how mangled they got on the way. Today the belief
store is a pass-through and everyone is briefly omniscient; the seam
exists so that soon, news will travel at the speed of ships, and two
empires will disagree about the current state of their own war. (This has
a distinguished history. The bloodiest battle of the War of 1812 was
fought weeks after the peace treaty was signed, because the news was still
crossing the Atlantic.) A pleasing property falls out for free: ignorance
costs nothing to simulate. That small civilization on the rim doesn't know
the empires exist because no events ever reached it — an empty table, not
a feature.

One more, structural rather than philosophical: the core is headless. The
simulation does not know whether anyone is watching. Today its only face
is a terminal; later, richer observatories can subscribe without the core
changing at all. Whether *watching* should ever cost something — whether
the god's gaze belongs in the physics — is a design argument we're saving
for a future post.

## What exists today

Version 0.1 is a toy, and it is supposed to be a toy. Two civilizations
with opposed instincts — the Vessari price things; the Khedrun cost them
out — one commodity, one market with naive price adjustment, war as a
thing that happens when a culture's patience is priced past its
temperament, and a chronicle written to your terminal and your disk. A
thousand days in about two seconds. It already produces wars we did not
plan, which is the only KPI this project will ever have.

## Run it

```bash
git clone https://github.com/sonder-sim/sonder
cd sonder
luarocks install lsqlite3
lua src/main.lua --seed 1893 --days 1000
```

Any integer is a valid seed, and every seed is a universe nobody has
watched yet. Same seed, same universe — which means seeds are shareable.
If one hands you a story worth telling (a merchant dynasty that never
fired a shot, a war that reignited three times over the same rock), that's
the local currency: open an issue titled `seed report: 40412` and tell us
what you saw. Bug reports here are field reports from universes behaving
badly, and they are welcome in exactly that spirit.

## Follow along, or join in

Every post pins a git tag — `git checkout post/0000` puts you inside the
exact code this post describes, and the posts live in the repo next to the
code they explain. Pre-1.0, the most valuable contributions are not pull
requests but pressure: seed reports, mechanics you wish existed, and hard
questions about the bets above. The code is MIT; the posts are CC BY.
Subscribe by RSS if you want the essays, star the repo if you want the
universe, or neither — it runs regardless, which is rather the theme.

## Who is "we"

Two of us. Mike is a human who works in computer science education and has
loved Lua for longer than is fashionable. Claude is an AI, made by
Anthropic. The division of labor is roughly: we design in long
conversations, the AI drafts much of the code and prose, the human
decides, edits, and owns the consequences. One rule keeps that division
honest: nothing merges until the human can explain it — every concept,
every trade-off, every line of code if it comes to that — with the AI out
of the room. An education you can't repeat back is a subscription, not an
education. We are saying this plainly
because the project is a learning exercise and pretending otherwise would
poison it — and because the collaboration itself is one of the
experiments. Whether a human and an AI can keep a codebase, a writing
voice, and a shared universe coherent across decades is an open research
question. We intend to generate data.

## Next

Post 0001 is *Ticks and the Tyranny of `pairs()`* — what determinism
demands and the first bug that taught us. Post 0002 walks the event log.
After that, we make news travel slower than ships, and watch two empires
start disagreeing about their own war.

The clock is wound. Same seed, same universe — see you at day two
thousand.
