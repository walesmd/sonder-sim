# The world library

A field guide to the kinds of places a civilization can come from,
cling to, or strip for parts. Written for two future customers: card
125 (procedural galaxy growth), which will need to *make* worlds, and
card 118's descendants, which will need civilizations to live on,
fight over, and believe things about them.

## Types are presets, not enums

The catalog below names fifteen world types. None of them will ever
be an enum in the schema. A world, when it becomes data, is a bundle
of **typed attributes** (the seven axes below); a "type" is just a
recognizable cluster of attribute values, the way "desert" names a
climate rather than constrains one. The generator composes attributes
freely, so hybrids are legal by construction — a rogue world with a
live geothermal core is a reefworld with the lights off, and nothing
in the data model should be surprised by it. Named types exist for
lore, chronicle prose, and human conversation. The physics only ever
sees the axes.

## The seven axes of a world

(That there are seven, matching the civilization questions, is
coincidence. Probably.)

1. **Energy budget.** What can power life or industry here, and how
   lavishly: stellar flux, geothermal heat, tidal kneading, radiation
   belts, chemistry, nothing. The single strongest predictor of what
   a world can cradle.
   *Infrastructure:* attribute(s) gating what event kinds a location
   can host — no `forge.lit` where there's nothing to burn.
2. **Habitability envelope.** *Where* life can hold on: open surface,
   crust and cavern, subsurface ocean, cloud deck, nowhere. Note the
   postcard case — open surface — is one value among five, not the
   default.
   *Infrastructure:* an attribute consumed **relationally**. There is
   no `habitable` boolean and never will be: habitability is a join
   between a species' needs and a world's attributes. A Garden is
   paradise to a surface-dweller and noisy dead rock with weather to
   the Vess.
3. **Signal medium.** What carries information there: air, water,
   rock, vacuum. Shapes native senses, and therefore native minds —
   the Vess exist because their world conducts thought.
4. **Gravity and escape cost.** How hard the world holds its
   children. Low-gravity moons breed early spacefarers (the Marrow
   Fleet); deep gravity wells breed astronomers who stay home. The
   gravity tax is a civilization-scale destiny parameter.
5. **Endowment.** The extractable stock: metals, volatiles, dopants,
   biomass. **Finite, discrete, conserved** — when mining becomes a
   mechanic, a world's endowment is an integer ledger and extraction
   moves matter from the world's account to somebody's hold, exactly
   the shape card 120's audit wants. Depletion is not a special
   event; it's a balance reaching zero, and it is history.
6. **Hazard profile.** What the world does to its inhabitants:
   chronic (radiation sleet, tectonic restlessness) and episodic
   (flares, impacts, shell-quakes).
   *Infrastructure:* a hazard profile is a distribution over future
   event kinds — the world-side half of civilization question 7. The
   threats a civilization is *aware of* live in its belief store;
   the hazards that are *real* live here; tragedy lives in the gap.
7. **Stability horizon.** How long the world stays what it is. Vents
   cool, belts drift, orbits decay, stars age. Worlds have lifespans,
   and a civilization's relationship to its horizon — the Vess
   planning against the cooling, the Fleet already gone — is some of
   the best history a simulation can grow.

## The catalog

### Cradles — worlds that can begin a civilization

**Gardens.** Temperate surface worlds: liquid water on the outside,
breathable-adjacent atmospheres, lavish stellar energy. The postcard,
and the only type where living on the *outside* is the default —
which shapes everything: horizon cultures, weather gods, and above
all early astronomy, because a Garden's children can see the stars
from their cradle. Rare, coveted, and contested — with the standing
caveat that desirability is species-relative (the Fleet sees a
gravity trap with nice views). Hazards mild and episodic. History
seeds: colonization races, terraforming disputes, the oldest wars in
everyone's history books.

**Reefworlds.** Geothermal cavern worlds — the Instrument's class.
Mineral-saturated groundwater deposits living reef through a warm
crust; the surface may be airless and the biosphere never notices.
Signal medium is rock itself, so minds here are slow, deep, and
latency-native. Energy is geothermal: steady, ancient, finite (see
stability horizon — the Vess deadline). Utility to visitors: dopants,
rare minerals, geothermal taps — and note that mining a *live*
reefworld sits somewhere between forestry and murder depending on
who you ask, which is a diplomacy engine all by itself.

**Shellseas.** Global oceans under kilometers of ice. Life clusters
at vents; energy is tidal flex plus chemistry. The defining fact is
epistemic: **the ceiling**. A shellsea civilization's universe is
bounded, warm, and dark; astronomy arrives late and traumatically,
if ever — breaking the ice is their Copernican moment, and some
never attempt it, or forbid it. A civilization here can be ancient,
subtle, and know nothing of stars: ignorance is free (law 3), and
the shellsea is its purest natural habitat. Utility: water in
quantity, and radiation-shielded harbors under the shell.

**Sleetworlds.** Low-gravity moons swept by a giant's radiation
belts — Marrow's class. Life happens *indoors*: endolithic,
shielded, communal. The belts are sleet and power line at once
(hazard and harvest), and the gravity tax is nearly zero, so
sleetworld species reach space absurdly early and half-accidentally.
Stability horizon: belts drift as stars age — the slow squeeze that
made the Fleet. History seeds: leavings, and the ones who stay.

**Forges.** Tidally kneaded moons: constant volcanism, ground that
won't hold still, energy in embarrassing surplus. A marginal cradle —
life must love change — and any civilization from one runs on a fast,
twitchy cycle: architecture is a verb, permanence is a superstition,
and a Forge-born diplomat meeting the Vess would conclude, not
unkindly, that they were talking to furniture. Utility: energy taps
and freshly resurfaced minerals, forever.

