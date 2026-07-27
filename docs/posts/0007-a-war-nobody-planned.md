# A War Nobody Planned

*Post 0007 · code pinned at tag `post/0007` · Lua 5.4 + SQLite ·
this post's universe: seed `1893` · ~12 min read*

---

```
$ ./lua src/main.lua --seed 1893 --ticks 1000 | sed -n '/tick   84 /,/tick   88 /p'
tick   84 · khedrun-holds · the day's books: 0 sacks in the granary (+8, −8), 40¢ in the treasury
tick   84 · khedrun-holds · hunger — the granaries came up 2 sacks short
tick   85 · khedrun-holds · the day's books: 0 sacks in the granary (+6, −6), 40¢ in the treasury
tick   85 · khedrun-holds · hunger — the granaries came up 4 sacks short
tick   86 · khedrun-holds · the day's books: 0 sacks in the granary (+7, −7), 40¢ in the treasury
tick   86 · khedrun-holds · hunger — the granaries came up 3 sacks short
tick   86 · khedrun-holds · the khedrun declare war on the vessari — 4 hungry days were the last insult
tick   87 · vessar-reaches · a khedrun war party rides against the vessari granaries (force 8)
tick   88 · vessar-reaches · the khedrun raiders carry off 8 sacks and 400¢ from the vessari and put 4 to the torch
      ⋮
tick   96 · khedrun-holds · the khedrun sheathe — grain at 79¢ buys more than blood

$ sqlite3 out/universe-*.db "SELECT count(*), min(tick), max(tick) FROM annals WHERE kind='war.declared'"
20|86|971

$ sqlite3 out/universe-*.db "SELECT sum(json_extract(payload,'$.seized')),
      sum(json_extract(payload,'$.plunder')), sum(json_extract(payload,'$.burned'))
      FROM annals WHERE kind='war.spoils'"
1569|78450|746
```

Look at the treasury on day 84: forty cents. The Khedrun have been
broke for two weeks — you can watch it coming in the feed, the bids
shrinking, then stopping, then the granary draining ten sacks a day
— and on day 86, after four hungry days, they do the thing their
culture does instead of starving quietly. The war lasts ten days.
The raiders carry off grain and silver and burn what they can't
carry. Then grain is 79¢, the granaries hold 48 sacks, and the horde
goes home.

Nobody wrote that war. There is no line of code that schedules a
war, no script with day 86 in it, no quest table. There are two
temperaments, a market between them, and weather in the harvests —
and when we ran a thousand days of seed 1893, twenty wars
precipitated out, the first at day 86 and the last at day 971, every
date set by nothing but arithmetic and luck. The card that built
this had one acceptance criterion, which the board calls the only
KPI this project will ever have: *a thousand days produce a
chronicle worth reading — and ideally a war nobody planned.* This
post is about what it took.

## The cast: temperament as constants

The placeholder market and war office are gone — drift and muster
churned out of the vocabulary exactly as every post since 0002
promised they would. In their place, vocabulary v2: eleven kinds of
event, two civilizations, one commodity, one exchange.

**The Vessari price things.** Terraced valleys, ten to fourteen
sacks a day, appetite for eight. They sell their surplus — but never
below their fifty-sack reserve, never more than twelve sacks a day,
always undercutting the posted price by two, and *never below 80¢*.
Below the floor, a Vessari factor closes the ledger and waits for
the market to remember what grain is worth.

**The Khedrun cost them out.** High stony holds, six to eight sacks
a day, appetite for ten. The gap is the whole of their history, and
it closes at the exchange when there is silver and at spearpoint
when there is not. Their patience is an instrument with real
graduations: grain above 150¢ for seven markets running is an
insult; four hungry days inside a week is a deeper one. Either fuse
burns and the war parties ride — six to twelve to a band, a sack per
raider, fifty cents of silver per spear, and some of what they can't
carry put to the torch. Ten days and the horde goes home, weary,
regardless.

Every one of those numbers is a constant in `src/worlds/toy.lua`,
and every constant is a temperament in disguise. That's the whole
authoring model of the toy world: you don't write history, you write
*dispositions*, and history is what the dispositions do to each
other under weather.

## Minds are projections too

