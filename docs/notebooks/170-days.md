# Notebook — 170-days

Card 170: *One home for road-day arithmetic; retire channel_speed.*
Overnight run, card 2 of 4 (2026-08-08).

## Why this card exists

`ceil(distance ÷ speed)` was written five times — carriage, roads,
audit, space, continent — and three of those sat beside comments
saying "the same integer ceiling the courier uses": the codebase
kept *asserting* the knowledge was one thing while representing it
five ways. Meanwhile `channel_speed` survived card 150 as a
retired concept with living consumers: since rows carry their own
speeds, a world declaring a fast row would have had news and
freight silently priced apart.

## Session 1 — built

- `Travel.days(distance, speed)` — the one statement of the
  formula, asserts included (roads' copy never asserted; now it
  inherits the discipline).
- `Universe:days(from, to, tick)` — the map + road speed, the one
  call freight prices journeys through. News does not go through
  it: the courier asks the carriage, whose rows own their speeds.
- Consumers rewritten: carriage (row arithmetic via Travel.days),
  roads, space's travel(), continent's travel_days().
- **The audit's road contract changed**: `{ distance,
  channel_speed }` → `{ days = fn }` — callers pass a closure over
  Universe:days (main + four spec files updated). Honest limit
  documented at the contract: this explains drift by *freight*
  pace, not carriage rows; the richer road is card 163's docket
  (already noted there).
- `channel_speed` demoted in place: the opts comment now says what
  it is — the road speed — and nothing else reads it directly
  anymore except Universe:days and the default field row.
  Deliberately NOT renamed overnight (road_speed is tempting;
  naming is Mike-flavored — flagged for his read).

183 specs, 0 failures, three seals bit-identical. Engine 0.2.3.
Living docs: api.md gains Universe:days, the demoted
channel_speed row, and the audit road contract.

Post 0020, *The Same Integer Ceiling*: the code confessing its own
duplication is the front door; CS underneath is DRY as Hunt &
Thomas actually stated it (knowledge has one authoritative
representation — not "never type similar lines twice"); visual
question asked, answered no. What-we-got-wrong: the audit road
contract was the review's smallest-looking finding and turned out
to be the widest edit of the card (five call sites) — interface
duplication costs more than expression duplication, which is the
DRY point restated.