# The seven questions

Mike's interview, from the first world-building session. Every
civilization in Sonder must be able to answer these — first as prose
in this directory, eventually as data the simulation can act on:

1. What kind of world is their homeworld?
2. How did that world shape their transition from independent
   organisms to a civilization?
3. What does their economy look like?
4. Where are they technologically, and where on the societal
   evolutionary scale?
5. Do they have religion?
6. How aggressive are they?
7. What civilization-threatening events are they *aware of*?

None of this is being implemented now. This document exists so that
when each mechanic arrives, the question it answers already has a
place to land — and so nothing we write today forecloses an answer we
might want in a decade.

## Question by question: what it shapes, and how it becomes data

### 1. The homeworld

Shapes everything downstream: what's scarce, what's sacred, what
"outside" even means. The Vess grew inside a geothermally active
crystal reef; the Continuance's home is an entire star system it was
told to maintain; the Marrow Fleet's home is a memory with a radio
silence where the signal used to be.

*Infrastructure account:* worlds become **entities with typed
attributes** (biome class, gravity band, resource profile, hazard
profile) when the galaxy grows (card 125). A species carries a
compatibility relationship to world types, not a hardcoded homeworld —
so a seed can grow Vess-like life anywhere reef-compatible. Homeworld
loss (the Fleet) demonstrates the attribute must be nullable: a
civilization is not structurally required to *have* a world.

### 2. Organisms → civilization

The origin story sets the social defaults: trust radius, decision
latency, what an "individual" is. Our three archetypes were chosen to
stress the axis from three directions: the Vess went **many→one**
(isolated reefs fusing into a chorus), the Continuance went
**one→many** (a single mind forced to fork by light-lag), the Fleet
stayed **many-and-mobile** (crews federated by covenant, never fused).

*Infrastructure account:* origin shape becomes a small set of
**parameters on the decision machinery** — consensus latency (ticks to
commit to a choice), polity granularity (one actor, or many
semi-independent ones), succession behavior. Notably *not* code: the
same decision loop, tuned. If an origin story ever genuinely can't be
expressed as tuning, that's a new general mechanic asking to exist.

### 3. Economy

What do they value, what's actually scarce for them, and what posture
do they take at the border where their value system meets someone
else's? The stress test here is honesty about *non-material* goods:
the Vess trade dopants and stored charge but are really trading
theology; the Continuance's scarcest goods are attention and archival
substrate; the Fleet deals in rights and reputation — nothing they
own is heavier than a promise.

*Infrastructure account:* the market mechanic (card 118 and onward)
stays one shared code path; species contribute **valuation weights**
over a shared commodity vocabulary, plus a trade-posture profile
(repricing speed, grudge persistence, arbitrage tolerance). Money
stays integer cents; matter stays discrete and conserved (card 120's
audit) — lore never gets to break law 1. The Vess/Fleet dispute over
whether arbitrage is heresy or a service is *two valuation profiles
disagreeing*, which is exactly law 3: same market, two beliefs
about it.

### 4. Technology & societal stage

Two separate axes, deliberately — a civilization can be Kardashev-
adjacent in energy terms and medieval in institutions, or the
reverse. Tech gates what a civilization *can do*; societal stage
shapes what it *chooses*. Both must be able to move during a run,
in either direction: collapse is history too.

*Infrastructure account:* tech becomes **integer tiers gating event
kinds** (a civilization without orbit-capable tech simply cannot emit
`fleet.launched`), societal stage an enum influencing decision
weights. Both are per-civilization attributes, changed by events like
everything else. The event vocabulary already supports this shape:
gating is a validation rule, not a new mechanism.

### 5. Religion

The most load-bearing question, because Sonder already has a place
where religion *structurally lives*: the belief store. Law 3 says
civilizations act on beliefs, never truth, and card 122's plan is
that news degrades in transit and gets **culturally interpreted** on
arrival. Religion is that interpretation function with a name and a
liturgy. The Vess hear a market signal as a prayer's answer; the
Continuance files the same signal as evidence for the Audit at the
End; the Fleet's hulls remember it as one more entry in an ancestor's
log. Same event, three beliefs — the thesis of the project.

