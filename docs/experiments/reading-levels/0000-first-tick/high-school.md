# First Tick

*Reading-level experiment · target: high school · rewritten from `docs/posts/0000-first-tick.md` · original untouched*

---

*Note: the original post was drafted before any code existed. Its chronicle excerpt, install steps, and line counts are aspirational until v0.1 ships.*

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

Nobody wrote that story. It fell out of a seed number, two invented cultures, one commodity market, and about eight hundred lines of Lua, in the two seconds it took to simulate a thousand days. Run the same seed and you get the same thousand days, down to the last hull. Change one digit and you get a universe nobody has ever seen.

More precisely: nobody wrote the *story*. We wrote the rules. Learning to be surprised by our own program — on purpose, repeatedly, for years — is more or less the entire project.

## What this is

Sonder is a universe you read. Many simulated civilizations, each with its own instincts and grudges, trade, scheme, and occasionally shoot at each other across a procedurally generated galaxy. You aren't a player in the usual sense; you're something between a god and a subscriber. The simulation runs whether or not you watch, and your rare interventions are recorded forever. Zoom out and empires collide; zoom in and you see the same war twice, once through each side's records — which do not agree, because in Sonder no civilization acts on the truth, only on what it *knows*.

There is no roadmap to 1.0 because there is no 1.0. We expect to work on this for decades, adding one mechanic at a time, and every mechanic ships with an essay — because a universe simulator makes CS concepts *necessary* instead of assigned. Priority queues show up because fleets need arrival times, graph algorithms because trade is a network, distributed-systems theory because light is slow and news travels on merchant ships.

## The four bets

We made four architectural decisions before writing much code. We expect to eventually regret at least one of them, in public.

**Lua.** An economy simulation is mostly bookkeeping — inventories, prices, treaties, grudges — and Lua's tables (its one flexible data structure, usable as both list and dictionary) are unreasonably good at bookkeeping. Its professional niche is exactly this: the rules-and-content layer of simulation-heavy games. There's also a criterion engineers pretend not to use — joy. One of us has loved this language for years, and on a decades-long project that's a load-bearing fact. Also, noticed only after deciding: *lua* is Portuguese for "moon."

**Determinism is the one non-negotiable law.** Determinism means: same inputs, same outputs, always. A seed (the starting number for the random number generator) plus a version of the code produces exactly one universe, on every machine. That takes discipline: no reading the real-world clock inside the simulation; a separately named random-number stream for each subsystem (so adding a market feature never shifts the war's dice rolls); and never looping over an unordered table where the order could change an outcome.

That last one humbled us within hours. Lua's `pairs()` function walks a table in whatever order it pleases — the language makes no promise — and our very first universe quietly refused to happen the same way twice. Same seed, different history. The fix, and the whole doctrine, is post 0001.

What determinism buys is almost everything we care about: perfect replays; save files that are just a seed plus your interventions; a regression test that re-runs a thousand years and asserts the same universe comes out; and the idle-game trick where closing the app costs nothing, because on return we fast-forward the days you missed and hand you the news.

**History is the product.** Internally, nothing "happens" in Sonder except that an event is appended to a log — dated, located, sized, and linked to the events that caused it. Everything you read is a projection of that one log. This pattern is called **event sourcing**: the event log is the true state, and every other view is computed from it. For a game you mostly *read*, it stops being an architecture pattern and becomes the point. The log lives in SQLite, so the save file is a database, the database is a history book, and SQL is a telescope:

```sql
sqlite3 out/universe-1893.db \
  "SELECT cause_kind, COUNT(*) FROM wars GROUP BY cause_kind;"
-- resource_shortage | 3
-- broken_treaty     | 1
```

That query asks the finished universe: "group the wars by what caused them, and count each kind." Answer: three wars over resource shortages, one over a broken treaty.

**Civilizations do not act on the truth.** Each faction's decision-making code is *structurally* forbidden from reading world state — not by convention, by design. It reads only that faction's beliefs: which events have reached it, when they arrived, and how mangled they got on the way. Today the belief store is a pass-through (everyone is briefly all-knowing), but the seam exists so that soon news will travel at the speed of ships, and two empires will disagree about the current state of their own war. This has real historical precedent: the bloodiest battle of the War of 1812 was fought weeks after the peace treaty was signed, because the news was still crossing the Atlantic. A pleasing property falls out for free — ignorance costs nothing to simulate. The small civilization on the rim doesn't know the empires exist because no events ever reached it: an empty table, not a feature.

One more, structural rather than philosophical: the core is headless — the simulation never knows whether anyone is watching. Today its only face is a terminal; later, richer viewers can subscribe without the core changing at all.

## What exists today, and how to run it

Version 0.1 is a toy, on purpose. Two civilizations with opposed instincts — the Vessari price things, the Khedrun cost them out — one commodity, one market with naive price adjustment, war when a culture's patience is priced past its temperament, and a chronicle written to your terminal and disk. A thousand days in about two seconds. It already produces wars we did not plan, which is the only success metric this project will ever have.

```bash
git clone https://github.com/sonder-sim/sonder
cd sonder
luarocks install lsqlite3
lua src/main.lua --seed 1893 --days 1000
```

Any integer is a valid seed, and every seed is a universe nobody has watched yet. Seeds are shareable — same seed, same universe — so if one hands you a story worth telling, open an issue titled `seed report: 40412`. Every post pins a git tag: `git checkout post/0000` puts you inside the exact code this post describes. The code is MIT-licensed; the posts are CC BY.

## Who is "we"

Two of us. Mike is a human who works in computer science education and has loved Lua for longer than is fashionable. Claude is an AI made by Anthropic. The AI drafts much of the code and prose; the human decides, edits, and owns the consequences. One rule keeps that honest: nothing merges until the human can explain it — every concept, every trade-off, every line if it comes to that — with the AI out of the room. An education you can't repeat back is a subscription, not an education. Whether a human and an AI can keep a codebase and a shared universe coherent across decades is an open research question. We intend to generate data.

## Next

Post 0001 is *Ticks and the Tyranny of `pairs()`* — what determinism demands and the first bug that taught us. Post 0002 walks the event log. After that, we make news travel slower than ships, and watch two empires start disagreeing about their own war.

The clock is wound. Same seed, same universe — see you at day two thousand.
