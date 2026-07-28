# Notebook — card 122: news at ship speed (belief store v2)

Branch: `122-ship-speed`. Card text: "Fill the seam: events propagate
at travel speed, degrade in transit, and get culturally interpreted
on arrival — until two empires disagree about the current state of
their own war."

Mike's framing when queueing it: in the current run every
civilization is omniscient — the two toy civs traded immediately
because they were born aware of each other. In the final version they
might not even know the other exists. The transition wanted: from
all-knowing to actual physics — the spread of information, the moving
of goods.

## Session 1 — the design conversation (questions put to Mike)

Seven questions, each with Claude's recommendation. Mike's answers
get recorded inline; the answers that stick become the design.

**Q1 — What is distance, minimally?** Locations today are four
strings. Options: pairwise distance table; coordinates; a route
graph. *Recommendation:* a pairwise distance table measured in days
at courier speed 1, declared by the world (content, like the cast),
consumed by the engine's courier. Channel speed stays a divisor
parameter so the lore's "channel speed is a parameter, not a
constant" (and someday the Whisper) is real from day one. Card 125
can replace the table with a generated map later without touching
the courier.
> Mike: Go with the recommendation — pairwise table. (Settled after
> the two corner checks recorded below: distance must enter as
> `distance(from, to, tick)` with the table as first implementation,
> and the table is distance only — never time-to-deliver.)

*Q1 discussion (session 2).* Mike's corner check: planets will
eventually move, galaxies rotate — does a static table paint us in?
Claude's answer (verdict pending): no, on one condition we adopt now —
distance enters the design as a *function*, `distance(from, to, tick)
→ days`, called by the courier at each event's departure; the table is
merely that function's first implementation. Three insulating layers:
(1) truth is geometry-free — events carry location names only, so
distance never touches the event schema, annals, audit, or seal;
geometry changes alter *when beliefs form*, never *what happened*;
(2) the courier is the function's only caller — one call site to ever
revisit; (3) the tick parameter is passed from day one even though
the table ignores it, so a moving-map provider later slots in without
touching the courier. Delay fixed at departure vs re-evaluated
mid-flight is a courier-internal refactor inside the same seam if we
ever want it. Known toll, not a corner: any geometry change re-cuts
seed 1893's golden masters (once, loudly, ledger entry).

*Q1 discussion, continued (session 2).* Mike probed a second
assumption: ships and civs will move at different speeds, with
breakdowns and interference — is the table distance only, or
time-to-deliver? Answer that stuck: distance only, and the design
splits three concepts. *Distance* is a property of the universe (the
table; "days at channel speed 1" is a time-flavored unit the way a
light-year is — a reference speed baked into a unit of separation,
not a delivery promise). *Speed* is a property of the mover (v122
has one abstract mover, so speed collapses to the channel-speed
divisor). *Time to deliver* is never stored — derived per event at
departure, `ceil(distance ÷ speed)`. All future richness lands in
that derivation, not the table: per-hull speeds arrive with the
carrier card (Q2's deferral), breakdowns become events on a named
`rng.courier` stream once there's a vehicle to break down (the field
model owes no breakdown answers — part of why field goes first),
degradation is Q3's split, goods logistics is Q5's. Agreed: none of
it factors into 122.

**Q2 — Field or carrier?** Does news simply take d ticks to cross
distance (field model), or does it ride *things* — hulls with routes
and schedules (the Marrow Fleet model)? *Recommendation:* field model
for 122 — delay = ceil(distance ÷ channel speed), fully
deterministic, no rng. Carriers become their own card when a carrier
can be *somebody*; the courier seam survives that upgrade too.
> Mike: Field model for 122 — but on the record: it's an engineering
> shortcut, not the universe's physics, and it cannot persist. Once
> the universe has moving objects, information must disseminate on
> mechanisms — people on ships, radio between planets, some system.
> Default assumption: data travels on a thing unless a civilization
> proves otherwise (field-like communication stays lore-possible,
> not ruled out by physics, but it must be earned — the Whisper).
> 122's field is here to introduce the delay and test the machinery
> going forward.

