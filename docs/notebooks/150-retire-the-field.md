# Notebook — 150-retire-the-field

Card 150: *Carriers: information rides things (retire the field).*
The first implementation card under ADR 0005: the carrier taxonomy
leaves paper and enters the engine.

## Why this card exists

Card 122 licensed the field model — news radiating at one uniform
speed, no emitter, no vehicle, no failure — as an engineering
placeholder, with the retirement debt on the record from day one:
*nothing arrives that nothing carried.* Card 161 designed the
successor (ADR 0005): movement as a system, five columns per
mechanism, two payload disciplines, two delivery shapes, the
witness rule. This card is rung 1 of that ADR's migration ladder —
the row schema lands in the engine, each world declares its current
behavior as rows, the field row becomes data instead of code — and
possibly a rung-2 pilot, which is this card's decision to make
(ADR 0005 assigns it here explicitly).

Inherited requirements, from the card and its comment:

- Mike's caution (card 150 comment): in the field model *the
  warning arrives with the sword* — differential mechanism speeds
  must make early warning possible; spies, allied civilizations
  with faster hulls, better channels.
- The courier seam survives: only the when-does-this-reach-this-
  faction computation changes; belief stores and decision code do
  not move.
- The build map (notebook 161, Q7): this card owns the row schema,
  worlds declaring rows, addressed + radiated delivery, the
  witness-set computation, menu-as-belief seeding, mechanism choice
  inside decide(), and schedules on the travel calendar (card 153's
  calendar is the home).
- The proof obligation (ADR 0005, rung 1): all three golden seals
  bit-identical after the re-expression — the card-153 adoption
  pattern.
- The eval bar (Marrow Fleet entry): "news riding hulls is card
  150's bar" — the full Fleet test runs when the map learns to
  move; at minimum, this card must not foreclose a carrier who is
  somebody.

## Session 1 (2026-08-04) — setup

