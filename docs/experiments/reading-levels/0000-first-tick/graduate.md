# First Tick

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0000-first-tick.md` · original untouched*

---

*Draft caveat carried over from the original: written before any code existed; the chronicle excerpt, install steps, and line counts are aspirational until v0.1 ships.*

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

Emergent narrative from a seeded, deterministic simulation: two cultures with opposed utility functions, one commodity market, ~800 lines of Lua, 1,000 simulated days in ~2 seconds. The run is a pure function of the seed (here, 1893): replay it and every hull is lost on the same day; perturb one digit and you get an unexplored universe. We authored the transition rules, not the trajectory — engineering the capacity to be surprised by our own program, repeatedly and on purpose, is the project.

## What this is

Sonder is a universe you read: many simulated civilizations trading, scheming, and warring across a procedurally generated galaxy, observed by something between a god and a subscriber. The core runs regardless of observation; player interventions are rare, explicit inputs, permanently recorded. The intended end state is multi-scale: empires colliding at the widest zoom, and at closer zoom the same war rendered twice through two factions' mutually inconsistent records — inconsistent by construction, because no agent reads ground truth. There is no 1.0 and no roadmap; the horizon is decades, one mechanic at a time.

The pedagogy is the co-equal product. Every mechanic ships with an essay covering the design and the CS it forced: priority queues arrive with fleet ETAs, graph algorithms with trade networks, distributed-systems theory with finite information propagation speed (news travels on merchant ships). Nothing is taught in the abstract. A secondary motive: most complex systems are encountered full-grown, with no record of why any street goes where it goes. Sonder is built in public from tick zero, each post pinned to the exact commit it describes — an experiment in whether a system can stay legible for its entire life.

## The four bets

Made before writing much code; we expect to publicly regret at least one.

**Lua.** An economy simulator is dominated by bookkeeping — inventories, prices, treaties, grudges — and Lua tables are unreasonably good at it: a small language composing simple structures into complicated ones, which also describes the modeled universe. Its professional pedigree is precisely the rules-and-content layer of simulation-heavy games. And one criterion engineers pretend not to weight: joy. One of us has loved the language for years; on a decades-scale project that is load-bearing. (Noticed post-decision, kept anyway: *lua* is Portuguese for "moon.")

**Determinism as the single non-negotiable invariant.** `(code version, seed)` defines exactly one universe, bit-for-bit, cross-machine. Mechanically: no wall-clock reads inside the sim; per-subsystem named PRNG streams (`rng.market`, `rng.war`, …) so a new feature never shifts another subsystem's draw sequence; and no iteration over hash tables anywhere ordering can affect an outcome — Lua's `pairs()` order is unspecified, and it humbled us within hours: our first universe quietly failed to replay identically. The fix and the doctrine are post 0001. The payoff is nearly everything downstream: exact replay; saves reduced to seed + intervention log; a golden-master regression test that re-runs a thousand years and asserts bit-identical output; and free idle-game semantics — on return, fast-forward the missed days and present the news.

**History is the product (event sourcing).** Nothing "happens" except an append to the event log; each event is dated, located, sized, and cause-linked to its antecedent event ids. Chronicle text, terminal output, statistics — all projections over that single log. For a game whose primary verb is *read*, event sourcing stops being an architecture pattern and becomes the point: the product is only as good as its record-keeping. The log persists in SQLite, so the save file is a database and SQL is a telescope:

```sql
sqlite3 out/universe-1893.db \
  "SELECT cause_kind, COUNT(*) FROM wars GROUP BY cause_kind;"
-- resource_shortage | 3
-- broken_treaty     | 1
```

**Agents act on beliefs, never truth.** Each faction's decision layer is structurally — not conventionally — barred from reading world state; it reads only that faction's belief store: which events arrived, when, and how degraded in transit. v0.1 ships a pass-through store (transient omniscience), but the seam exists so news can later propagate at ship speed and two empires can disagree about the live state of their own war. Historical precedent: the bloodiest battle of the War of 1812 was fought weeks after the peace treaty was signed, the news still mid-Atlantic. A property falls out for free: ignorance is O(0) — the rim civilization that has never heard of either empire has an empty belief table, not a modeled feature. Its chronicle this year: a good harvest and some troubling lights in the sky.

A fifth, structural bet: the core is headless. The simulation carries no knowledge of observers; today's terminal chronicle and any future observatory are subscribers, and the core does not change when they do. Whether observation should ever have in-universe cost — whether the god's gaze belongs in the physics — is deferred to a future post.

## v0.1, deliberately a toy

Two civilizations with opposed proclivities (the Vessari price things; the Khedrun cost them out), one commodity, one market with naive price adjustment, war triggered when a culture's patience is priced past its temperament, chronicle to terminal and disk. A thousand days in ~2 seconds. It already produces unplanned wars — the only KPI this project will ever have.

```bash
git clone https://github.com/sonder-sim/sonder
cd sonder
luarocks install lsqlite3
lua src/main.lua --seed 1893 --days 1000
```

Any integer is a valid seed; determinism makes seeds shareable artifacts. The requested contribution currency pre-1.0 is pressure, not pull requests: seed reports (`seed report: 40412`), mechanics you wish existed, hard questions about the bets. Bug reports are field reports from universes behaving badly. Every post pins a tag — `git checkout post/0000` reproduces this post's exact code. MIT for code, CC BY for posts.

## Who is "we"

Two: Mike, a human in CS education with a long-standing Lua attachment, and Claude, an AI made by Anthropic. Division of labor: joint design in long conversations; the AI drafts most code and prose; the human decides, edits, and owns consequences. The honesty invariant: nothing merges until the human can explain it — every concept, trade-off, and line — with the AI out of the room. An education you can't repeat back is a subscription. The collaboration is itself one of the experiments: whether a human and an AI can keep a codebase, a voice, and a shared universe coherent across decades is an open question, and we intend to generate data.

## Next

Post 0001: *Ticks and the Tyranny of `pairs()`* — the determinism doctrine and the first bug that taught it. Post 0002 walks the event log. Then news gets slower than ships, and two empires begin disagreeing about their own war.

The clock is wound. Same seed, same universe — see you at day two thousand.
