# Notebook — 168-courier

Card 168: *Extract the courier from the heartbeat.* Second card off
the 166 findings menu, first of the overnight run (2026-08-08,
Mike asleep, standing authorization: queue it up and start doing
it; nothing merges unmonitored).

## Why this card exists

The courier had lived inline in `Universe:step()` since card 122 —
four lines of arithmetic then, but by card 151 it was forty:
cursor, carriage query, encounter dice, loss scheduling, and a
three-way delivery branch, all in the tick loop. Card 166's review
ranked this the extraction to do *before* card 152, because
degradation's second half (blur) and interpretation both have to
change *how news wears in transit*, and the only place to change
that was the heartbeat. Now it's `sonder/courier.lua`.

## Session 1 — built

Shape: the courier owns per-recipient state (cursor, pending
calendar, store reference), the losses calendar, and the dice —
constructed with the annals, the carriage, and its reserved
stream. Three methods: `enroll(name, home, store)` (registration
order is delivery order, which is physics), `dawn(tick)` (loss
specs returned for the *universe* to emit — emission stays the
universe's door; the courier doesn't get a key), and
`deliver(i, tick)`. `step()` shrank to the heartbeat: dawn →
systems → per faction, deliver → decide → emit.

Two identity notes, for the seal argument: the dice stream is now
derived at construction instead of first draw — derivation is from
(seed, name) alone, so timing cannot matter; and the stream object
was cached before, so holding it is the same object. The warning
from finding 21 (the courier stream is the engine's one *shared*
stream; adding factions shifts later draws — correct, but cards
158/163 should expect it) moved into the module header where those
cards will actually read it.

Proof: **183 specs, 0 failures, first run — three seals
bit-identical.** The card-153 adoption pattern, third use.
Faction rows slimmed to {name, home, decide, store}; cursor and
pending are courier property now (no external consumer touched
them — main and the specs read only .name/.store).

Engine 0.2.2 (patch: engine changed, seals stand). Living docs:
architecture.md's module map gains courier.lua (the courier now
sits between universe and carriage/belief/travel, which is the
truthful picture).

Post 0019, *A File for the Question*: short, honest post for a
pure extraction — front door is the before/after of step(); CS
underneath is separation of concerns via the "shearing layers"
idea (things that change at different rates belong in different
places — the heartbeat changes never, how-news-wears changes every
card); visual question asked, answered no (the diff is the
picture, and architecture.md's updated map carries the diagram
duty). What-we-got-wrong: nothing broke, but on the record — this
extraction was available at card 150 and we declined it as
speculative; two cards later it was load-bearing. The rule of
three held: the third consumer (152, incoming) is what made it
real, and extracting at 150 would have guessed the shape wrong
(no dice existed yet).