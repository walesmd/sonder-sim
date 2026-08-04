# Notebook — card 153: travel as a system (goods don't teleport)

*(Closed 2026-08-03, session 1 — a single-session card, design to
post. The official re-cut landed (seal 3475639d8f49678b, ledger
entry in seal_spec), post 0012 shipped in both tracks with the
merchant's sixteen-day ledger as the front door and the drift's
death as the spine, and the docs sweep updated the glossary
(shipment, road ledger, travel calendar), README, and CLAUDE.md.
148 specs green, zero failures. The does-this-need-a-visual
question was asked: yes — the settlement flow diagram is in
complete.md. Post tag `post/0012` goes on the merge commit. One
punt on the record: the price-war bet is settled (lost), and the
hunger-cycle ecology stands per the no-nostalgia ruling.)*

Branch: `153-travel`. Card text: "Goods don't instantly travel from
one point of the universe to the other — but 122 fakes it: the
exchange keeps settling trades instantly, because that card is only
proving the delay machinery on news. Mike's framing to preserve:
travel — goods, news, anything — will require a system of its own."

## Inherited from card 122 (the inputs)

- **The doctrine:** nothing arrives that nothing carried (card 150);
  news has to move, goods have to move (Mike's ruling, session 3);
  one movement system, many cargoes — the hull that carries grain
  carries letters.
- **The licensed fakes this card retires or reckons with:** trade
  settlement teleports goods; war spoils teleport home the moment a
  raid resolves.
- **The wrinkle with a ready acceptance test** (card 153's comment,
  2026-07-28): the Khedrun starve beside full granaries because
  spoils grain arrives home instantly in truth while its news rides
  back at road speed. When goods stop teleporting, the party, the
  grain, and the news arrive home together and the wrinkle heals by
  construction. Test to write: during a war, believed stock at
  khedrun-holds never diverges from audited stock by more than what
  is genuinely still on the road.
- **Machinery in place:** the map behind `distance(from, to, tick)`;
  `travel()` in toy.lua (the integer ceiling); marches already move
  physically (war parties are the first travelers); the audit's road
  (in-flight accounting will need to learn about goods in transit —
  matter that is nowhere-in-particular for d days is a conservation
  question).
- **Scope guards:** settlement risk (paid but undelivered — raided
  in transit?) is real design; carriers-as-somebody stays card 150;
  in-flight actors stay card 158. Whether this card builds the
  general travel system or the goods-specific slice of it is the
  first design question for Mike.

## Session 1 — the design conversation

**Settled first, before the questionnaire (Mike's verdicts):**

1. *Is it time for a travel subsystem?* Yes — his words kept:
   "Instead of rebuilding travel systems over and over and over
   again, we need a travel subsystem now." The timing argument that
   stuck: the transit scheduler already exists in three dialects
   (courier buckets, battle marches, exchange order-arrivals — the
   audit's in-flight ledgers arguably a fourth), so this is
   consolidation past the rule of three, not speculation. Scope
   guards agreed in the same exchange: one scheduler, one speed
   (the existing channel-speed parameter), per-cargo arrival
   semantics stay with their owners, and no technology zoo — the
   moment a per-shipment speed or a breakdown roll appears, that's
   card 150 territory and we walk back.

2. *Does transit enter the event vocabulary?* "It should absolutely
   be an event" — with the distinction he sharpened on the spot:
   grain leaving A for B is **net zero** — a physical good departs
   one place and arrives at the other — whereas information
   traveling is a **copy**: A doesn't lose the asset; a copy of it
   goes to B. A transfer moves; a copy spreads. Same roads, same
   scheduler, opposite arithmetic on arrival — and this is the
   spine of how the audit will treat roads.

**The questionnaire (recommendations recorded; Mike's answers
inline as they land):**

**Q1 — One event grammar or per-cargo kinds?** The march/raid pair
is already the pattern: a departure event (the actor's act, at the
origin) and an arrival event (physics' verdict, at the destination,
cause-linked to the departure). *Recommendation:* generalize the
*shape*, not the kind — per-cargo kinds (grain has different payload
fields than a war party, and the vocabulary's flat, strictly-typed
payloads want that), all conforming to the departure→arrival,
cause-linked pattern the audit and chronicle can rely on.
> Mike: Agreed — generalize the shape, keep per-cargo kinds.

**Q2 — Where does the scheduler live?** Options: a new engine
service on the universe, or a small shared module
(sonder/travel.lua-ish) that the courier, the battle system, the
exchange, and the goods system each instantiate — deduplicating the
code, not the state. *Recommendation:* the shared module, and the
courier adopts it internally as the proof of generality — with the
card-122 trick repeated: after the refactor, the golden seal must
not move (a pure internal swap shifts nothing), and only then do
goods start riding.
> Mike: Agreed, shared module — and yes to the seal-equivalence
> proof.

**Q3 — Where does matter live in transit?** The audit's
conservation identity grows a term: founded + harvested − eaten −
burned = held in granaries + **held on roads**. Departure events
credit the road ledger, arrival events drain it; a violation is an
arrival without a departure, or an arrival exceeding what departed.
"Net zero" is the card's audit bar: nothing conjured, nothing
vanished, some of it just *between places*. *Recommendation:* as
stated; shipments that never arrive stay on the road ledger
honestly until loss gets a recorded door (cards 151/158).
> Mike: Definitely track individual shipments, not totals. And a
> corner-check for the schema: eventually we won't trust that a
> shipment moves linearly from A to B — we'll need its exact
> position in the universe. Pirates, black holes, time dilation.
> Don't build any of that now, but don't back us into a corner:
> it's not just "goods left A, arrives at B in seven days" — a lot
> can happen in those seven days.

*Q3 resolution — the three commitments that keep the door open.*
(1) **Arrival is a verdict, never a promise.** The departure event
records only what left, from where, toward where, when; the arrival
is emitted by physics as its own event. A future system is free to
emit a *different* verdict citing the same departure — taken by
pirates, swallowed, delayed — and the road ledger drains through
whatever recorded door that verdict names. This is already the
march/raid discipline, generalized. (2) **A shipment's identity is
its departure event id.** The pairing runs on cause links, so a
journey's whole history is the events that cite it — never a row
in a table whose schema would need migrating when journeys get
eventful. (3) **Position is a projection, not state.** Where a
shipment is at tick t is derivable from its departure, the map, and
whatever events have befallen it since — the same move as
belief-at-any-tick. Nothing stores a position, so nothing corners
us when positions start to matter. Corollary for the audit: it
checks that matter is conserved across a journey, never that the
journey ran on time — punctuality is physics' business, and time
dilation will thank us.

**Q4 — What actually ships in 153?** Grain from trades (the seller's
sacks depart at settlement and arrive days later) and spoils home
with the war party (healing the starving-beside-full-granaries
wrinkle — its acceptance test is on card 153's comments). The open
half: does *money* travel too? Cents are conserved integers like
sacks; leaving payment teleporting while grain rides creates a new
incoherence (paid instantly, delivered in five days — escrow by
accident). *Recommendation:* both ride — it's the same grammar at
zero new machinery, and "paid but not yet delivered" becomes real,
which the lore's invoice-keeping cultures want eventually.
> Mike: Agreed, money rides too — but eventually we'll probably
> have more complex economic systems, including debt, money
> transfer, etc.

*Q4 note.* The forward pointer captured as a card ("Money grows
up: debt, transfer, and credit"): in 153, money is specie in a
crate — conserved cents physically riding roads. The future his
note names is money as *ledger*: transfer by message (money moving
at news speed — a bank is an institution whose ledger both
counterparties believe, law 3 pointed at finance), debt as a
recorded promise-to-pay with a due tick (the audit learns
receivables), and the Marrow Fleet's rights-and-reputation wealth
already standing as the eval for non-material assets.

**Q5 — How do minds account for their own shipments?** A civ that
shipped grain knows it shipped (own event, one-day lag) — believed
books gain "mine, on the road," and appetite can't eat sacks that
are between places. *Recommendation:* believed books track own
in-transit stock the same learned-watermark way; hunger becomes
possible while your own grain rides, which is honest and probably
re-diversifies the war ecology unaided (the extinct price wars may
return without touching a temperament).
> Mike: A one-tick delay on what a civilization sends out is too
> aggressive — a civ should know exactly what it sent, at least for
> now. But what *arrived* is different: a grain-only civilization
> learns the end of the transaction only when news rides back —
> "we sent 1,000 bundles, only 600 arrived" takes time to come
> home, and they can't know whether pirates hit the shipment until
> it does. And en-route visibility is a *technology*: whether a civ
> can see where its shipments are depends on the systems it has —
> keep it simple now, but that's where the simulation is headed.

*Q5 resolution.* Three tiers of shipment knowledge, now doctrine:
**own acts are known as they happen** (a mind's books never lag its
own dispatches — implementation shape: within a decide, dispatch
decisions are computed before the day's tally is written, so the
tally reflects what left that same morning; self-knowledge is free
and immediate); **outcomes are known when news returns** (arrival
and every other verdict ride back at road speed — already the
model); **en-route visibility is a capability civs don't have yet**
(a technology-and-communications question for the reception era,
cards 157/150 — minds never read the road ledger; ignorance stays
free, even about your own caravans). The believes viewer will show
the middle tier plainly: a merchant's ledger listing shipments
dispatched whose fates are still blank.

**Q6 — The card's bar?** Candidates: the wrinkle-heal test (during
a war, khedrun believed stock never diverges from audited by more
than what's genuinely on the road — already written on the card);
plus one chronicle-legible beat, e.g. a civilization going hungry
beside a road that carries its own arriving grain.
*Recommendation:* both — one is arithmetic, one is a story, and
card 122 taught us the good cards have each.
> Mike: Agreed on both bars. And on the ecology caution: I am not
> of the opinion that the toy narrative needs to reflect that
> either of these civilizations survive at all. A civilization
> dying is an absolutely acceptable outcome. Our toy universe
> should be testing the system we're building — the system
> mechanics themselves. Can the system support the narrative we
> believe to be true and acceptable?

*Q6 resolution — coherence is not survival.* Claude's caution had
said "civilizations must survive their own physics"; Mike struck
it. What must hold through any outcome: the mechanics —
conservation to the sack and cent (through death, if death comes),
events grammatical, the chronicle narratable, the audit balanced,
wars ending or civilizations dying in the attempt. Survival of the
cast is not a spec. The lore shelf agrees in advance: card 143
("the ways civilizations die") is a shelf entry, and the charter
says every system must be able to host the shelf's stories — so if
153's physics starves the Khedrun, that is the system being
*tested against death*, not the system failing. What the
acceptance run owes us is documentation of what the machinery did
at the edge (a faction with empty books, an exchange with a dead
counterparty, hunger events unto silence) — and whatever it did
becomes either a pass, a bug, or a post. The temperament
conversation happens only if Mike *wants* survivors, never because
the system needs them.

## Session 1 — the design, settled; the build order

All six questions answered. The build order:

1. **travel.lua** — the shared deterministic scheduler: the
   calendar-queue pattern extracted (buckets keyed by arrival tick,
   drained at exactly now, id-ordered within a tick), each owner
   instantiating its own. Specs of its own.
2. **The courier adopts it** — pure internal refactor; the golden
   seal must not move (the equivalence proof, second edition).
3. **The vocabulary grows shipment kinds** — per-cargo, all
   conforming to the departure→arrival, cause-linked shape (grain
   and cents both ride, Q4); the audit classifies each by its
   ledger legs; exact kind names and payloads decided at the
   keyboard. Spoils ride home with the war party (the return leg
   gets its design here too).
4. **The audit learns roads** — the road ledger keyed by departure
   event id; conservation identity extended (granaries + roads);
   violations for arrivals-from-nowhere, over-drains, and shipping
   phantom stock; punctuality never audited (Q3's corollary).
5. **The toy rewires** — settlement emits shipments instead of
   moving books instantly (market.trade becomes the agreement; the
   ledger moves on delivery); minds write their tally after their
   dispatch decisions (books never lag own acts, Q5); believed
   books gain "mine, on the road"; appetite can't eat sacks between
   places.
6. **The acceptance run** — with Q6's doctrine standing: death is
   an acceptable outcome; document what the machinery does at the
   edge and check it against card 143's eval. The quiet bet on
   record: goods-delay may re-diversify the war ecology unaided.
7. **The two bars** — the wrinkle-heal identity (believed vs
   audited bounded by the road, during war) and the story excerpt
   (hungry beside a road carrying your own arriving grain).
8. **Re-cut, post 0012, docs sweep** — ledger entry; glossary
   candidates already visible: road, shipment, net zero vs copy.

## Session 1 — steps 1–2, built

`sonder/travel.lua`: the calendar queue extracted — schedule(arrives,
item) and due(now), scheduling order preserved within a tick, pages
torn out as read, instances sharing nothing, and the determinism
argument (indexed by integer tick, read at exactly one tick, no
pairs(), no opinions about order) living where the pattern now
lives. Deliberately cargo-blind: what arrival *means* stays with
each owner, per Q1/Q2. Five specs of its own.

The courier adopted it as a pure internal swap — add_faction's
hand-rolled buckets became a Travel instance; the drain and the
schedule call replaced fifteen lines with two. **The equivalence
proof, second edition: 147 green, and the golden seal did not move
(a3b626e777c0eaff).** Bit-identical history through an extracted
scheduler — the subsystem is born with the same birth certificate
the courier got at card 122.

Not yet adopted: the battle system's march list and the exchange's
order arrivals — they convert in step 5's rewiring, where their
code is already open on the bench. Next: step 3, the shipment
kinds, whose names and payloads we said get decided at the
keyboard.

## Session 1 — the naming conversation (step 3's front door)

Mike opened with the thought exercise (grain.shipped /
grain.delivered — noun on the left, past-tense state on the right,
the state vocabulary consistent across nouns, dot-namespace
extensible) and asked for experience-based feedback. What stuck,
now convention:

1. **Past tense, always** — events are facts, never requests.
   Applies prospectively; v3's grammatical scars (civ.tally,
   market.order) stay, renames cost re-cuts.
2. **Controlled verb list; semantics declared, never parsed** —
   shipped/delivered is the canonical transit lifecycle, uniform
   across cargo families; no code ever infers meaning from a name
   (the audit's explicit registration stays the contract).
3. **The noun is a behavioral class, not an instance** — new
   commodity = payload value; new behavior = new kinds. This amends
   Q1's "per-cargo kinds" to "per-class kinds": cargo (conserved
   matter in units, commodity field), payment (money; its audit
   legs differ), war (agents; the party's homeward leg is
   war.returned — an agent coming home isn't freight even when
   carrying some).
4. **Extend with verbs and payload fields, never deeper dots** —
   two segments, held flat; future verdicts (lost, seized, delayed)
   are new verbs citing the same departures, per Q3's
   arrival-is-a-verdict rule.
> Mike: Agreed — name the class now: cargo, payment, war.returned.
> And the reason locks the design: a civilization might ship
> payment through electronic means — delivery seconds after the
> ship — where another puts literal credits on a ship for seven
> days. The vocabulary must tell the same story either way; the
> speed depends on that civilization's capabilities. The
> vocabulary is very important; we do need to lock it down.

The mechanism-speed independence he named goes on the record as
the taxonomy's design test: grain on a ship for seven days and
credits wired in four seconds are the same two events at different
gaps — cards 150 (mechanisms) and 159 (ledger-money) will cash
this exact check.

## Session 1 — steps 3–7, built

**The vocabulary grew five kinds** (no version bump — appends):
cargo.shipped/delivered, payment.shipped/delivered, war.returned —
and two kinds changed meaning with their docs updated:
market.trade is now the agreement (moves no books), war.spoils is
the verdict *and* the seized goods' departure leg (target debited
where the raid happened; raider credited only at war.returned).

**The audit learned roads:** a road ledger keyed by departure event
id, drained exactly by the arrival that cites it; conservation
identities carry road terms (founded = held + on-road, for money
and matter both); violations for deliveries-from-nowhere,
mismatched drains, and phantom dispatches; punctuality never
audited. The counterfeiter's impossible purchase became an
impossible *dispatch* (a forged payment.shipped driving a treasury
negative).

**The toy rewired:** four Travel calendars (order slips, outbound
marches, homebound parties, freight); a new roads system —
registered first, the mail arrives at dawn — turns due freight into
delivery events; the exchange emits the agreement plus both road
legs (the clamps guarantee nobody ships what they don't hold); the
battle schedules the laden party home; believed books fold the six
road legs by the learned watermark.

**The finding that outranks the steps: the drift died, honestly.**
Every event that moves a civ's books now happens at its own gates —
dispatches leave them, deliveries arrive at them, raids hit them,
parties return through them — all at distance zero. So believed
books stopped drifting from truth entirely: mismatches are ZERO
across every seed, and card 122's relaxed-audit machinery now
certifies the zero instead of explaining the drift. The 122 drift
was a symptom of action at a distance (trades at the exchange
moving faraway books); make matter honest and self-knowledge
becomes exact, while ignorance moves where it belongs — what you
believe about everyone else. The toyworld spec records the full
arc: 120 demanded zero (omniscience), 122 relaxed it (drift as
product), 153 returns it to zero (earned). Post 0012's spine.

**The bars, both met:** the arithmetic bar exceeded (believed vs
audited divergence during war isn't bounded by the road — it's
zero; the wrinkle healed by construction), and the story bar passes
as a spec: civilizations go hungry beside roads carrying their own
grain — in this ecology, chiefly the khedrun starving while their
laden war parties are still homebound.

**The acceptance run (seed 1893, 1000 days):** 20 wars (all hunger
— the price-war bet lost; the quiet bet is settled and the ecology
stays hunger-cycled), 73 trades, 210 hunger days, 176 parties home,
violations 0, mismatches 0, and at day 1000: 40 sacks and 2,000¢
literally between places, with the books balancing around them.
Both civs alive (vessari 891 sacks / 14,706¢; khedrun 82 / 7,294¢)
— Q6's doctrine stands untested by death, this seed.

**The merchant's ledger, rendered** (--believes vessari): day 11
"we dispatch 12 grain" (own act, known instantly); day 19 "1,176¢
from the khedrun reach us" (lands at their gates); day 27 — tick
27 ← tick 19 — they learn their grain arrived, sixteen days after
dispatching it and eight days after being paid for it. Q5's three
tiers, visible in one feed.

Suite: 146 green; the golden seal ×2 red on schedule, awaiting this
card's official re-cut. Uncommitted, awaiting Mike's word.
Remaining: re-cut + post 0012 + docs sweep (glossary: road,
shipment, net zero vs copy; courier entry fine; README/CLAUDE.md).