*Infrastructure account:* religion needs **no mechanic of its own**.
It's a bias vector on belief formation (what a civilization does to
events on arrival) plus vocabulary flavor in how its chronicle-facing
history reads. Whether a civilization "has religion" is just whether
its interpretation function is near-identity or richly distorting.
An atheist civilization is a supported configuration, not a special
case — and note we don't have one yet (see gaps).

### 6. Aggression

A posture, not a binary — and it decomposes: willingness to initiate
violence, retaliation persistence, preferred coercion instrument. The
current cast makes the decomposition visible precisely because none
of them favors kinetics: the Vess coerce by disconnection, the
Continuance by overwhelming defense and unnerving post-war repair,
the Fleet by logistics strangulation. Three different "no"s to the
same question.

*Infrastructure account:* the proclivity vector — already in the
project's founding vocabulary (mercantile vs martial, card 118) —
generalizes to **weights over coercion instruments**, feeding the one
shared conflict mechanic when it exists. Making the toy world's
"martial" civilization a weight vector rather than a flag is cheap at
118-time and saves a rewrite at 30-species-time.

### 7. Known existential threats

The question is beautifully phrased: threats they are *aware of* —
which makes it a belief question, not a world question. A threat can
be real and unknown (the thing that may have eaten the Elyr armada),
known and real (hull-blight, substrate rot), known and *wrong* (the
Elyr fled a sensor miscalibration), or mythologized until it's
load-bearing culture (the Still, the Audit, the Kept). The gap
between the threat register in the world and the threat register in
each civilization's head is where Sonder's tragedies will come from.

*Infrastructure account:* real hazards are world-side state and
event kinds; awareness is **rows in the belief store** — no new
machinery, just discipline about never letting the two collapse into
one table. A civilization's existential dread should be queryable,
and wrong.

## Cross-cast reference

| axis | the Vess | the Continuance | the Marrow Fleet |
|---|---|---|---|
| homeworld | geothermal crystal reefworld ("the Instrument") | an entire star system ("the Estate") | lost moon, gone silent ("Marrow") |
| origin shape | many→one (reefs fused by Meridians) | one→many (forks forced by light-lag) | many-and-mobile (covenant federation) |
| scarce goods | energy gradients, dopants | attention, archival substrate | docking rights, reputation |
| trade posture | slow, honest, grudge-bearing; arbitrage is heresy | contract-perfect; overpays for art, logs it as research | fast, fluid; arbitrage is a service |
| tech / society | materials mastery, hates rocketry / unified chorus | K-I+ system engineering / jurisprudence culture | life-support mastery, no heavy industry / clan federation |
| religion | the Deep Hum; auditors as clergy | the Mandate; deletion is the only sin | ancestor-hulls; the hull remembers |
| aggression | disconnection (excommunication at scale) | reluctant, efficient, repairs what it breaks | evasion, sabotage, logistics strangulation |
| known threats | the Fracture, cooling vents, the Still | substrate rot, value drift, the armada's fate | hull-blight, drift, host dependence, the Kept |

## Gaps the current cast does not cover

Written down per principle 6, so the road to thirty fills holes:

- **Everyone is ancient.** All three are elder civilizations with
  deep histories. We have no young species, no pre-industrial
  species, nobody at their equivalent of 1400 CE — and the zoom-in
  fantasy of Sonder (the small civilization on the rim with a
  complete inner history) needs them.
- **Nobody is martial.** Three sophisticated non-kinetic postures
  and not one civilization that genuinely prefers the sword. The toy
  world (card 118) literally requires a martial archetype; it should
  be drawn from a real profile, not a strawman.
- **Everyone is religious.** No secular-materialist civilization,
  no post-religious one, nobody whose interpretation function is
  near-identity.
- **Everyone is coherent.** Three internally-unified polities. No
  fractured species, no species mid-civil-war, no two-civilizations-
  one-species case — which the entity model must eventually permit
  (species ≠ polity; the attribute schema should never assume 1:1).
- **Everyone is likable.** Nobody cruel, parasitic, or tragic in the
  self-inflicted way. A universe of reasonable adults is a universe
  with dull wars.