Card 150 moved to Up Next (the only card there; 161 closed Done the
same day). Branch `150-retire-the-field` cut from main at
`b54251e` (card 161's merge, tag `post/0014`). This notebook
opened.

Candidate questionnaire, to be refined as the design conversation
opens:

1. Scope: rung 1 only (pure re-expression, three seals standing
   still, nothing observable changes), or rung 1 plus a rung-2
   pilot in one world (the field row actually retired somewhere,
   witnesses and carriers real, one seal re-cut on the ledger)?
   And if piloting — which world?
   > Mike (2026-08-04): Go ahead and make a branch, start working
   > on this, and let's go with rung one plus the pilot.

   *Q1 closed:* rung 1 for all three worlds, then the rung-2 pilot
   per the recommendation Mike accepted — **Harrow**: smallest
   world with real geography, trade already travels by journeys,
   and the charter's famine-to-war story gets its news riding the
   same roads as its grain. Space stays on the field row (the
   destination, migrated carefully later); Bellwether too (the org
   chart has no meaningful earshot yet).
2. The row schema as Lua: how a world declares its mechanisms, what
   the engine validates, where rows live relative to the world
   interface (ADR 0004's list).
3. The witness-set computation: loudness-scaled range on natural
   media, who-was-in-range at event time, and what the courier's
   delivery loop becomes.
4. Menu-as-belief seeding: how factions come to believe their
   mechanism menus at genesis, and how menu rows age.
5. The seal proof: what the equivalence spec looks like, and what
   the re-cut ledger entry says if a pilot happens.

## Session 1, continued — reading the engine, and a discovery

The courier is one function: `delay()` inside `Universe:step()`,
`ceil(distance(location, home, tick) ÷ channel_speed)` — the field
row as four lines of arithmetic. The seam held exactly as card 122
promised: one call site.

**The discovery that shapes the pilot:** Harrow's minds never read
the field's over-delivery. Every input to every decide() is either
*self-located* (own tally, own hunger, own war office — distance 0)
or *addressed* (offers where I'm the buyer, accepts where I'm the
seller — read single-fire at learned == tick, exactly the delay a
letter would take). Third parties never act on others' events. So
retiring the field in Harrow changes **no mind's inputs**, which
means no intents change, which means the annals is bit-identical —
**the pilot should not move the continent seal at all.** The
observable product of rung 2 is the belief stores: private
chronologies shrink to what was witnessed or addressed, the
believes viewer grows honestly ignorant, and the specs prove a far
quiet event never lands in an unrelated store. The predicted ledger
entry for a pilot re-cut turns out to be unnecessary — better: the
witness rule lands and history doesn't flinch. (Claude predicted a
re-cut in Q1's framing; the code knew better. Kept for the post's
what-we-got-wrong.)

*Q2 resolved (schema as Lua).* New engine module
`src/sonder/carriage.lua` — the glossary section's name. A world
passes `opts.mechanisms` (array of rows) to Universe.new; the
engine consumes the columns today's worlds exercise — speed and
coverage (shape + range/addressing) — and validates strictly;
failure and cost columns arrive with cards 151/159 per the build
map. Two shapes:

- radiated: `{ name, shape = "radiated", speed, range }` where
  range is `"everywhere"` (the field row) or a table
  `{ loud = R, ["local"] = R, quiet = R }` — earshot as
  loudness-scaled range on the world's own map.
- addressed: `{ name, shape = "addressed", speed, to }` where `to`
  maps event kind → payload field naming the recipient faction
  (`continent.offer` → "buyer"). Declarative — no functions in
  rows; rows are data.

Arrival = earliest across reaching rows (array order breaks ties;
no pairs()). No row reaches → nil → the event is never delivered
to that faction: the witness rule, structurally. Engine default
when a world declares nothing: the field row at channel speed —
bare spec universes keep the pass-through era.

*Q3 resolved (witness sets).* Natural media are a radiated row the
world declares (Harrow's "earshot": loud carries 2 days — over one
cheap pass; local and quiet stay home, range 0). Range 0 delivers
only to factions whose home is the event's location — which makes
quiet self-knowledge exact without any actor-identity machinery.
Genesis at the-void (distance 0 to everywhere, per the world's own
map convention) stays witnessed by all: creation was loud.

*Q4 deferred, on the record:* menu-as-belief seeding needs minds
that *choose* mechanisms; Harrow's minds address letters by charter
(the counterparty is fixed in their standing postures), so the
menu is degenerate — one row, always. Real menu choice arrives
with the first world whose minds weigh channels (space, when the
Fleet lands). Noted in ADR 0005's terms: choice inside decide()
ships its seam here (the letters row exists; whom to address is
already the mind's), but menu *rows as beliefs* wait for content
that can want them.

*Q5 resolved (the proof).* Rung 1: all three seals bit-identical
with the field row declared as data (space, office) — the card-153
adoption pattern. Rung 2 (Harrow): the same seal assertion —
`9be58120c48a121b` stands — plus new specs asserting the witness
rule's observable truth: the steppe never hears the mountains'
hunger; a letter reaches its addressee at road pace and reaches
nobody else.

## Session 1, continued — built, and the prediction held

Implementation landed, one commit's worth, uncommitted pending
Mike's gutter pass:

- `src/sonder/carriage.lua` (new, ~140 lines) — mechanism rows as
  data. Two shapes (radiated with per-loudness range or
  "everywhere"; addressed with a kind → payload-field map), strict
  validation, earliest-arrival-wins across rows, integer arithmetic
  throughout, `Carriage.field(speed)` as the canonical field row.
  nil from `arrival()` is the witness rule: never delivered.
- `src/sonder/universe.lua` — the courier consults
  `carriage:arrival()` instead of the hardwired `delay()`;
  `opts.mechanisms` joins the world interface; default is the field
  row at channel speed, so bare spec universes keep the
  pass-through era.
- `src/worlds/space.lua`, `office.lua` — rung 1: the field row
  declared explicitly, with comments saying why each world waits
  for its own rung-2 card.
- `src/worlds/continent.lua` — rung 2, the pilot: earshot
  (radiated, loud carries 2 days, local/quiet stay home) and
  letters (offers to their buyer, acceptances to their seller).
  No field row.
- `tests/carriage_spec.lua` (new, 14 specs) — unit specs on the
  module plus courier-integration specs, including
  the declared-field-row ≡ old-courier equivalence
  (chronologies compared) and out-of-earshot-is-never-not-late.
- `tests/continent_spec.lua` — three pilot specs: the steppe never
  hears the mountains' hunger; letters land at exactly road pace
  (learned − tick = 4 for valley→mountain offers) and never on the
  Selm's table; foundings carry one pass, not two (the Selm hear
  the valley and the steppe, never the mountains or the gate).

**176 specs, 0 failures. All three golden seals stand, including
Harrow's `9be58120c48a121b` — the field retired and history did
not flinch,** exactly as the discovery predicted: Harrow's minds
never read the over-delivery, so only the belief stores changed.
The believes viewer shows it lived: tethri's private chronology now
holds their own books, the Selm's founding (two days, in earshot),
the Ashfold's salt letters (addressed) — and no trace of the
valley or the mountains. Same seal for every believer, different
fingerprints, smaller and honest.

Flagged for Mike, undecided by Claude:

- **Engine version**: main.lua pins ENGINE_VERSION = "0.1.0"
  (matches the rockspec). The engine gained a module and the world
  interface gained a field — does this card bump to 0.2.0, and
  when in the rhythm does a bump land?
- **ADR 0004 amendment**: the world interface list should gain
  "mechanisms — what carries news, and how fast" as a supplied
  item. Draft it in the docs sweep, or as its own line in ADR 0005?
- The `war.declared` earshot beat: under the pilot, Valebright
  never hears the mountains declare war — the raid arrives
  unannounced at their gates four days later (they witness it
  landing). Honest, dramatic, and exactly the differential-speed
  future card 150's comment demands (an ally in earshot *could*
  warn them — content for a later card). Worth a paragraph in the
  post.