The load-bearing design decision: **the civilizations are
stateless.** No patience counter ticks up between days. No cached
granary total. Each morning, a civ's decide function is handed its
belief store and reconstructs its entire mind from scratch — what it
holds (the last self-reported tally plus believed trades and raids
since), whether it is at war (the latest believed declaration versus
the latest believed peace), how insulted it feels (recent believed
prices, recent believed hungers, counting only insults since the
last peace, because old grudges were settled by the old war).

Law 2 said every state view is a projection of the event log. This
card extends that into the agents' heads: a civ's mental state *is*
a projection of its belief store, recomputable, inspectable,
identical on every machine. And the belief store is fed by the
courier, which means when card 122 slows the news down, it won't
just delay reactions — it will change what the minds themselves
contain. Two civilizations will reconstruct different mental states
from the same war because the events reached them in different
orders. The mechanism shipped this card; only the delay is missing.

Physics went the other way, on purpose: the exchange and the
battlefield are systems, entitled to truth, and they draw **no
random numbers at all**. The exchange folds a ledger from the annals
(a cursor, caught up after every emit, so nothing in a tick can act
on books that don't include its own consequences), clears
yesterday's orders where willing prices cross, clamps every trade to
what the buyer can pay and the seller actually holds, and moves the
posted price toward the unfilled imbalance — at most 4¢ a day. The
battlefield resolves yesterday's raids against the granaries as they
actually are: the raider rides on beliefs, and finds out what they
got when physics pays out on truth. All the chance in this universe
lives in decisions and harvests; everything that *adjudicates* is
deterministic bookkeeping.

## Money circulates through violence

The first economy we built had a one-way heart, and it killed the
patient. Purchases drain the Khedrun treasury toward the Vessari
forever; nothing brings coin back; the Khedrun go broke around day
35 and then — in the first draft — starve *quietly*, because the
only war trigger was high prices, and a civilization too poor to bid
leaves prices on the floor. A thousand days of a rich merchant
republic and a silent famine next door. Not a chronicle worth
reading.

Two mechanics fixed it, and both turned out to be the card's
epigraph wearing engineering clothes. **Hunger insults too**: being
unable to afford grain at any price is still being priced out, so
empty bellies burn a fuse of their own — a broke Khedrun goes to war
instead of starving politely. And **raids carry silver as well as
sacks**: fifty cents of plunder per point of force, which means war
is how money flows back the other way. The thousand-day cycle that
emerges: the treasury drains through honest trade → poverty → the
granary drains → hunger → war → plunder carries grain and coin home
→ peace → trade resumes with stolen silver → the treasury drains.
Twenty wars, roughly forty-five days apart, dates jittered by
harvest luck. The Vessari books, read closely, say the quiet part:
the wars are how their customers refinance.

(Burning earns its law citation: total matter is conserved *unless
explicitly mined or burned*, and `war.spoils` carries a `burned`
count precisely so the audit can watch matter leave the world
through a door with a sign on it. It's also why the Vessari hoard
can't grow forever, and why a long war leaves real scarcity behind
it.)

## Tuning: four regimes before it lived

Emergence isn't free. The notebook keeps the full journal; the
summary is that the same eleven kinds and two temperaments produced
four completely different worlds as the constants moved:

1. **The free-fall.** Vessari surplus swamped Khedrun demand; the
   price fell 4¢ a day forever; the Khedrun starved silently. Fixed
   by the merchant floor, thinner harvests, and the hunger fuse.
2. **The strobe.** 184 wars, one every five days, each lasting one
   day. Two bugs (next section), but also a peace condition that
   ended hunger wars the moment grain was cheap — and grain is
   *always* cheap to people with no money. Relief now ends only the
   wars that prices started.
3. **The inferno.** Burning at full force made war profitable at
   civilization scale: fifty wars, the Vessari ground to four sacks
   and 0¢, the Khedrun holding every coin in the world. Softer
   torches, harder fuses, shorter wars.
4. **The cycle.** The one you read above.

The craft lesson we didn't expect: **we diagnosed every regime by
reading the chronicle, not the specs.** The specs held (conservation
never broke, determinism never broke) while the *world* was wrong in
four different ways. A readable feed turns out to be an instrument —
the project's oldest claim about itself, tested for the first time.

## The CS underneath: growing societies, groping prices

The toy world is a tiny **agent-based model**, and it's in
distinguished company. Schelling's segregation model (1971) showed
neighborhoods self-segregating out of mild individual preferences —
macro-patterns nobody chose. Epstein and Axtell's *Sugarscape*
(1996) grew trade, migration, wealth inequality, and — yes — combat
from agents with metabolisms walking a grid of sugar. Their phrase
for the method is the thesis of this whole project: *generative*
social science — if you didn't grow it, you didn't explain it. Our
KPI is Sugarscape's move restated: don't script the war; create
conditions where wars are *possible* and let one precipitate. The
difference is that Sonder keeps the annals: our emergence comes with
a complete causal paper trail, down to the four hunger events every
declaration cites.

The exchange's price rule — nudge the posted price toward unfilled
imbalance — is a crude **tâtonnement**, Walras's 1874 picture of an
auctioneer "groping" toward the price that clears the market. Real
tâtonnement is a convergence process; ours never converges, because
the world keeps kicking it (harvest noise, war shutting off bids),
and that's the feature. A price that settled forever would be a dead
chronicle.

And the war cycle itself has a name in dynamics: a **relaxation
oscillator** — slow charge, fast discharge, like a dripping faucet
or a neuron. The treasury and granary drain slowly (charge), the
hunger fuse trips (threshold), the war discharges the tension in ten
violent days (plunder resets the state), and the cycle re-arms. The
period isn't in any constant: ~45 days is a *derived* quantity,
emergent from appetite minus harvest, plunder rate, and how fast
trade re-drains the treasury. Change any constant and the rhythm of
history changes — which is exactly what tuning felt like from
inside.

## What we got wrong

**The best bug of the project so far: the plunder moved in truth
but not in belief.** The battle system paid the raiders in the
ledger — and `believed_books` only moved grain, so no tally ever
recorded the silver. The Khedrun never *believed* they'd been paid;
the Vessari never *noticed* they'd been robbed; the strobe regime
was both civilizations acting rationally on wrong minds. Savor the
irony: card 117 built the wall between belief and truth, and the
very next card shipped the first bug that *lives in the gap* — a
bug that was inexpressible before law 3 was structural. The fix was
one line; the regression net is not: `toyworld_spec` now folds the
entire annals into an independent audit, and every self-reported
tally must match it, cent for cent, sack for sack. With a
pass-through courier, belief that drifts from truth is a bug. (When
card 122 slows the news, that same drift becomes the *product*. The
audit will need to learn the difference — we left it a comment.)

**The gremlin got lucky for two days.** Card 116's perturbation
spec, re-aimed at the new world, failed its own divergence assert:
the stolen Vessari draw happened to deal identical harvests two days
running, and history didn't fork until day 252. The spec now pins
the coincidence on purpose, because it teaches the seal's honest
contract: it detects *divergence*, not tampering. A perturbation
that changes no event hasn't happened — by law 2, quite literally.

**The price fuse has never fired.** All twenty wars in the
acceptance run are hunger wars; peacetime prices oscillate 78–101¢,
nowhere near the 150¢ temperament. The mechanism is real and
spec-exercised, and we are saying plainly that no seed we've met has
ever used it, rather than quietly tuning the threshold down until
one did. It's a mechanism waiting for a world where scarcity bites
harder.

**And the org chart bent under the card.** Toyworld started life in
`src/sonder/` next to the laws, and Mike caught it in review: not
engine, not test — *content*. It lives in `src/worlds/` now, and the
question "what is a world, actually?" produced the card's best
answer: the lore shelf is an *expressibility* eval (authored story
leads, the engine must host it), the toy world is an *emergence*
eval (temperaments lead, history must precipitate), and a world file
is lore compiled to constants and decide functions. The Vessari and
Khedrun joined the lore shelf with provenance notes admitting they
were written engine-first — the shelf's first "hosted" checkmarks,
and the first lore written *from* a world instead of toward one.

## Next

Card 119 cuts **v0.1** — the walking skeleton, complete: ticks,
events, lore, the durable annals, the seal, the seam, and a world
where wars precipitate out of grain prices. Post 0000, written
before any code existed, finally gets its excerpt from a universe
that runs.

Seed 1893, day 86. Four hungry days were the last insult. Ask the
file why — it can cite them.
