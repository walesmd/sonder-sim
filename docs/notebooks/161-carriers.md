# Notebook — 161-carriers

Card 161: *Carriers research: what carries things, and how fast.*
Prose-first, like card 129: the deliverable is a taxonomy on paper —
every mechanism's speed, coverage, failure profile, cost, and owner —
plus a mapping of which future card builds what, and the post. No
implementation. No technology zoo.

## Why this card exists

Card 122 bought its delay machinery with a licensed shortcut: the
field model, news radiating at one uniform speed with no emitter, no
vehicle, no failure. Mike put the retirement debt on the record the
day he licensed it (notebook 122, Q2): *nothing arrives that nothing
carried* — the field is an engineering placeholder, not the
universe's physics, and it cannot persist. Cards 150–159 are
sequenced to pay that debt: mechanisms (150), degradation (151),
reception (157), in-flight actors (158), money grown up, and the
rest.

But 150 built without a shared design would grow one world's
content: a zoo of hulls and relays that Harrow's caravans and
Bellwether's email can't inhabit. ADR 0004 made the litmus law —
*a carrier is a hull, a caravan, and an email before its card is
even cut* — and this card is that sentence taken literally. Research
before implementation: name the shape all mechanisms share, so each
successor card builds a property of the taxonomy rather than a pile
of special cases.

Standing acceptance test, Mike's own: **payment as credits in a hull
(seven days) versus payment wired electronically (seconds) must be
the same two events at different gaps.** A taxonomy that can't say
why those are one mechanism schema with two speeds has failed.

## Session 1 (2026-08-04) — setup and context

Card 161 written and moved to Up Next; branch `161-carriers` cut
from main at card 160's merge; this notebook opened.

Context gathered before the design conversation:

- **Card 150** (implementation, downstream of this research): retire
  the field; mechanisms each get a speed, a coverage, and a failure
  profile; a carrier can be somebody. Mike's comment, the caution
  this card must honor: in the field model *the warning arrives with
  the sword* — a raid's news travels exactly as fast as the raiders.
  Early warning is a differential-speed phenomenon; the plurality of
  mechanisms is what makes intelligence and preparation time real.
- **Card 151** (degradation): wear is a property of the mechanism
  the information rides — radio garbles, couriers lose detail,
  a sunk ship loses everything. Forces the second audit relaxation.
- **Card 157** (reception): emit → propagate → receive → interpret;
  detection floors; loudness stamp re-judgment punted there.
- **Card 158** (in-flight actors): things in motion are addressable
  actors — a war party that can hear the peace and turn around; the
  Marrow Fleet already established that an address can sail.
- **Notebook 122, Q1–Q2**: distance is a property of the universe,
  speed a property of the mover, time-to-deliver never stored —
  derived at departure. Per-hull speeds were explicitly deferred to
  the carrier card. The field is the degenerate mechanism: a
  universal broadcast with no emitter and no failure modes.
- **The Marrow Fleet** (lore): the carrier archetype — routes,
  prices, biases; news with an invoice; the eval that a carrier can
  be *somebody*, and that whoever is fastest sets the speed of news.
  The Whisper: field-like communication stays lore-possible but must
  be earned.
- **ADR 0004**: the world interface; mechanism schema will be
  engine, mechanism instances world content, if the pattern holds.

## The design questionnaire

Planned questions, one at a time, verdicts inline as they land:

1. One ontology or two — do matter and information ride the same
   taxonomy?
2. The axes — are speed, coverage, failure profile, cost, owner the
   right five, and what type is each?
3. Coverage — addressed versus broadcast, and what radio actually is.
4. Who chooses the mechanism — is channel selection a decision minds
   make (law 3), and where does emission-side choice live?
5. Owners — when a mechanism is somebody, what does that obligate
   (ties to 158 and to cost)?
6. The migration ladder — how the field model and card 122's channel
   speed re-read as degenerate mechanisms, per world, without
   re-cutting history.
7. The build map — which successor card owns which axis (the
   deliverable table).