*Q2 discussion (session 2).* Mike's doctrine is stronger than a
scope call and should outlive the card: nothing arrives that nothing
carried. Claude's one enrichment: Mike's own examples show the
future is a *plurality of mechanisms*, not just hulls — radio is
physically field-like propagation yet still mechanism-flavored (an
emitter, a speed, falloff, jamming) — so the eventual shape is
mechanisms each with a speed, a coverage, and a failure profile,
and v122's field is the degenerate case: a universal broadcast with
no emitter and no failure modes. Everything downstream of "events
arrive late" (belief divergence, the relaxed audit, the believes
viewer) is mechanism-agnostic and survives the field's retirement;
only the "when does this event reach this faction" computation
changes. Consequences now: zero code, but the post and the
courier's comments must call the field a licensed placeholder so
the retirement debt is on the record; captured as a Fizzy card so
it isn't lost in chat.

**Q3 — Scope: delay only, or degradation and interpretation too?**
The card names all three. Degradation and cultural interpretation
each need real design (an rng stream for the courier, per-culture
interpretation rules — likely lore work first). *Recommendation:*
122 ships delay + visibility semantics; degradation and
interpretation split into follow-up cards. "Two empires disagree
about the current state of their own war" is achievable with delay
alone, and it's the card's own bar.
> Mike: Delay only for now — but in the future, degradation via the
> means by which the information travels (a property of the
> mechanism — ties to card 150) and interpretation through a
> civilization's belief system both become things. Don't forget the
> other bits: captured as card 151 (degradation, with the advance
> warning that it forces a second audit relaxation) and card 152
> (interpretation, lore-first, wants the cast's proclivities).

**Q4 — What do the visibilities mean under distance?** Stamped since
card 114, consumed never. *Recommendation as a starting point:*
public = travels everywhere, delayed by distance; regional =
delivered only to civs whose home is within some radius R of the
event's location (R in the same day-units as distance); secret =
delivered only to the acting faction itself. Open sub-questions: R's
value; whether a raiding party "carries the news home" (the spoils
event travels back to the raider's home at courier speed, so the
raider's capital learns of its own victory late — which reads
wonderfully).
> Mike: (a) Yes — everything to everyone, delayed by distance;
> stamps unconsumed in 122. (b) If we need to rename, rename right
> now. And loudness is probably an attribute — or maybe a
> perception — of an event, with a guard: the event doesn't
> *control* its observability. Thirteen colonists in a basement
> talking revolution (which leads to the United States) and the
> Death Star destroying a planet have very different
> observabilities, but it's the environment, their interactions,
> and what the event does to the rest of the universe that control
> that — not the event itself.

*Q4 resolution (session 2).* Mike's guard becomes the constraint on
the field's future consumer: the stamp is an *input* — the signal
the act emitted, declared by the world as part of acting — never
the *answer* to who observes. Observability is computed by the
environment (mechanisms, distance, interference — the era of cards
150–152) or emerges through consequences. The basement example
names that second channel exactly, and the annals already model it:
cause links mean a quiet event becomes historically observable
through its loud descendants — you can't perceive the meeting, but
you can perceive the revolution and walk backward. Decision: rename
now, while nothing consumes the field and 122's golden-master
re-cut is already scheduled to absorb any hash change (byteform
serializes the field name into every hashed event, so field and
value renames alike re-cut history — the rename rides 122's
scheduled re-cut for free).

*Q4 coda (session 2).* Mike: it's the tree-falls-in-the-forest
problem — if a planet gets destroyed and no one's around to see
it, does anyone care? The architecture's answer, on the record: it
makes a sound (law 2 — the annals record it; truth is
observer-independent); nobody knows (law 3 — no belief store gains
a row, so inside the universe it didn't happen for anyone); and
whether anyone *cares* is the player's job (law 4 — the chronicle
projects truth, not belief, so the observer can mourn a planet no
civilization will miss). The project's thesis pointed at its own
mechanics — sonder: the unobserved is still fully real. And per
Mike's own guard, even a witness-free destruction is causally
loud: the shipments stop, the signals go silent; in the mechanism
era, absence becomes information.

*Q4 addendum (session 2, pre-answer).* Mapping the semantics onto
the toy world's real stamps produced three findings. (1) The war
engine is safe from R: both Khedrun fuses run on events R can't
withhold — the price fuse on public `market.price`, the hunger fuse
on their *own* home's `grain.hunger` (`h.location == KHEDRUN.home`,
distance 0) — and no mind reads the other civ's regional events at
all, so R's value is mechanically free in the toy world. (2) The
actor-carries-news-home rule is load-bearing, not flavor:
`war.spoils` lands at the *raid's* location, and without the rule a
small R means the Khedrun never learn of their own plunder — their
believed books drift unboundedly. So: the actor is always entitled
to its own events, delivered from event location to actor home at
channel speed ("the capital learns of its victory when the ships
return"). (3) New sub-question C: secret delivery and the
carry-home rule both need the courier to answer "whose event is
this?", and events carry no actor — today "who did it" lives in
world-specific payloads by convention. Recommendation: event
vocabulary v2 adds an optional top-level `actor` field
(append-friendly addition, documented migration) rather than
teaching the engine's courier to parse content payloads. Unifying
frame for the whole question: visibility decides *entitlement*,
distance decides *when*; delay applies uniformly, even to your own
distant deeds (ceil(0 ÷ speed) = 0 keeps at-home events same-tick).

*Q4 discussion (session 2) — Mike rejects the premise.* Not the
sub-questions: the stamp itself. Visibility is not a state that
information holds; it's a behavior of the actors and entities that
hold the information. Two spies talking is secret only while the
spies keep it — if one goes and tells someone, it's no longer
secret, and the datum never changed. So Claude's addendum above
(R, carry-home rule, actor field) is machinery for entitlement
semantics that shouldn't exist, and is superseded. What survives of
the stamp, pending Mike's confirmation: *loudness at origin* — how
loudly the act was performed (war declared from the walls vs
planned in a cellar), chosen by the emitting actor as part of the
act and an immutable fact of the occurrence thereafter. Who may
*ever* know is never event state: ongoing secrecy is holders
choosing not to retell; disclosure is an *append* — a retelling
event, cause-linked to the original — never a mutation. That
reading unifies the deferred cards: carriers (150) move retellings,
degradation (151) is what retelling chains do to payloads,
interpretation (152) happens at reception. Consequence for 122: Q4
dissolves. The field courier delivers *everything to every faction,
delayed by distance* — stamps unconsumed. No radius R, no special
carry-home rule (war.spoils reaches the raider's home in d days as
a plain delivery), no actor field yet. Two decisions remain for
Mike: (a) confirm everything-delayed as 122's delivery rule;
(b) the stamp's fate — redefine as loudness in the glossary, and
rename the field now (vocabulary v2, documented migration) while
nothing consumes it, or keep the name and redefine only. Post
material either way: card 114 stamped a word that claimed too much.

*The rename, executed (session 2).* Mike picked `loudness`, values
`loud` / `local` / `quiet` (the Death Star is loud, a raid is
local, the basement meeting is quiet). Changed in one pass: the
vocabulary (schema v3, the version-history comment carrying the
reason), the annals' envelope and validation, byteform's canonical
bytes, the archive (column renamed, layout v2), belief's copy, the
genesis stamp, the chronicle's fallback line, the toy world's
thirteen stamps (mechanical mapping: public→loud, regional→local),
and the specs. The golden seal re-cut: ea60291970dba95b →
af26f37ad52c3762, with a ledger entry noting the first re-cut where
history didn't change — same seed, same draws, same 1589 events,
only our name for one fact of them. 117/117 green; ten ticks of
seed 1893 narrate identically; an independent sweep found no
stragglers. Published posts and old notebooks keep the old word —
they are pinned history. **Open item for this card:** the value
mapping was mechanical, but the meaning changed — walk the ten
kinds with Mike and re-judge each stamp under the loudness reading
(is a civ.tally *local*, or is bookkeeping *quiet*? is a
market.order loud everywhere, or loud only at the exchange?). Any
re-judgment is free until 122's final re-cut lands, and the
believes viewer will want honest stamps.

**Q5 — Do goods slow down too?** The exchange settles trades
instantly; raids already take one day. Slowing *goods* (caravans,
delivery, settlement risk) is economy physics — a different beast
from slowing *knowledge*. *Recommendation:* out of scope; new card
("logistics: goods at caravan speed"). One consistency rule inside
122: physical arrivals (war parties) travel at the same speed as
news, so armies never outrun the concept of distance itself.
> Mike: Obviously goods take time to travel — but if we're just
> getting an example of the delay working, we can fake it. Travel,
> whether goods or news or anything, is going to require a system
> of its own, so defer — but write a card, because goods don't
> instantly travel from one point of the universe to the other.

*Q5 resolution (session 2).* Captured as a card ("Travel as a
system: goods don't teleport"). Mike's generalization is the
keeper: one travel system eventually moves everything — it's card
150's mechanism doctrine seen from the cargo hold (the hull that
carries grain carries letters). The 122 consistency rule stands:
war parties ride at news speed. The exchange keeps settling
instantly, on the record as a fake.

**Q6 — Does the toy world itself gain distance?** If
vessar-reaches ↔ khedrun-holds gets a real distance, seed 1893's
history changes: the civs discover each other when the first news
arrives, trade starts late, wars are declared on information that's
already stale — and the golden masters re-cut (once, loudly, ledger
entry). Alternative: keep the toy instant and demo distance only in
specs. *Recommendation:* the toy world gains real distances — the
readable feed is the instrument, and discovery-then-trade is the
whole point of the card. Sub-question: the Vessari currently ignore
war entirely (they read only prices); do they gain minimal
war-awareness (stop offering while they *believe* a war is on) so
the disagreement is legible in the chronicle?
> Mike: Yes, the toy world gains distance — otherwise why does it
> exist? And on war-awareness, lean toward the belief system: what
> do the Vessari believe? That should be the influence, not me.

*Q6 resolution (session 2).* Both halves land, and the second half
arrives as a standing principle: authorial intent enters through
who a civilization *is* (content, proclivities), never through
puppeteering what it does — the influence on behavior is always
the civ's own belief store. Concretely: no stop-trading flag; the
Vessari mind reads its believed war.declared/war.peace rows (which
distance now delivers late) and withholds offers while it believes
a war is on — a prudent grain-seller, in character, prudent on
stale information. Distances to declare in toy.lua (tunable):
vessar-reaches ↔ the-exchange 3, the-exchange ↔ khedrun-holds 5,
vessar-reaches ↔ khedrun-holds 8 — the exchange sits on the road
between them (triangle equality because it's literally on the
path), and the Khedrun, farther out, are the worst-informed: staler
prices, wars declared on older grievances. Known consequences:
seed 1893 re-cuts for real (ledger entry two — the loud one), and
the coherence work so nothing teleports (orders reaching the
exchange late — likely the exchange becoming a believer itself,
law 3 for institutions; raids landing after the ride) gets designed
at implementation.

**Q7 — Observability: do we ship a belief viewer?** The chronicle
renders truth. The card's payoff is the *gap* between truth and each
civ's picture — invisible unless we render a faction's belief store.
*Recommendation:* in scope, small: `--believes vessari` renders the
feed as that civ's belief store received it (its private chronology),
giving the post its "same war twice" excerpt and the zoom thesis its
first working demo.
> Mike: Yes — we should have a mechanism to observe the belief
> system any actor has at any given tick, and be able to easily
> relate that to the truth, which is the chronicle.

*Q7 resolution (session 2).* Mike's phrasing upgrades the scope two
ways, kept verbatim above: *any actor at any given tick* —
point-in-time observability, not just a full-feed replay — and
*easily relate to truth*. Both fall out of one stamp: the courier
writes an arrival tick on each believed copy as it delivers
(belief-side metadata — the event stays a photograph; the arrival
stamp is the album writing a date on the back). With it, an actor's
belief store at any tick T is a pure projection of annals + the
distance table: recomputable from a universe file alone, no new
persistence. Viewer surface (exact flags at implementation):
`--believes NAME` renders the private chronology with double-dated
lines ("day 94 · the vessari learn: on day 86, ..."); an as-of
filter gives any tick; the relation to truth rides shared event
ids — until card 151 lets beliefs diverge from their photographs,
the gap is exactly the in-flight and never-arrived events, plus
per-belief staleness.

## Session 2 — a tooling mishap, and a flow change

Opening the card's worktree from GitLens took over Mike's editor
window and orphaned the session. Nothing was lost: the notebook held
the whole design state, and restoring from it took minutes — the
paper trail earned its keep on its first real test. Decision: for
interactive card work (the norm), we drop worktrees and work on the
branch directly in the main checkout, so Mike's gutter-highlight
review works untouched. Worktrees return if and when we truly run
cards in parallel. The seven questions below still await answers.

## Standing notes (not questions)

- **The audit is already positioned** (card 120): violations stay
  zero forever; the mismatch assertion is the one line 122 relaxes.
  Design intent for the relaxed spec: every tally mismatch must be
  exactly explained by in-flight events — apply the undelivered
  events to the believed figure and you must get the audited figure.
  Drift equals the news that hasn't landed, nothing more.
- **Card 117's planted same-tick spec** didn't survive card 118's
  vocabulary churn in its original form; its spirit lives in
  toyworld_spec's "every tally agrees" assertion. The visible,
  on-schedule red will come from the mismatch line instead —
  post 0006's promise gets kept in a different file.
- believed_books() in toy.lua uses recent() windows sized for
  instant delivery ("a day produces at most one tally per civ") —
  delayed delivery arrives in bursts and will need those windows
  rethought. Implementation detail, but a load-bearing one.
- Deterministic delivery order: when multiple delayed events land on
  the same tick, delivery order must be defined (by event id) — same
  discipline as everything else near outcomes.

## Session 2 — the design, settled; the build order

All seven questions answered (7 for 7, plus one premise rejected
and rebuilt better). What session 2 already shipped: the
visibility→loudness rename (see Q4). What remains, in order:

1. **Distance as content** — toy.lua declares the 3/5/8 table; the
   world exposes `distance(from, to, tick)` (the table ignores
   tick — the unlocked door).
2. **Courier v2** in universe.lua — everything to every faction,
   delayed by ceil(distance ÷ channel speed); channel speed a
   parameter, default 1. Factions gain homes (add_faction grows a
   location). Same-tick deliveries in event-id order. The pending
   deliveries want a deterministic scheduler — likely the card's CS
   lesson (a priority queue keyed on (arrival, id)).
3. **Arrival stamps** — Belief:receive learns the delivery tick
   (Q7's one structural touch).
4. **Coherence: nothing teleports** — war parties ride (raids
   resolve after travel); the exchange stops being omniscient
   (candidate: the exchange becomes a believer — law 3 for
   institutions). Both designed at the keyboard with Mike.
5. **Vessari war-awareness** — the mind reads its believed
   war.declared/war.peace and withholds offers while it believes a
   war is on. In character; no flags (Q6's principle).
6. **The audit relaxes** — drift must be exactly explained by
   in-flight events (card 120's positioned assertion; post 0006's
   promised on-schedule red finally lands). believed_books()
   recent() windows rethought for burst arrivals.
7. **The believes viewer** — Q7's mechanism.
8. **Golden re-cut #2** — the loud one: discovery-then-trade
   history replaces born-omniscient history. Ledger entry.
9. **Post 0011 and the docs sweep** — glossary (channel speed,
   in-flight, whatever the work coins), README status, CLAUDE.md
   status, the stamps re-judgment open item (Q4), simple.md, and
   the does-this-need-a-visual question (early answer: yes — the
   delay geometry and the two-chronologies diagram both want
   Mermaid).

## Session 3 — step 4, designed (three questions, three verdicts)

Part 1 committed at 8b2d46e ("Card 122, part 1: loudness, the map,
and the courier"). Then the step-4 design conversation:

**Q-A — armies stop teleporting via two events.** Mike: completely
agree — declaring war and war happening are different events with
physics, space, and time as inputs. `war.march` at the raider's
home (the faction's act), `war.raid` at the target when the battle
system delivers the party d days later; cause chain declared →
march → raid → spoils. His caution, comment on card 150: "the
warning arrives with the sword" is a one-speed artifact, not a law
— spies, allies with faster hulls, and better channels must
eventually let warnings outrun armies; early warning is a
differential-speed phenomenon.

**Q-B — no recall, for now.** Launched is launched; a raid can land
after the peace (the war that ended before its last battle). Mike's
real concern, captured as card 158: the system must support news
reaching and influencing *all* actors involved — a war party that
hears the peace mid-march and turns around, or stages nearby
because talks might go sideways. Things in motion are addressable
actors; the Marrow Fleet's address-that-sails is the same machinery.

**Q-C — the exchange hears at news speed; settlement stays
physics.** Accepted as a compromise to keep moving. Orders arrive
at the exchange delayed by the same ceil formula; conservation
clamps stay truth-side; goods still teleport (card 153's license).
Mike's reinforcement, comment on card 155: there is no such thing
as THE exchange — plural, mobile, tech-differentiated, arbitrage
everywhere. The hardwired exchange is a placeholder twice over
(singular and omniscient); 122 fixes only the omniscient half.

## Session 3 — step 4, built

Landed: `war.march` (vocabulary append, no version bump — the
departure, at the raider's home) with `war.raid` re-cast as the
arrival end, emitted by the battle system when the road runs out;
`travel()` in toy.lua — the courier's integer ceiling for anything
on the road; the battle system rewritten from raid-resolver to
march-deliverer (raid and spoils the same morning; cause chain
declared → march → raid → spoils); the exchange matching orders by
*arrival* day, so order slips ride the same roads; chronicle
templates split ("rides out against" / "falls on"); the audit
classifies war.march as neutral. War discipline moved from
raid-time to launch-time: marches launch only in wartime, raids may
land after the peace on purpose, and a new property spec holds
every raid to citing a march exactly eight days its senior. Suite:
128 green, the same six scheduled reds. Violations 0; mismatches
296 over 300 days.

What seed 1893 shows now — the feed is the report: war declared
day 82; parties ride out daily; for eight days nothing happens at
vessar-reaches (the declaration's news arrives day 90, the first
sword day 91 — the warning arrives with the sword, exactly as
licensed, card 150's comment holding the future exception); peace
on day 92 with six parties still on the road; raids keep falling
through day 98 — the war that ended before its last battle, on the
first try. And the khedrun sheathe citing cheap grain having *never
heard whether their war worked*: the first spoils news reaches home
day 99, seven days after the peace.

New wrinkle on the record: the khedrun then starve beside full
granaries. Spoils grain teleports home in truth (card 153's
license) but the *news* of it rides back at road speed, so believed
stock stays low, they under-eat what they don't know they have, and
the hunger fuse re-trips (day 97's second war). When goods stop
teleporting (card 153) the party, the grain, and the news all
arrive home together and this heals by construction; until then it
is honest physics under the license — and very fine chronicle
drama.

## Session 3 — step 5, built; and a finding that outranks it

Step 5 landed as designed in Q6: vessari_decide reads its believed
war.declared / war.peace rows (same latest-by-id logic as the
khedrun's own) and withholds offers while it believes a war is on —
prudence at the pace of news, no authorial flags. New toyworld
property spec: replay believed-war windows from truth plus the road
([declared+8, peace+8) at the toy's distances) and assert no sell
order ever lands inside one. 129 green, same six scheduled reds.

**The finding: slow news made price wars extinct.** Eight seeds,
eight thousand days: every single war is hunger-fused — zero price
wars anywhere — and every believed-war window sits inside a longer
market closure caused by the price floor, so the step-5 prudence is
real but *shadowed*: it never gets to close an open market. The new
economy settles into a ~95-day cycle: prices sag to the vessari
floor, the market shuts, the khedrun starve, a war pair follows,
spoils and reopening, repeat. The old ecology's price wars — the
day-86 "grain at 151¢ was the last insult" war that post 0000 made
the project's front-door excerpt — cannot happen in the distance
era with the current temperaments: prices never sustain seven
believed days above 150, because bidding stops (war) or offering
stops (floor) long before. The spec carries an honesty note: its
assertion stands guard, currently unexercised. Decision deferred to
Mike at the step-8 re-tuning (already planned): retune temperaments
to re-diversify the war ecology, or accept the hunger-only cycle as
the honest product of slow news. Post material either way — the
mechanic changed what kind of wars the world *has*, which is the
card's thesis working at a scale we didn't ask it to.

**Mike's ruling (session 3, same day): physics wins.** His words,
kept: "News has to move, goods have to move. If that currently
changes civilizations' behaviors or how we've been measuring this
very limited toy universe, that's okay. The toy universe shouldn't
measure itself against past instantiations of the toy universe."
We are testing a system against two civilizations, without
technology, without trade that bypasses the exchange, without the
rest of the real cast — the old ecology was an artifact of an era,
not a KPI. Doctrine distilled: golden masters pin *determinism*
(same code, same seed, same history) and acceptance specs guard
*coherence* (wars happen and end, discipline holds, money
balances); neither exists to preserve particular dramas. Post
0000's tag keeps the day-86 price war forever; the live world owes
it nothing. Step 8 therefore re-cuts for the new history with no
temperament-chasing, and step 5's prudence stays as built —
shadowed today, waiting for the richer ecology (technology,
bilateral trade, thirty civilizations) to give it a stage.

## Session 2/3 — steps 1–3, built

Landed: the toy's map (3/5/8, the exchange on the road between
them, undeclared pairs adjacent so genesis is heard instantly), the
card-122 courier in universe.lua (per-faction pending buckets
indexed by arrival tick — no pairs(), no floats, delay in integer
arithmetic `(d + speed − 1) // speed`), homes on add_faction, and
the learned stamp in belief.lua (`receive(e, learned)`; the copy
carries it out; the photograph gets a date written on its back).
New tests/courier_spec.lua: eight specs — delay, channel-speed
ceiling, the stamp, id order when far and fresh news share a tick,
distance-zero ≡ pass-through, and the validation walls.

**The equivalence proof, on the record:** with homes wired but no
distances declared, the full suite ran green INCLUDING the golden
seal (af26f37ad52c3762) — courier v2 at distance zero reproduced
history bit for bit. Card 117's seam promise ("replaced wholesale
without any decide() noticing") kept, measurably.

**Then the map went in, and six specs went red — every one on
schedule, none a violation:** the golden seal (history genuinely
re-cut; interim value d951dfcc01e20a9d, not cut until step 8), the
chronicle's golden feed (discovery-then-trade replaced
born-knowing: first offer tick 3, first trade tick 6 — four days
late), and the audit/toyworld mismatch counters — the exact
assertion whose comment says "Card 122 will relax exactly this
assertion — mismatches, never violations." #violations stayed ZERO
on every seed: money and matter still conserve perfectly in truth
while beliefs drift. Post 0006's promised on-schedule red, arrived;
card 120's structural separation of drift from theft, vindicated.

**What the new history shows** (seed 1893): ticks 1–2 silence;
tick 5 the Khedrun bid 103¢ against a believed tick-0 price into a
market already at 92¢; the first war moves from day 86 to day 31
and changes species — hunger, not price, because the granary drains
for six days before the market even connects. And the step-4 work
announced itself in the feed: war declared at khedrun-holds day 31,
war party striking vessar-reaches day 32, the declaration's news
reaching the Vessari day 39 — raiders out of nowhere; the army
outran its own rumor.

**Noted for step 4 (latent, not yet a bug):** a civ physically eats
`min(appetite, believed available)` — after selling, a seller
over-believes its granary for d days, so with meaner temperaments a
civ could eat grain it no longer has. Ran clean on seeds
1893/7/40412 (the Vessari reserve buffers it), but "truth is not
testimony" belongs on step 4's docket: the ledger folds tally
self-reports as if they were physics.

## Session 3 — the adversarial review, and what it caught

A 28-agent review (four lenses, two refuters per finding) over the
steps-1–3 diff. Six findings confirmed, six refuted (among the
refuted: the immediate-path learned stamp and a shallow-copy worry —
killed by evidence, which is what refuters are for).

**The real one — believed_books discarded delayed news forever
(toy.lua).** The `since` watermark was an event *id*: own tallies
arrive a day late, but trade/spoils news arrives 3/5/8 days late
carrying old ids, always below the latest tally's id — so the
moment delayed news finally landed, `id > since` dropped it,
permanently. Verified by execution: the Khedrun's believed treasury
sat frozen at 14,000¢ for sixty days (actual: 6,679¢), believed
stock hit 0 against an actual 313, and 34 phantom-hunger days
tripped the war fuse — the day-31 war was caused by *bookkeeping*,
not slow news. The fix: judge "has my tally absorbed this?" by the
courier's `learned` stamp, never by id — `learned > basis.tick`,
because the tally written on day T absorbed exactly what was
learned by day T (each believed trade integrates into the first
tally decided after it lands, by induction). The arrival stamp we
built for the believes viewer turned out load-bearing for honest
bookkeeping — Q7's mechanism paid for itself before the viewer
even exists. At distance zero the learned-filter and the id-filter
select identical sets, so the equivalence proof stands.

**Five spec-coverage gaps, all now filled** (courier_spec is 13
specs): departure-time distance lookup pinned by a tick-sensitive
map (mutation-tested by the reviewers: the scan-tick mutant passed
the old suite); learned = hand-over tick past computed arrival;
exact-division and speed-beats-distance ceil boundaries; one event
reaching two homes at two ticks; and the private chronology
inverting id order when near news outruns older far news.

**The healed history (seed 1893):** violations 0, mismatches 344
over 300 days (was 1,180 with the bug) — every mismatch now a tally
honestly written while news was in flight, which is precisely what
step 6's relaxed audit will certify. First war day 80 (was day 86
omniscient; the bugged books said day 31), hunger-fused — slow news
genuinely leaves the far civ hungrier, since the market takes six
days to connect. Nine wars in 500 days. Suite: 126 green, the same
six scheduled reds (seal ×2, chronicle feed, audit mismatch
counters ×3). Interim seal after the fix: 419247db6f8710be — still
not cut into the ledger; that waits for step 8.

*Aside (session 3) — trade venues.* Mike asked whether all trading
happens at the exchange. It does, narrowly: one venue, one bid and
one offer per day, and market.trade's vocabulary doc declares it
"the only way money or grain legitimately moves." Fine as a
stepping stone; captured as card 154 for the larger picture —
an exchange *run by a civilization* (an institution owned by an
actor, converging with step 4's exchange-becomes-a-believer), plus
direct civ-to-civ trade, legal and illegal. Two things fall out and
went on the card: smuggling is where loudness earns its keep (a
quiet trade the audit still balances — the audit checks arithmetic,
not law), and once deals happen away from the exchange, civs trade
on their own believed prices — under distance-delayed news,
information asymmetry becomes tradeable and arbitrage emerges for
free. No code changed.

*Aside (session 3) — Mike interrogates `home` against the Fleet.*
Does the mandatory `home` on add_faction fail the Marrow Fleet eval
("systems with a mandatory homeworld... fail this entry")? Verdict,
recorded in the Fleet's eval notes: it holds. Home is a name, not a
fixed point — the map owns where names are, the tick parameter lets
names move, a hull is an address that sails. Mike's conglomerate
reading is the model: each hull a faction with its own store, which
the entry requires (the Wake-Sisters drama needs fragmented
knowledge), and the civilization is an aggregate — civilization ≠
faction, converging with card 136. Engine conditions now in the
eval: home never becomes a coordinate or gets cached as stationary;
nothing hard-wires faction == civilization. Pending honestly:
nothing moves a name yet; the full test runs with the moving map.

*Aside (session 3) — Mike asks about reception-side loudness.*
Should loudness exist on the recipient side — a civ believing
something is secret when it's really loud, or lacking the
technology to perceive a loud event at all? Captured as card 157.
The decomposition that stuck: the stamp is *emission* truth; the
full pipeline is emit (122) → propagate (150/151) → receive (157)
→ interpret (152). Detection capability is a property of the
receiver gating the courier's receive step (below your detection
floor, an event doesn't exist *for you* — ignorance stays free);
beliefs-about-loudness are second-order beliefs (misjudged emission
or misjudged reception — espionage and opsec live there). Design
seed: when stealth becomes attemptable, the actor proposes and the
environment disposes — intent in the payload, the stamp stays the
universe's verdict, same shape as the battle system. Today's
licensed simplifications named: authors stamp honestly (no stealth
attempts), and reception is omniscient (everything that arrives is
perceived).

*Aside (session 3) — the grander trade vision, continued.* Two more
Mike notes, documented as cards 155 and 156, no code changed.
(1) No universal-exchange limitation: civilizations set up their own
exchanges, exchanges interact with exchanges, and an exchange may
refuse certain civilizations — policy from the owner's beliefs and
commerce culture, never engine rules. Step 4's
exchange-becomes-a-believer is the first step down that road.
(2) A civilization of criminal counterfeiters must be possible; the
audit must not forbid the behavior, but must see it ("a thousand
credits just entered the ecosystem"). The doctrine that crystallized:
**crime is content, not corruption.** Law 2 means in-world
counterfeiting is a *recorded* event kind (typically quiet) — a door
for money exactly as burning is a door for matter, lawful because
the event records it. The audit's violation category keeps its
meaning forever: violations = arithmetic unexplained by recorded
events = engine bug or tampered history, always zero; recorded
forgeries balance in truth while staying invisible to belief-side
actors. And the future beat: in-world forgery detection is
belief-side auditing — a treasury reconciling believed books finds
drift NOT explained by in-flight news and starts suspecting someone.
Step 6's relaxed-audit invariant is literally the detective's tool.