## Session 2 (2026-08-05) — observation is a radiated row

Mike's question, kept: we've focused on carriage of physical goods
and letters — what about knowledge? A star dies and a civilization
just *observes* that fact; can the radiated shape accommodate it?

Answer, on the record: yes — it is the radiated shape's purest
case, and the arithmetic is already proven in miniature (the
carriage spec's loud beacon two days away, witnessed two days late,
never witnessed one day further). A star's death travels on space's
natural medium — light in vacuum, a radiated row with owner nobody:

    { name = "light", shape = "radiated",
      speed = <c in map-units/day>,
      range = { loud = <very far>, ["local"] = <system>, quiet = 0 } }

Astronomy falls out as **delayed witnessing**: a civilization ten
light-years out learns the death ten years late, the learned stamp
carrying the gap — looking at the sky is receiving old news on a
fast medium (the Continuance's "nothing, so far" is this row as
culture). After witnessing, the knowledge is retellable, sellable,
sit-on-able — one plus shipments; the observatory becomes a source,
and instrument differentials become belief-freshness differentials
(the third leg of early warning). Declaring the row is space's
rung-2 content decision: the eval costs a row, not a mechanic —
the litmus paying off as ADR 0005 promised.

Two edges flagged, both owned by card 157: (1) three loudness
levels are coarse for astronomy — a supernova and a shout are both
"loud"; magnitude-scaled range or the kind-by-kind re-judgment
fixes the range column's *input*, not the taxonomy's shape.
(2) Witnessing needs instruments — reception is omniscient within
range today, the licensed simplification 157 retires; when
detection floors land, the shellsea's ice becomes a boundary in
the medium and the under-ice civilization never sees the star die,
exactly the story the world library demands stay tellable.

## Session 2, continued — the post and the sweep

Mike: commit and move to the next task. Part 1 committed
(`f9b4f3b`); the next task in the rhythm is the post.

Post plan: **post 0015, *The Seal That Didn't Move*** — the pilot's
surprise is the story. Front door: the tethri's believes view,
real output from seed 7 (what's *missing* is the excerpt's point).
Why-now: the build map's sequencing, the field as two-card-old
debt. CS underneath: the two shapes as unicast and scoped broadcast
(range as TTL; the field as flooding), and **characterization
testing** (Feathers 2004) — the golden seal as a characterization
test whose surprise was the finding. The does-this-need-a-visual
question was asked and answered yes: one Mermaid map of Harrow
showing how far a declaration of war carries (earshot 2 from
korrag-height; the valley at 4 learns from the raid itself).
What-we-got-wrong: the predicted re-cut that never happened
(reasoned from the mechanism instead of the consumers); "the first
event nobody learned about" overclaimed (per-faction ignorance,
not oblivion — on Harrow every event happens at somebody's home);
the stray lint directive.

Docs sweep: glossary (courier entry de-staled — it hardcoded the
field arithmetic; mechanism and field-row entries gained their
built-at-150 status), README status through post 0015, CLAUDE.md
status and next-up (150 done; 151–159 remain; space's rung 2 noted
as its own future card), ADR 0004's world-interface list amended
with mechanisms (marked as the card-150 amendment). Engine version
left at 0.1.0 — flagged in the PR as an open question for Mike
rather than bumped unilaterally.