**Q1 — One ontology or two?** Card 153 already has matter riding
roads: goods and payment travel as paired departure/arrival events
on the travel calendar. Card 150 is framed as *information* rides
things. Do we design one taxonomy of carriage that covers both, or
an information-transport taxonomy that merely shares the travel
scheduler? *Recommendation:* one ontology. Everything that crosses
distance is carried by a mechanism; Mike's payment test case is the
proof it must be so (credits in a hull and credits on a wire are the
same two events, different mechanism, different gap — if matter and
information had separate taxonomies, that sentence couldn't be
written). The real distinction lives one level down, as a payload
property, not a taxonomy split: matter is **exclusive** (grain on
this caravan is not in the granary — conservation, card 120's audit)
while information is **replicable** (the same rumor rides every hull
that heard it, and telling costs the teller nothing). One taxonomy,
two payload disciplines: exclusive payloads obey conservation and
the road ledger; replicable payloads obey belief semantics (learned
stamps, degradation-to-come). Radio then isn't an exception — it's a
mechanism whose payloads are replicable-only, which is why it can
broadcast. The Fleet stays the archetype that carries both at once.
> Mike (2026-08-04): When I think about a good or money or anything
> moving from one place to another, that movement is a system. The
> system itself defines how quickly it moves, or how accurately it
> moves, or the risk associated with it. And then the clear
> distinction is whether an asset is actually moving net zero versus
> whether it is copyable and reproducible, like information or
> intelligence.

*Q1 verdict, restated.* One taxonomy — movement is a system, and the
system owns the properties (speed, accuracy, risk, in Mike's words).
The matter/information split is a fact about the *cargo*, not about
the system: **net-zero** payloads (Mike's term; grain, credits —
conservation holds, the audit's road ledger watches them) versus
**copyable** payloads (news, intelligence — telling costs the teller
nothing; belief semantics watch them instead). Mike's words replace
Claude's draft pair "exclusive/replicable" — plainer, same cut.
Candidate glossary entries when the post lands: *net-zero* and
*copyable* as the two payload disciplines.

*Vocabulary lesson, kept:* Mike flagged "ontology" as opaque — the
question only landed once restated as "one design for everything
that moves, or two separate designs?" Design questions in this
questionnaire get asked in plain words first; terms of art can come
after the idea lands, not before.

**Q2 — The axes.** Every mechanism gets a row in the taxonomy; what
columns must that row have? The card names five: speed, coverage,
failure profile, cost, owner. Mike's Q1 answer already produced
three unprompted — how quickly (speed), how accurately (degradation,
card 151's claim on the failure profile), risk (loss, the other half
of the failure profile). *Recommendation:* the five are right, typed
as follows, each answerable by all three worlds or it's out.

- **Speed** — distance covered per tick; the divisor in card 122's
  derivation (gap = ceil(distance ÷ speed)), so it composes with any
  world's map. Hull: days between stars. Caravan: passes per week.
  Email: effectively instant — which makes the wire the taxonomy's
  boundary case and Mike's payment test live here.
- **Coverage** — which destinations a mechanism can serve and how
  they're named: point-to-point to an address, broadcast within
  range, or relay hop-by-hop. Detail deferred to Q3.
- **Failure profile** — what can go wrong in flight and what the
  world sees when it does: late (delay grows), lossy (never arrives
  — the sunk hull, the dead rider), degraded (arrives wrong — card
  151 owns the whole axis), intercepted (arrives at someone else too
  — a failure that *adds a receiver*). The taxonomy records the
  shape; the owning cards build the machinery (rng.courier, law 1).
- **Cost** — who pays, in what, and when. The Fleet's news has an
  invoice; the caravan charges per trip; email is free at the
  margin. Load-bearing: cost is what keeps differential speed honest
  — with no prices, every faction always picks the fastest system
  and the one-speed field sneaks back in wearing a different hat.
  Card 150's early-warning requirement depends on this axis
  existing.
- **Owner** — who the mechanism *is*: nobody (physics — radio waves
  once emitted), an institution (the Fleet, a caravan house, the IT
  department), or the sender's own people (the war party carrying
  its news home). Owner is where bias, refusal, and selection attach
  (the Fleet doesn't fight; the Fleet stops coming), and card 158 is
  what makes an owner addressable mid-flight.

Two candidate sixth axes, recommended dispositions: **capacity**
(hulls have holds; a caravan carries N units; email doesn't care) is
real but only binds net-zero payloads — file it as a property of the
net-zero discipline, built by whichever economy card first needs it,
noted in the build map rather than the taxonomy's spine. **Range**
(radio falls off; a rider can't cross the sea) folds into coverage
rather than standing alone.
> Mike (2026-08-04): Coverage is a really interesting one because I
> don't view coverage as an attribute of the item being moved from
> point A to point B — it's more an attribute of the delivery
> mechanism. For example pirates could hijack some cargo but they
> probably couldn't hack a banking system. If we're talking about a
> banking system where credits move instantaneously through some
> sort of technology, hackers would be more adept at doing that and
> less adept at literally hijacking and taking a ship. On cost:
> every faction picking the fastest or cheapest system is not
> necessarily true, because we have to take technology and awareness
> of technology into account. A faction would only pick the fastest,
> cheapest, safest transmission method **that they are aware of**.
> There certainly could be technology that they are not aware of.
> And eventually we're going to build an insurance market, but that
> is for the back burner completely.

*Q2 discussion.* Two sharpenings out of Mike's response, both kept:

- **Every column belongs to the mechanism, never the cargo** — the
  frame affirmed, and the pirates/hackers example pushes it further
  than the draft had it: the failure profile is *qualitative* per
  mechanism, not a loss percentage. The same credits face pirates on
  a hull and hackers on a wire, and neither attacker can work the
  other's lane. Obligation added to the failure column: every
  mechanism declares its own threat surface — what "attack" even
  means there. Worlds supply the attackers; the taxonomy demands the
  declaration.
- **The menu is a belief** — law 3 reaching the taxonomy itself. A
  faction chooses from the mechanisms it *believes exist* (and can
  afford, and trusts), never from the world's true list. Ignorance
  stays free: no rows about the wire means credits keep riding
  hulls. Consequences: differential advantage now has three legs —
  speed, price, and *knowledge of channels* — so early warning can
  come from knowing a mechanism the enemy doesn't know exists (the
  Whisper is this fear's lore name; card 157's detection floors are
  its reception-side twin). Adopted as the founding fact of Q4.

Insurance market: captured as a Fizzy card in the Maybe pile with
provenance back to this discussion — back burner completely, Mike's
words. It will eventually price the failure column (the Fleet's
"insurance rises" lore beat already assumes it exists).

> Mike (2026-08-04): I think that seems reasonable for now, but I
> also feel like this is what we have our evals for. So measure that
> against our evals and what we want to accomplish.

*Q2 eval sweep (2026-08-04).* Per Mike's instruction, the row —
speed, coverage, failure profile (threat surfaces declared), cost,
owner; capacity filed under net-zero, range folded into coverage —
was measured against the full suite: the shelf charter and its
speed-of-truth section, the five civilization entries, the world
library, both eval-universe charters, and the flexibility
principles. The row survives every entry. Three amendments earned,
one rider queued for Q3:

1. **Rows are state, not constants** (the Vess's Silences; the
   Ashfold's closed gate; the shelf's FTL-as-technology stance).
   Every cell must be mutable by events — coverage is cut, tolls
   rise, a channel is jammed — and the row *set* itself is history:
   mechanisms are born (a civ develops radio, earns the Whisper),
   improve, and die. The taxonomy obeys law 2 like everything else,
   and the recursion is free: news of a new mechanism travels on
   the old ones. The menu-is-a-belief (Q2 discussion) then follows
   instead of being bolted on — factions learn the new row late.
2. **No universal fallback** (the shellsea ceiling, named in the
   library's own eval note). The union of all coverages need not
   cover the world; a location unreachable by every mechanism must
   stay expressible, or ignorance stops being free. Retiring the
   field means retiring guaranteed delivery — a design that keeps a
   quiet everywhere-mechanism as a default has un-retired the field
   and fails the shellsea.
3. **Mechanisms are data, not code** (flexibility principle 1,
   extended). One carriage code path — travel calendar plus courier;
   a mechanism is a row, a configuration of shared machinery, never
   its own code path. Row *schema* is engine, row *instances* are
   world content (ADR 0004's split, applied). A mechanism concept
   that seems to demand its own code path signals a missing general
   mechanic — and becomes a card.

Rider for Q3: **coverage must carry schedule.** The Fleet's routes
(a port called at twice a year), Bellwether's payday, the rogue
world as a free slow ferry with one departure ever — "which
destinations" is not enough; coverage is which destinations, named
how, *available when*. Card 122's gap = ceil(distance ÷ speed)
silently assumed departure-at-will; the wait for a departure is
real time the taxonomy must be able to price.

Confirmations, briefly, entry by entry: the Fleet's prices land in
cost, its biases and selection in owner, carrier-as-somebody in
owner (158 builds the addressability); the Vess's conductive rock
and the library's signal-medium axis are mechanisms with owner =
nobody; the Continuance's vanished armada demands loss that is
*silent* — a failure event whose loudness can be quiet — hosted
inside the failure column, and their notary work reads forgery as a
threat-surface entry, not a new column; Harrow's tolls and
pass-keepers are third parties who act on a mechanism's cost and
coverage through events without owning it — owner stays singular
(the operator), and "the pass-keeper who closes the gate once" is a
coverage mutation with cause links; Bellwether's managers who sit
on news are mechanisms whose owner is a mind, the office's own
Marrow Fleet; and the office wire is the shelf's FTL boundary case
already in production — the same row schema hosts the Whisper the
space cast fears and the email Bellwether ignores daily, which is
the three-universes litmus passing in one sentence. The Khedrun's
sack-per-raider briefly argued for capacity as a column; it binds
only net-zero cargo, so the filed disposition holds. Cost's "in
what" stays deliberately open (coin, favors, reputation — the
Fleet's rights-wealth is the economy's stress test, not this
row's), per principle 3: qualitative until a mechanic needs the
number.

Q2 closes with the row as amended, pending Mike's read of the three
amendments.
> Mike (2026-08-04): That looks good to me. Let's continue.

**Q2 closed.** The row: speed, coverage, failure profile with
declared threat surfaces, cost, owner — every cell mutable by
events, the row set itself history, no universal fallback,
mechanisms as data never code. Capacity filed under the net-zero
discipline; range folded into coverage.

**Q3 — Coverage's shapes.** When a mechanism delivers, what shapes
can "where it goes" take? Candidates from the worlds: the rider to
a capital, the email to an inbox (delivery to a *name*); the radio
emission, the beacon, the proclamation in the square, the standing
channel (delivery to a *region*); the rumor climbing the org chart,
gossip port to port (delivery by *retelling*). *Recommendation:*
two primitive shapes, not three — **addressed** and **radiated** —
and relay is behavior, not a shape.

- **Addressed** — the sender names a destination and the mechanism
  traverses the map to it. The name is anything the world's map can
  price, and an address can sail (card 158's war party, a Fleet
  hull): resolving a moving name is the mechanism's problem, priced
  into its row. Delivery is to the name's holder.
- **Radiated** — the sender emits into a *neighborhood of the map*,
  no addressing: everyone whose position falls inside the coverage
  region is delivered to, subject to card 157's detection floors.
  "Range" means whatever the world's map means by nearness — hops
  up the org chart, adjacency on the continent, distance in the
  void — so the litmus holds without a special case. Interception
  dissolves for this shape: a radiated payload has no wrong
  recipient, only receivers with and without instruments (the
  addressed shape keeps interception in its threat surface — mail
  can be read, hulls boarded).
- **Relay is not a shape.** A rumor cascade is minds re-emitting: an
  event arrives, a mind decides (law 3, on its beliefs) to tell
  someone, and the telling is a *fresh emission* riding an addressed
  or radiated mechanism, cause-linked to the belief that prompted
  it. The chain of retellings is a cause chain; card 151's
  "couriers lose detail across retellings" becomes compounding —
  each hop is a new payload composed from the teller's possibly
  already-degraded beliefs, plus the mechanism's own wear. Rumor
  stays content; the engine never needs a rumor code path
  (flexibility principle 1 again). Bellwether's managers who sit on
  news are exactly this: the relay hop that declines to fire.

Schedule, per the Q2 rider, folds in as coverage's third part:
coverage = (reachable set, addressing form, availability). At-will
mechanisms send when the sender pleases (email, a rider if you
keep riders); scheduled ones send when the calendar says (the
Fleet's port calls, the weekly caravan, payday); one-shot ones send
once (the rogue world's single departure). The wait for a departure
is real, priceable time — card 153's travel calendar is the obvious
home when 150 implements.

What radio actually is, per this shape pair: a radiated row —
owner is the emitter's operator (or nobody once emitted), speed
effectively map-instant, coverage a range-shaped neighborhood that
jamming can cut (a coverage attack, per the mutable-rows
amendment), garbling in the failure column (card 151's business).
Bellwether's standing channel is the same row at office scale — a
radiated mechanism whose neighborhood is a roster, which is why
"meetings with attendee lists" (declined in the office charter) is
a coverage question, not a new shape.
> Mike (2026-08-04): Yes, two shapes are fine, because a rumor is
> not just a single transmission. A rumor is multiple transmissions,
> and at every stop there is probably some sort of degradation of
> the information or twisting of the information, dependent upon
> the beliefs or the political objectives of that particular stop.
> A rumor is not point A to B. A rumor is point A to B to C to D to
> E to F, and C, D, E all probably influence that a little bit. A
> rumor is not one shipment. A rumor is one plus shipments.

**Q3 closed.** Two shapes — addressed and radiated — with coverage
carrying (reachable set, addressing form, availability). Relay
demoted to behavior, and Mike's verdict sharpened the hop: the
twist at each stop is *choice*, not just wear — "dependent upon the
beliefs **or the political objectives** of that particular stop."
So a retelling re-composes the payload from the teller's degraded
beliefs (card 151's compounding) AND the teller's agenda (card
152's interpretation, and the Fleet's "it selects" made mechanical
— the same decide() that chooses whether to tell chooses *what* to
tell). "A rumor is one plus shipments" — candidate line for the
post; candidate glossary framing if the post coins terms here.

**Q4 — Who chooses the mechanism, and what happens when nobody
does?** Founding fact, from Q2: the menu is a belief. Two cases,
and they split cleanly:

*Deliberate sendings* (an order, a payment, an offer, a warning):
the sender's mind chooses, inside decide(), from the menu it
believes exists — fastest, cheapest, safest *that it is aware of*,
weighted against stakes: the war order pays for the fast channel,
gossip takes the cheap one. The chosen mechanism rides in the
intent. Because the choice reads beliefs and never world state
(law 3, structurally), a faction can choose a mechanism that no
longer exists — the gate closed last week and they haven't heard —
and the failure is itself an event that teaches them. Stale menus
produce misdelivery, and misdelivery produces drama; no special
machinery required.

*Incidental news* (a battle happened; nobody owns telling the
world): nobody chooses, and the field's retirement forces the real
answer, in two parts —

- **Within loudness-range, events radiate on the world's natural
  media.** The world library already has the axis (signal medium:
  air, water, rock, vacuum); a natural medium is just a radiated
  row with owner = nobody, speed from physics, and range scaled by
  the event's loudness stamp. This is the propagation-side consumer
  the loudness stamp has been waiting for (122 stamped it; 157
  judges reception; this card says it scales natural radiation
  range). The Death Star is loud: everyone with line of sight and
  instruments learns directly. The basement colonists are quiet:
  natural media carry nothing, and only deliberate telling moves
  it. The shellsea's ice is a boundary in the medium — no
  infinite-range medium exists, so the no-universal-fallback
  amendment holds; the old field re-reads as a natural medium with
  infinite range, which is exactly what we're retiring.
- **Beyond natural range, news moves only by carriage** — and the
  incidental channel is relay behavior by moving minds: crews and
  travelers arrive carrying what they believe and retell at the
  gates (the hull is a faction, card 158; its beliefs disembark
  with it). The Fleet lore says it outright: every fact in every
  port's ledger arrived in a Fleet hold. Nothing arrives that
  nothing carried, now with no exceptions — what the field used to
  do for free is either physics within earshot or somebody's
  retelling beyond it.
> Mike (2026-08-04): I say we take the tactic of "if a tree falls
> in the forest but no one is there to hear it, does anyone hear
> the sound?" If there is not someone — an individual, a faction, a
> persona — to carry the information, then is it real?

**Q4 closed, hardened.** Mike's verdict goes further than the draft
and the extra distance matters — call it **the witness rule**: an
event's *news* exists only in the minds that caught it. If no
individual, faction, or persona was in range to witness, the
information never enters circulation — not delayed, not degraded,
nonexistent as news, forever. The draft's natural media quietly
"delivered" to whoever they reached — the field's third hat; the
witness rule retires it. Natural media are how witnesses witness
(physics offers; minds catch), and everything after the catch is
somebody carrying. There is no delivery without a deliverer.

The guard, stated so the rule is never misread: **law 2 is
untouched.** The tree falls; the annals hears it; the event is
recorded, seals over it, and any chronicle can show it to the
observer. What has no existence without a witness is the
propagating copy — the news. The universe keeps truths no
civilization will ever hold, which is the project's namesake
feeling pointed at epistemology: complete inner histories nobody
has heard of. (The Fleet entry's temptation note stands: the
annals knows everything; we do not break law 2 for drama — the
witness rule generates the drama without touching truth.)

Consequences banked for the successor cards: the witness set of an
event is the minds within loudness-scaled range with adequate
detection (157's floors) *at event time* — a computation 150 owns;
silent loss is now first-class (the Continuance's vanished armada:
loud somewhere, witnessed by no one who survived to carry it —
"nothing, so far"); and espionage gets its physics — being the only
witness is an asset, and 157's beliefs-about-loudness games are
beliefs about *who else was in earshot*.

**Q5 — When the mechanism is somebody, what does carrying oblige?**
Owner-as-mind is settled (Q2); bias-at-the-hop is settled (Q3);
addressability in motion is card 158's. What remains is the
relationship between the sender and the somebody. *Recommendation,
three parts:*

- **Carriage is a service transaction on the existing trade
  grammar.** Card 153 already made the trade "just the agreement"
  with goods and payment riding as journeys; hiring a carrier is
  the same grammar — an offer to carry, an acceptance, payment on
  the mechanism's cost terms. No new commerce machinery; the Fleet
  invoices through the same events the Vessari sell grain through.
- **Custody, not ownership.** A net-zero payload in an owned
  mechanism sits in the owner's hands: the road ledger (founded =
  held + on-road) already speaks custody — this names whose hands
  the on-road column means. Custody is what makes theft-by-carrier
  a coherent event, and what the audit watches when the carrier is
  a person and not a road.
- **Payloads ride opaque by default — freight versus belief.** Two
  ways information travels, and the taxonomy should name them: as
  **freight** (a sealed letter, an email body — the carrier holds
  it without knowing it; wear is the mechanism's physics, card
  151) and as **belief** (the herald's memorized message, the
  crew's port gossip — the carrier knows it, and every arrival is
  a retelling, re-composed per Q3 from beliefs and agendas). The
  Fleet does both at once — "priced, handled, and ever so slightly
  shaped by the handling." Reading the freight you carry is not a
  schema default; it is a *behavior* in the mechanism's threat
  surface (the Fleet reads some mail; a covenant-honest hull does
  not; the manager reads everything). This distinction is also
  what card 151 needs to price wear correctly: freight degrades
  physically, belief-carried news degrades by re-composition.
> Mike (2026-08-04): I think we go middle of the road, custody
> while carried. I can imagine a world in which civilization A
> contracts out civilization C to carry goods to civilization B. A
> and B have an agreement, but perhaps C goes rogue and they steal
> that shipment. I'm not sure if that answers your question or not,
> so let me know if I'm off base.

*Q5 discussion.* Mike's scenario answers parts 1 and 2 and
stress-tests them end to end — walked through the machinery, it
holds at every joint:

- A contracts C to carry to B: the carriage contract is the trade
  grammar (part 1) — offer to carry, acceptance, payment on the
  mechanism's cost terms.
- Departure: A's books move the goods from held to on-road; custody
  = C (part 2 — custody names whose hands the road ledger's on-road
  column means).
- C goes rogue: the theft is an event; goods move from the road
  into C's stores. World-level conservation intact — the audit
  certifies nothing vanished, because nothing did.
- **The witness rule pays off unprompted:** a theft on an empty
  road has one witness, and he isn't telling. A eventually learns
  only that B reports non-arrival — carried back by some mechanism,
  days late. Was it C, bandits, the pass, a sunk hull? A and B get
  a *whodunnit built from inference instead of news*, while the
  annals knows the truth throughout and the observer can watch A
  accuse the wrong neighbor. Q4's doctrine generates the drama;
  nothing here needed new machinery.

Banked as an eval seed, litmus-clean — **the carrier who goes
rogue**: a Fleet clan skims cargo in a hungry year (the Conjunction
hangs them — reputation as the control on rogue carriers; card 162
eventually prices the residual risk), a caravan house steals the
shipment, a manager sits on work product routed through them.

Part 3 (opacity — freight versus belief) remains open, restated
against Mike's own scenario: rogue C carrying *grain* steals it,
and the theft is visible at arrival day — nothing arrives; a hole
in the world. Rogue C carrying A's *letter* can instead read it —
and B still receives the letter on time. Copyable cargo isn't
stolen, it's leaked: no hole, nothing visibly wrong, but a copy
went somewhere A never sent it. The net-zero/copyable split from
Q1 is exactly why the two betrayals look different. Recommendation
stands: payloads ride opaque by default; the carrier knowing its
freight is a behavior in the threat surface, never a schema
default.
> Mike (2026-08-04): For copyable information, yes — opaque by
> default. I think it would come down to that civilization's
> behaviors as to whether they look at it or not. When we look at
> net-zero sorts of cargo, obviously that would be on a manifest or
> something, and so they would know exactly what they're hauling.
> Letters, copyable things, should certainly be on the manifest,
> but it would come down to civilization behavior as to whether
> they open up the mail and read it or not.

**Q5 closed, with the manifest layer added.** Carriage is the trade
grammar; custody while carried; and knowledge splits in two —
**manifest knowledge** (the carrier always knows *what* it hauls;
for net-zero cargo that is total knowledge, grain being grain) and
**content knowledge** (for copyable cargo the manifest stops at the
envelope: "one sealed letter for B" is manifest; what it says is
behind the opening-the-mail behavior, a civilization proclivity in
the mechanism's threat surface). Opacity is not ignorance of the
freight — it is ignorance of the contents. Whether a carrier looks
is temperament: lore-facing knob, the Fleet's "it selects" and the
covenant-honest hull both live here.

*Hand-off note from the card pull (2026-08-04):* card 159's
specie-vs-ledger-money seed completes Mike's acceptance test. Wired
payment = a payment *message* riding a fast mechanism, settled at
the receiving ledger (159 builds the ledger); credits in a hull =
specie as net-zero freight (153 already built the road). The
taxonomy hosts both today on paper — same two events, different
gaps — and the build map (Q7) should show the split explicitly.

**Q6 — The migration ladder.** What happens to the three worlds
that already run — and what is the promise that adopting the
taxonomy re-describes history rather than rewriting it?
*Recommendation:* a three-rung ladder, climbed per world.

- **Rung 0 — this card.** Re-description on paper, zero code. What
  runs today re-reads exactly as degenerate rows: the courier's
  delivery of everything to everyone is one row — a natural medium
  with infinite range and uniform speed, owner nobody, no failure,
  no cost, at-will (the **field row**; under the witness rule it is
  doctrinally forbidden going forward, and stays only as the
  licensed placeholder card 122 put on the record). The journeys —
  war.march, cargo.*, payment.* — are addressed mechanisms owned by
  the sender's own people, no failure, no cost. Nothing moves;
  three seals untouched.
- **Rung 1 — card 150 opens.** The row schema lands in the engine;
  each world declares its current behavior as rows; the field row
  is now data, not code. Proof: all three golden seals bit-identical
  — the card-153 adoption pattern (same history, new machinery
  underneath).
- **Rung 2 — per world, deliberately.** A world retires its field
  row and replaces it with real mechanisms — witnesses within
  loudness range, carriers beyond, schedules on the calendar. Each
  replacement re-cuts that world's seal once, loudly, with a ledger
  entry (the card-116 discipline). The witness rule becomes
  enforceable in a world at its rung 2, not before.

The open choice for Mike: **per-world climb versus big-bang.**
Recommendation is per-world — each world's seal is protected until
its own deliberate re-cut; one world pilots rung 2 and the lessons
are cheap; and the litmus stays enforced anyway because the schema
(rung 1) ships for all three at once. Which world pilots is card
150's decision, not this card's.
> Mike (2026-08-04): I'm not sure I actually understand the
> question. From my perspective the three worlds are three
> completely independent unique worlds. They all have their own big
> bangs. We are just building a simulation engine that can support
> them all.

**Q6 closed — and the question dissolved.** Vocabulary lesson #2
this card: "big-bang" (software jargon for all-at-once migration)
collided with cosmology; Mike reasonably read it as genesis. The
plain question was only: when 150 builds carriers, must all three
worlds adopt at once, or each on its own schedule? Mike's framing
*contains* the answer: independent worlds, one engine — so the
engine gains the capability once (rung 1), and each world adopts
when its content is ready (rung 2), independently, because
independence is the premise. ADR 0004's split again: capability is
engine, adoption is world content. The ladder's only addition is
bookkeeping — a world's adoption is a deliberate, recorded moment
(seal re-cut, ledger entry), never a silent rewrite. Per-world it
is, by derivation rather than decree.

**Q7 — The build map.** The card's deliverable table: which
successor card owns which piece of the taxonomy. Everything this
questionnaire designed, assigned to the card that builds it:

| Piece of the taxonomy | Owner |
|---|---|
| Mechanism row schema in the engine; worlds declare rows; the field row becomes data; addressed + radiated delivery; witness-set computation (loudness-scaled natural media, who was in range); menu-as-belief seeding; mechanism choice inside decide(); schedule/availability on the travel calendar | **150** |
| The failure column made real: freight wear (mechanism physics) vs belief-carried re-composition (one-plus-shipments compounding); rng.courier stream; the second audit relaxation | **151** |
| The agenda half of the retelling twist — political objectives, per-culture reading of arrivals (lore-first; wants proclivities from cards 133–146) | **152** |
| Bilateral and illegal trade off the exchange — smuggling as quiet carriage; the audit balancing crime | **154** |
| Exchanges as civ-owned institutions; inter-exchange price propagation at news speed (arbitrage = bilateral story at institutional scale) | **155** |
| Counterfeiting as recorded quiet events — money's doors, forgery in the threat surface | **156** |
| Reception: detection floors; the loudness stamp re-judgment kind by kind with Mike; beliefs about loudness — espionage as beliefs about who else was in earshot | **157** |
| Owners addressable mid-flight: recall, staging, custody events mid-journey (the war party that hears the peace) | **158** |
| Ledger-money: the payment message + the believed ledger (the wire made real); debt as promise-to-pay; specie vs ledger split of Mike's acceptance test | **159** |
| Insurance pricing the failure column on beliefs | **162** (parked) |
| Capacity (holds, sack-per-raider) — binds net-zero cargo only | unowned; claimed by the first economy card that needs it |
| Threat-surface *content* — pirates, bandits, hackers as actual actors | world content, as worlds earn them; the schema slot ships with 150 |

Alongside the map, this card's own deliverables: the post (rung 0
in prose), glossary entries earned here (candidates: mechanism,
net-zero / copyable, freight vs belief-carried, manifest, the
witness rule, the field row), and a proposed **ADR 0005** — the
carrier taxonomy and the witness rule are architecture, not
content, and deserve the short record.
> Mike (2026-08-04): Yes, the table looks solid and I want the ADR.

**Q7 closed — questionnaire complete.** All seven questions ruled:
one taxonomy, two payload disciplines (net-zero / copyable); five
mechanism columns, rows as mutable state, mechanisms as data, no
universal fallback; two shapes (addressed / radiated), relay as
behavior, "a rumor is one plus shipments"; sender chooses from a
believed menu, the witness rule when nobody sends; carriage as
trade grammar, custody while carried, manifest vs content
knowledge; per-world adoption by derivation from world
independence; and the build map as tabled. ADR 0005 written
(docs/adr/0005-the-carrier-taxonomy.md). Remaining for this card:
the post (0014) and the docs sweep.

## Session 1, continued — the post

Post plan approved by Mike (2026-08-04): **post 0014, *The Witness
Rule***, slug `0014-the-witness-rule`; front-door excerpt is the
tree-in-forest exchange (the artifact itself — no invented
chronicle lines, post 0000's lesson); the CS underneath is
**delay-tolerant networking** (NASA's Bundle Protocol — store and
forward, custody transfer, contact plans) paired with epidemic
algorithms (Demers et al. 1987) for the rumor side; the
does-this-need-a-visual question was asked and answered **yes** —
one Mermaid diagram, the life of an event's news under the witness
rule. Mike: cite real deployments — "if there's something we can
refer back to that shows *here is what we implemented*, we should
absolutely do that."

**Standing feedback from Mike, bigger than this post:** our posts
have been lacking the *why* — why are we implementing this in this
moment? Adopted: 0014 gets a "Why now" section, and the post-shape
charter in CLAUDE.md gains "why now" as part of the docs sweep
(drafted for Mike's review like everything else). Saved to memory
so no future post forgets.
