# First Tick

*Post 0000 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

---

On day 86 of universe number 1893, a hungry nation went to war. Here
is the universe's own record of it:

```
tick    0 · the-void · a universe begins (seed 1893)
      ⋮
tick   84 · khedrun-holds · hunger — the granaries came up 2 sacks short
tick   86 · khedrun-holds · the khedrun declare war on the vessari — 4 hungry days were the last insult
tick   87 · vessar-reaches · a khedrun war party rides against the vessari granaries (force 8)
tick   96 · khedrun-holds · the khedrun sheathe — grain at 79¢ buys more than blood
tick  100 · the-exchange · 12 sacks pass from the vessari to the khedrun at 84¢
```

Read it top to bottom: a universe begins, a people go hungry, they
declare war, they raid their neighbors' granaries, and ten days later
— once grain is cheap enough to buy again — they put their spears away
and go back to shopping.

Nobody wrote that war. There is no script with day 86 in it. There
are about two thousand lines of code describing two personalities, one
grain market, and the weather — and when the computer plays out a
thousand days, twenty wars break out on their own. Run it again and
you get the exact same thousand days, down to the last sack of grain.
Change the starting number — the *seed* — by one digit and you get a
completely different universe nobody has ever seen.

That's the whole trick, and this project — called **Sonder** — is
about seeing how far it can go.

## What this is

Sonder is a universe you read, not a game you play. Simulated
civilizations trade, scheme, and fight across a galaxy, whether or not
anyone is watching. Your role is somewhere between a god and a
subscriber: history piles up on its own, and you read it like a
newspaper from a world that doesn't exist.

Two ideas make it special. First, everything is *repeatable*: the same
seed always produces the same universe, so you can share a universe
with a friend by sharing one number. Second, no civilization in
Sonder ever acts on the truth. Each one acts only on the news that has
reached it — and someday soon, news will travel slowly, on ships, and
two nations will genuinely disagree about how their own war is going.
(Real history works this way too: the bloodiest battle of the War of
1812 was fought *after* the peace treaty was signed, because the news
was still crossing the ocean.)

There's no finish line and no deadline. We expect to build this for
decades, one small piece at a time.

## Why we're doing it

The learning is the product. Every piece of the simulator ships with
an essay explaining how it works and the computer science behind it —
and every essay comes in two versions, the full one and the one you're
reading now. We build this way because a universe simulator makes
computer science ideas *necessary* instead of assigned: we needed a
tamper-proof diary, so we learned about event logs; we needed two
computers to agree they'd computed the same history, so we learned
about hash functions. Nothing is taught in the abstract. The universe
demands it first.

There's a quieter reason too. Most big systems, you only ever meet
when they're already grown — nobody can tell you why anything is the
way it is. Sonder is being built in public from its very first tick,
and every essay is pinned to the exact version of the code it
describes. Anyone can rewind to any moment and look around.

## What exists today

Version 0.1 is deliberately a toy: two small civilizations — the
Vessari, farmers who sell their surplus, and the Khedrun, hill clans
who buy what they can and take what they can't — one grain market, and
wars that start when hunger outruns patience. Every run writes a
history file you can question afterward: ask it *why* the war
happened, and it answers with the chain of causes, all the way back to
the hungry days that lit the fuse. Under the hood sit the pieces the
first nine essays explain: a perfectly repeatable clock, a diary that
only ever adds pages, a tamper seal on history, and the wall that
keeps every nation acting on beliefs instead of truth. A thousand days
takes about an eighth of a second.

## What we got wrong

Here's the fun part. The first version of this essay was written
*before any code existed*, as a dream of where the project would go.
Now the universe actually runs, and we can grade the dream:

- **We predicted the wrong first bug.** The draft claimed a specific
  famous trap had already bitten us. It never did — our first real bug
  was a test that was wrong about what it was checking.
- **The dream got every detail wrong and every name right.** The
  draft imagined a gas called heliox, a merchant cartel, and a war
  vote. Reality kept the two nations' names — Vessari and Khedrun —
  and swapped everything else: the goods became grain, the vote became
  hunger, and the imagined day-231 war actually arrived on day 86.
- **Reality was bigger and faster than we guessed.** We promised 800
  lines of code and a two-second run. It took 1,970 lines — and runs
  sixteen times faster than we promised.
- **The old install instructions were fiction.** The real ones exist
  now, and we tested them the honest way: we built this very version
  from scratch, in one command, before publishing them.

## Try it

If you're comfortable with a terminal, the complete essay has the full
instructions — three commands to a running universe. Any whole number
is a valid seed, and every seed is a universe nobody has watched yet.
If yours produces a story worth telling, tell us the number. That's
the local currency here.

The clock is wound. Same seed, same universe — see you at day two
thousand.