**Eyeworlds.** Tidally locked to their star: one face burning, one
frozen, life on the terminator ring between. (Settled species'
astronomers call them eyeball planets; the residents never do.)
Geography is destiny at its most literal — civilization here is a
**line, not an area**: every polity has exactly two neighbors, trade
flows along the ring or not at all, and the two frontiers — the
Glare and the Dark — are lethal, mythologized, and directional
scripture. Energy: the permanent wind of a world-sized heat engine.
History seeds: linear geopolitics; every war is a two-front war.

**Veilworlds.** Dense hot atmospheres over unreachable surfaces,
with one temperate band: the cloud decks. Aerial biospheres,
floating life, civilization without ground — no monuments, no mines,
metal-poor and biotech-rich, where weather is geography and nothing
stands still. Natural kinship with the Fleet, who consider veilworld
ports the only settled places that make sense. Utility: atmospheric
chemistry, skimming. Hazard: the down.

### Footholds — worlds that can hold a civilization that arrives

**Holdfasts.** Marginal worlds — thin air, deep cold, dead or nearly.
Almost certainly can't *originate* a civilization; can *sustain* one
that arrives with machines, in domes and warrens, utterly dependent
on the supply chain and the equipment. The type that proves
"originate" and "sustain" are different columns. History seeds: the
classic transplant colony, and the classic collapse — *the domes of
[somewhere] went dark in a season* is a chronicle line waiting to
happen.

**Rocks.** Asteroids and minor moons: negligible gravity, no
weather, pure position and material. What a rock offers is
*location* — an anchorage in the right orbit is worth a garden's
ransom to logistics, which is why the Fleet's territory-that-isn't
is mostly rocks with docking rights attached. History seeds: harbor
politics, claim-jumping, tollgates.

**Rogues.** Starless wanderers crossing the dark between systems.
No stellar budget at all; only internal heat, so most are graves in
waiting — but a rogue with a live core is a reefworld with the
lights off (the canonical preset-composition example), and a
civilization cradled there may not learn that other minds exist
until someone knocks. First contact in its purest form. Fleet
legend prizes them for another reason: a rogue passing through your
system is a free slow ferry across the void, if you dare board
something with no return schedule.

### Quarries and graves — worlds as resources, worlds as warnings

**Giants.** Gas giants: unlandable, indispensable. Fuel to skim,
radiation belts to harvest or dread, moon systems that amount to
small nations of real estate, and gravity that shepherds impactors
away from everyone downhill. Nobody lives *on* one; everything
nearby exists *because* of one. The economic anchor of most systems.

**Cellars.** Comets, ice moons, and the cold outer drift: volatiles
in bulk — water, methane, ammonia — which is to say fuel and life
support feedstock. Cheap to mine, far from everything, and *far
from everything* is a feature for some customers. The name is the
Fleet's, and so is the practice: the true map of the cellars —
which caches exist, and whose — is a fleet's realest treasure.

**Quarries.** Dead rocky worlds with rich veins and no biosphere to
object. Pure extraction: strip, smelt, ship. The cleanest case of
finite integer endowments — a quarry has a lifespan by arithmetic,
and its future ghost infrastructure is visible from its first
boomtown. History seeds: rushes, busts, company-world politics.

**Shatterbelts.** Rings and debris fields — sometimes primordial,
sometimes a former world, and the difference matters enormously: a
recent shatter is a crime scene, a grief site, or both, with
memorials moving at orbital velocity. Salvage economies, navigation
hazards, smuggler cover. If it used to be somebody's world, expect
taboo and treaty before profit.

**Graves.** Worlds that had biospheres — or civilizations — and lost
them. Fossil strata, glassed plains, silent cities. Everything a
quarry offers, plus history, plus dread: every species' astronomers
eventually find graves and must decide what killed them, which is
where half of any civilization's threat register (question 7) comes
from — existential fears are mostly learned from other people's
tombstones. Looting graves is a diplomatic third rail among species
who remember. The Elyr homeworld is a curated one, though the
Continuance objects to the word: *it is maintained.*

## Deliberately out of scope

- **Artificial habitats** — stations, spun cylinders, grown hulls,
  swarms. Those are *outputs* of civilizations, built entities with
  builders and histories, not world types the galaxy deals out. They
  get their own document when construction becomes a mechanic. (The
  Fleet lives entirely in this excluded category, which is exactly
  why the exclusion matters: "where do you live" and "what worlds
  exist" are different questions.)
- **Stars and orbits themselves** — card 125's business. This
  library stays star-agnostic except where the axes demand
  otherwise (energy budget, stability horizon).
- **Exotic compact environments** — neutron star environs, black
  hole accretion economies. Later, if ever; the axes should stretch
  that far, and if they can't, that's the finding.

## Gaps (per the shelf's principle 6)

- No **shared biospheres**: panspermia chains, two worlds trading
  life across a system. The relational-habitability model should
  handle it; nothing written yet exercises it.
- No **living worlds** — biosphere-as-single-organism, where the
  world *is* the civilization. Sits provocatively on the boundary
  between this library and the species shelf; somebody among the
  thirty should live there.
- Cradle diversity skews wet-and-warm: six of seven cradles involve
  liquid water somewhere. Either that's a deliberate cosmology
  stance (life is watery in Sonder) or a failure of imagination —
  decide on the road to thirty, not by accident.
