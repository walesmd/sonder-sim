# A File for the Question

*Post 0019 · pinned at tag `post/0019` · engine 0.2.2 · ~4 min
read · plain-language version: [simple](./simple.md)*

*Previously: post 0017's review ranked an extraction second on the
menu — the courier, grown from four lines to forty inside the tick
loop, exactly where the next two cards must operate. This card
moves it out, and proves nothing else moved.*

---

The heartbeat, after:

```lua
function Universe:step()
   self.tick = self.tick + 1
   local lost = self.courier:dawn(self.tick)
   for i = 1, #lost do
      self:emit(lost[i])
   end
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
   for i = 1, #self.factions do
      local faction = self.factions[i]
      self.courier:deliver(i, self.tick)
      local intents = faction.decide(faction.store,
         self.rng:stream(faction.name), self.tick)
      ...
   end
end
```

Dawn, then physics, then each mind in turn: delivered to, asked to
decide, obeyed. That is the whole tick now — the order that *is*
the determinism argument, readable in one screen. Everything that
grew inside it since card 122 — the annals cursor, the carriage
query, the encounter dice, the loss calendar, the three-way branch
between *arrives today*, *arrives later*, and *never* — lives in
`sonder/courier.lua`, a module whose header carries the arguments
those forty lines had accumulated.

## Why now

Because the next cards in the queue operate on exactly that code.
Degradation's second half (blur — news that arrives *wrong*) and
card 152's interpretation (news read through a culture) both
change how news wears in transit, and until yesterday the only
place to change that was the tick loop of every universe. The
review's phrasing stuck: give them a file instead of the
heartbeat. This is that file, extracted while it's cheap — before
its first demanding consumer, not after.

## The proof

A pure extraction claims nothing changed, and around here that
claim is checkable to the bit: same draws in the same order, same
deliveries at the same ticks, or the seals say otherwise. All 183
specs passed on the first run — three golden seals bit-identical.
Third use of the card-153 adoption pattern (extract, then prove
the extraction invisible), and the pattern is now routine enough
that the interesting part is writing this paragraph, not sweating
it.

One deliberate relocation: the warning about the courier's dice.
It is the engine's one *shared* RNG stream — reserved, drawn in
recipient order — so adding or reordering factions shifts every
later draw. That is correct (the dice belong to the roads, not to
any actor), but the cards that will add factions mid-history (158,
163) need to expect their seals to move. That warning used to be
findable only in a review notebook; now it's in the module header,
where those cards will actually trip over it.

## The CS underneath: shearing layers

Architects (the building kind) describe structures as **shearing
layers** — Frank Duffy's idea, popularized by Stewart Brand in
*How Buildings Learn*: a building is layers that change at
different rates. Site never changes; structure changes in decades;
services in years; furniture daily. Buildings survive when the
fast layers can move without tearing the slow ones.

Code is the same, and this extraction is a shearing cut. The tick
loop — dawn, systems, minds in order — is *site*: it has not
changed meaning since card 113 and should never. How news travels
and wears is *furniture*: it has changed in four of the last six
cards and will change in the next three. Keeping furniture bolted
to the foundation meant every upholstery job risked the building.
Now the layers shear cleanly, which is all "separation of
concerns" has ever meant: put things that change at different
speeds in different places, so change stays the size of its cause.

## What we got wrong

Nothing broke — so the honest entry is about timing. This
extraction was *available* at card 150, and we declined it as
speculative; two cards later it was load-bearing debt on a review
list. Was that a mistake? We think not, and it's worth saying why:
at card 150 the courier had no dice, no losses, no calendar — the
module we'd have extracted then is not the module that exists now,
and we'd have guessed its shape wrong. The rule of three held: the
third demanding consumer (152, incoming) is what made the seam
real. Extract-on-demand cost us one review finding;
extract-on-speculation would have cost a wrong abstraction. Cheap,
as tuition goes.

Next in the overnight queue: one home for the road-day arithmetic
that is currently written five times.
