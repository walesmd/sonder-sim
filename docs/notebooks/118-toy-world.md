# Notebook — 118-toy-world

Card 118: *Toy world: two civilizations, one commodity, one market.*
The Vessari price things; the Khedrun cost them out. One commodity,
one market with naive price adjustment, money in integer cents,
events (and only events) all the way down. War happens when a
culture's patience is priced past its temperament. Done when: a
thousand days produce a chronicle worth reading — and ideally a war
nobody planned, the only KPI this project will ever have.

## Session 1 (2026-07-26)

### What's already decided (inherited, not ours to relitigate)

- Everything from cards 113–117 is load-bearing here and unchanged:
  named streams, the strict annals, projections, the archive, the
  seal, and the belief seam. This card is the first *customer* of
  all of it at once.
- Law 1: money in integer cents, matter in discrete units (sacks).
  No floats anywhere near a treasury.
- The civs are **factions** (they can be wrong about things); the
  market mechanism and battle resolution are **systems** (physics,
  entitled to truth). Law 3 decides the split, not taste.
- Pre-0.1 vocabulary churn is free — this is the churn the last
  four posts kept promising. The golden ledger gets its third entry.
- Scope fences: **120** owns the double-entry audit (this card keeps
  conservation true and writes one invariant spec, but the real
  audit tooling is 120's); **122** owns slow news (couriers stay
  pass-through); **125** owns geography (locations stay strings);
  **132** owns time/tempo (a tick is a day here, by fiat, revisable).

### The design space (drafted; decisions marked, all awaiting Mike's
### interrogation)

**1. The cast.** The card names them: the **Vessari** (mercantile —
they price things) and the **Khedrun** (martial — they cost them
out). Toy civs, not lore-shelf species: the shelf is an eval suite
for the real thirty; these two are the engine's crash-test dummies,
with just enough temperament to generate history. Locations are
free strings until geography: `vessar-reaches`, `khedrun-holds`,
and the market at `the-exchange`. The commodity is **grain**, in
sacks.

**2. The economic loop, one day long.** Each day: civs tally (
harvest with variance, eat, report stock), then trade — the Khedrun
run a structural deficit (eat 10, harvest ~7) and must buy; the
Vessari run a surplus (harvest ~14, eat 8) and sell. Orders go to
the exchange as events; the market system clears them the next day
(systems run before factions, so a day-T order meets the market on
day T+1 — order latency for free); unfilled imbalance moves the
price, naively: `delta = clamp((bids − offers) ÷ 2, −4, +4)` cents.
Scarcity (a bad harvest streak) → unfilled bids → price climbs.
Glut → unfilled offers → price falls. That single feedback loop is
the whole economy.

**3. Statelessness: a faction's mind is a projection of its
beliefs.** The design jewel of the card. Neither civ keeps internal
state between days — no patience counter, no cached stock. Stock is
read off the latest believed `grain.tally` plus believed
trades/spoils since; patience is counted off recent believed
`market.price` events; war-or-peace is the latest believed
declaration vs peace. Law 2 said all state views are projections of
events; this card extends it into the agents' *minds* — a civ's
entire mental state is recomputable from its belief store. (This is
also what makes card 122 devastating later, in the good way: slow
news doesn't just delay reactions, it changes what the mind *is*.)
Belief store grows one query to make this cheap: `recent(kind, n)`.

**4. What can happen — vocabulary v2** (schema_version 2; drift and
muster churn away, eleven kinds arrive):

| kind | emitter | payload |
|---|---|---|
| `universe.genesis` | universe | seed |
| `civ.founded` | setup | name, grain, cents |
| `grain.tally` | civ | harvested, eaten, stock |
| `grain.hunger` | civ | shortfall |
| `market.order` | civ | side, units, limit |
| `market.trade` | market | buyer, seller, units, price, total |
| `market.price` | market | price, delta |
| `war.declared` | Khedrun | aggressor, target, price |
| `war.raid` | Khedrun | raider, target, force |
| `war.spoils` | battle | seized |
| `war.peace` | Khedrun | price |

Founding events exist so endowments are on the record — card 120's
audit needs an anchor event, not config archaeology. The opening
price (100¢) is posted at tick 0, citing genesis, so every civ's
first day has a price belief to act on.

**5. War, mechanically.** The Khedrun temperament is a threshold
(130¢) and a fuse (5 consecutive believed prices above it). Burn the
fuse → `war.declared`. At war, they stop bidding and raid instead
(force drawn from their own stream); the battle system resolves each
raid against the defender's *actual* granary next day (`war.spoils`
— the raider finds out what they got, which is not what they
planned, because they planned on beliefs). Peace when the believed
price falls to 110¢ or their granaries are comfortable again. The
hoped-for emergent loop: bad harvests → price spike → patience burns
→ war → raids empty Vessari granaries → Khedrun sated, stop bidding
→ price collapses → peace → deficit resumes → the cycle turns. No
line of code schedules a war; wars precipitate out of weather.

**6. Physics keeps the books.** The market system maintains a ledger
projection (treasuries, granaries — folded from founding, trades,
spoils, tallies) and enforces what factions can't be trusted to:
you can't buy grain with cents you don't have, can't sell sacks you
don't hold, can't loot a granary past empty. Trades clamp to the
binding constraint. Conservation is a spec from day one: every cent
a buyer loses, a seller gains; every sack is founded, harvested,
eaten, traded, or seized — never conjured. (The full double-entry
audit tooling is card 120; the invariant is not allowed to wait.)
The ledger lives in system closures with a cursor — deterministic
because it folds the annals, noted honestly as cache-not-truth.

**7. Where the toy world lives.** `src/sonder/toyworld.lua` — it's
content, not engine, but it's *the* demo world main.lua runs and the
world every golden test seals, so it graduates out of tests/support
(which now just re-exports it). Card 125's procedural galaxy will
make worlds plural; one hardcoded world module is honest today.

**8. The KPI is a reading assignment.** "A thousand days produce a
chronicle worth reading" — so the acceptance run is literal: run
seed 1893 for 1000 days, read the feed, look for a war nobody
planned. Tuning constants (harvests, temperament, fuse, price step)
is empirical and happens against that run, in this notebook, on the
record.

### What we built

- **Vocabulary v2** (schema_version 2): drift and muster churned
  away; eleven kinds arrived — genesis, `civ.founded`, `civ.tally`
  (the daily books: granary AND treasury — the tally grew a cents
  column when it became clear a civ's money is as much its state as
  its grain), `grain.hunger`, `market.order`, `market.trade`,
  `market.price`, `war.declared` (reason: price | hunger),
  `war.raid`, `war.spoils` (seized + plunder + **burned** — burning
  is the one lawful exit for matter, permitted because the event
  records it), `war.peace`.
- **`src/sonder/toyworld.lua`** — the world module: two stateless
  decide functions (a civ's whole mind recomputed from beliefs daily
  — stock, treasury, war status, patience, all projections), and two
  deterministic physics systems sharing a folded ledger (the
  exchange clears yesterday's orders, adjusts price by unfilled
  imbalance, caps trades at what buyers hold and sellers have; the
  battlefield resolves yesterday's raids against actual granaries).
  Physics draws no random numbers at all — chance lives only in
  civ decisions.
- **Belief store** grew `recent(kind, n)` — minds run on recent
  memory, and recalling all history to look at the end of it would
  price statelessness out of reach.
- **The Khedrun's two fuses**: five believed prices above 150¢
  (grain too dear), or four hungry days in a week (grain
  unaffordable — being unable to buy is also being priced out, and
  it's why a broke Khedrun goes to war instead of quietly starving).
  Both count only insults since the last peace: old grudges were
  settled by the old war. Peace: relief-price ends a price war only
  (a hunger war began with prices low), full granaries end either,
  and a weary horde goes home after 10 days regardless.
- **Money circulates through violence, by design**: purchases drain
  the Khedrun treasury Vessari-ward; plunder (50¢ per point of
  force) carries it back. The card's epigraph, mechanized: the
  Vessari price things; the Khedrun cost them out.
- Specs: `toyworld_spec` (the independent audit folding the whole
  annals — every tally must match it, every cent founded/traded/
  plundered, grain never negative, trade total = units × price; war
  discipline — raids only in wartime, no wartime bids, declarations
  cite their insults; the KPI as an executable claim), plus rewrites
  across annals/chronicle/faction/universe/archive/seal specs for
  v2. Suite: 110 green, twice.
- Golden ledger, third entry: `ea60291970dba95b` (1,589 events at
  500 ticks). Chronicle golden feed re-cut to the toy world's first
  two days.

### The tuning journal (post material, all of it)

Four regimes before the world lived, each diagnosed from the
chronicle itself:

1. **The free-fall.** First run: price −4/day forever, no wars ever.
   Vessari surplus (offer 20/day) swamped Khedrun demand (~4), and
   the Khedrun bled coin until they couldn't buy at any price —
   then starved *quietly*, because the only war trigger was high
   prices and prices were on the floor. Fixes: the merchant floor
   (Vessari won't sell below 80¢ — no dumping), thinner harvests,
   and the hunger fuse.
2. **The strobe.** War every 5 days, 184 of them. Two causes: peace
   fired the day after a hunger declaration (grain at 79¢ ≤ relief
   110¢ — but cheap grain means nothing to a war that hunger
   started; relief now ends price wars only), and — the best bug of
   the card — **the plunder never reached anyone's beliefs**. The
   battle system moved the cents in truth; `believed_books` only
   moved grain; so the Khedrun never believed they'd been paid and
   the Vessari never noticed they'd been robbed. The independent
   audit spec exists precisely so this class of bug can never ship
   again: every self-reported tally must equal the fold.
3. **The inferno.** Burning at one sack per point of force turned
   war profitable at civilization scale: 50 wars, 48 price-flavored,
   the Vessari ground to 4 sacks and 0¢, the Khedrun holding all
   24,000¢. Overcorrection: harder fuses (150¢ × 7 days; 4 hungry
   days), shorter wars (weariness 10), half-force burning, deeper
   Vessari buffers.
4. **The cycle.** ~20 wars per thousand days, ~45-day rhythm: the
   Khedrun treasury drains through honest trade → poverty → empty
   granaries → hunger → war → raids carry grain and coin back →
   peace → trade resumes with plundered coin. Money circulates;
   nobody schedules anything; harvest noise moves the dates.

### What broke / what surprised us (more post material)

- **The gremlin got lucky for two days.** The re-aimed perturbation
  spec (steal a Vessari draw at tick 250) failed its own
  divergence assert: the shifted stream happened to deal identical
  harvests at 250 *and* 251 — a 1-in-25 coincidence, deterministic
  for this seed — and history didn't fork until 252. The spec now
  pins the two lucky days on purpose: the seal detects *divergence*,
  not tampering; a perturbation that changes no event hasn't
  happened, by law 2.
- **Post 0005's two-bug prophecy, called in properly this time.**
  The plunder-belief bug and the relief-peace bug were both real,
  both shipped-in-the-first-draft, both found by reading the
  chronicle rather than by specs. The suspicion mechanism works;
  the audit spec turns one of them into a permanent regression net.
- **All 20 of seed 1893's wars are hunger wars.** The price fuse is
  real, spec-exercised, and never fires in the acceptance run —
  peacetime prices oscillate 78–101¢, nowhere near 150¢. Honest
  status: the price war is a mechanism awaiting a world where
  scarcity bites harder (or a seed we haven't met). On the record
  rather than tuned into existence.

### The acceptance reading (the KPI)

Seed 1893, 1000 days, 3,142 events, ~3,100 chronicle lines. Shape:
an opening act of pure commerce (days 1–85, price discovering its
way down from 100¢ as the rich Khedrun buy freely); first hunger war
at day 86 (the treasury ran dry two weeks earlier — the chronicle
shows the bids shrinking, then stopping, then the granary draining,
then three hunger lines, then the declaration); the war arc reads
cleanly (raids with force, spoils with torch counts, books visibly
bleeding); peace at day 96 ("grain at 79¢ buys more than blood");
then the cycle turns — 20 wars, none scheduled, dates set by harvest
luck. War 1 verified caused-all-the-way-down: declaration cites
three hunger events, hungers cite the tally chain, tallies chain to
founding, founding to genesis. A war nobody planned, with
provenance. KPI: met.

### Round 2 — Mike's review: where does a world live?

Mike questioned `src/sonder/toyworld.lua`: not engine, not
world-building, "almost a test" — and said out loud that the project
has reached the point of needing to organize its own files. The
discussion that followed produced the card's best conceptual result.

- **What a world file is:** none of the existing categories. Not
  engine (enforces no law), not a test (tests assert; worlds
  define), more than a fixture (main.lua runs it; the golden master
  seals it; v0.1 ships it). It's **content** — the first world the
  engine hosts.
- **Decision (Mike): `src/worlds/toy.lua`** — a content namespace
  beside the engine. The engine is `sonder/`; worlds are what it
  hosts; the directory boundary is the engine/content line. Card
  125's generated worlds get an obvious home.
- **Mike's sharper question:** are worlds a historic presentation of
  the lore — an eval establishing a minimum bar? Answer (agreed):
  **there are two evals.** The lore shelf's is *expressibility* —
  authored story leads, the engine must be able to host it (floor).
  The toy world's KPI is *emergence* — given temperaments and no
  script, history worth reading must precipitate. The Vessari and
  Khedrun were built engine-first (opposite of the shelf's
  direction), but what they are is lore-shaped: a world file is
  temperament compiled to constants and decide functions. The
  project's full trajectory: `docs/lore/` (authored priors) →
  `src/worlds/` (executable temperaments) → the annals (emergent
  history, nobody's draft).
- **Decision (Mike): the toy cast joins the lore shelf** —
  `the-vessari.md` and `the-khedrun.md`, written honestly as what
  they are (engine-first, constants restated as a people, provenance
  note saying so). The shelf's first "hosted since card 118"
  checkmarks: from now on, worlds cite their lore and lore knows
  whether a world hosts it yet.
- **Flagged, not fixed (recorded debt for card 125's era):** the
  event vocabulary is now mostly *content* (only genesis is truly
  the engine's), and chronicle templates are content-coupled the
  same way. Eventually worlds contribute kinds and sentence packs;
  that's real design work with schema-version implications, not a
  file move.
- Docs-sweep item: `docs/lore/README.md` describes the shelf as
  fiction-first — true of its founding residents, now with two
  engine-first exceptions that carry their own provenance notes.
  One sentence in the README should acknowledge the second
  direction exists.

## Session 2 (2026-07-26, same day) — the post and the sweep

Implementation committed (1bf3106) on Mike's word after the
interrogation rounds. Drafted
`docs/posts/0007-a-war-nobody-planned.md`. Shape: the day-84-to-96
war arc plus the SQL wars/spoils summary as the excerpt →
design (temperament as constants; stateless minds as belief
projections and what that sets up for card 122; deterministic
physics; money circulating through violence; burning's law
citation) → the tuning journal's four regimes, with the craft
lesson that every regime was diagnosed by *reading the chronicle*
while the specs stayed green → CS (agent-based modeling: Schelling,
Sugarscape and generative social science, with the annals as the
causal paper trail Sugarscape never had; Walrasian tâtonnement that
deliberately never converges; the war cycle as a relaxation
oscillator whose ~45-day period is a derived quantity) →
wrong-ledger (the plunder-belief bug as the first bug that lives in
law 3's gap, and the audit net it earned; the gremlin's two lucky
days; the price fuse that has never fired, stated rather than tuned
away; the org-chart bend and the two-evals answer).

Docs sweep: README status (post 0007, still-ahead narrows to the
v0.1 cut); CLAUDE.md status (118 done, next up 119/130); glossary
(audit entry replaces the stale toy-universe entry; new "Worlds and
their people" section: world, the toy world, the Vessari, the
Khedrun — per the coining rule); docs/lore/README.md acknowledges
engine-first entries as the shelf's second kind of resident.

### Proving "done"

- Conservation invariants: cents sum constant across all trades;
  sacks: founded + harvested − eaten = held + seized-in-transit,
  every day, for the whole run.
- Factions stay lawful: civs' decide functions receive only
  (beliefs, stream, tick) — no new capability leaked in.
- War mechanics: a fuse of N high prices declares; peace follows
  price relief; raids never seize more than the granary holds.
- Statelessness: a civ's decision at tick T is a pure function of
  (beliefs at T, stream state, T) — spec by rebuilding a store and
  replaying.
- Golden re-cut (third ledger entry) + the 1000-day acceptance run,
  read by a human, with at least one unplanned war in it.
