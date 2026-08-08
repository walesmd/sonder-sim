# The engine API — a reference

*The public surface of `src/sonder/`, as it stands at engine 0.2.0
(card 166). This is what a world author or a viewer author may
touch; the source comments remain the deep documentation, and the
specs in `tests/` are the executable contract. For what a world
must supply, see ADR 0004; for the concepts, see
[`architecture.md`](architecture.md).*

## Universe — the heartbeat

```lua
local Universe = require "sonder.universe"
local u = Universe.new(seed, opts)
```

`seed` must be an integer. `opts`:

| option | required | meaning |
|---|---|---|
| `vocabulary` | yes | what can happen here: the world's kinds, payloads, and loudness set. The engine demands exactly one entry, `universe.genesis`, because it emits it |
| `distance` | no | the world's map: `(from, to, tick) → days`, integers, consulted at each event's departure. `nil` means everywhere is adjacent (the pass-through era) |
| `channel_speed` | no | default 1; **the road speed** (demoted at card 170): the divisor `Universe:days` prices freight with, and the default field row's speed. News speed belongs to each carriage row |
| `mechanisms` | no | the world's carriage rows (see below). Omitted: the field row at channel speed |

Methods and public fields:

- `u:add_system(name, fn)` — ambient physics. Runs every tick as
  `fn(universe, stream, tick)` with its own named RNG stream.
  Systems see truth and emit directly. Registration order is part
  of the physics.
- `u:add_faction(name, home, decide)` — somebody. `home` is the
  name news travels to (an address, not a coordinate — the map
  decides where names are, and a name may move). `decide` is the
  mind: see the contract below.
- `u:emit(spec)` — append an event now. `spec` = `{ kind, location,
  magnitude, loudness, payload, causes }`; the tick is stamped by
  the universe (callers don't get to lie about when). Returns the
  new event's id. Invalid events raise — there is no soft-failure
  path into the log.
- `u:step()` / `u:run(ticks)` — advance time. One step: dawn
  losses → systems in order → per faction: due deliveries, courier
  scan, decide, intents emitted.
- `u:days(from, to, tick)` — how many days the road between two
  named places takes at this world's road speed (card 170): the
  one call freight systems, worlds, and viewers price journeys
  through. News does not go through here — the courier asks the
  carriage.
- `u.annals`, `u.tick`, `u.seed`, `u.distance`, `u.carriage` —
  readable state. Viewers read `u.annals`; nothing should write
  anywhere but through `emit`.
- Reserved actor name: `courier` (the engine's own dice stream —
  card 151).

**The decide contract** (law 3, structurally):

```lua
local function decide(beliefs, stream, tick)
   -- beliefs: this faction's Belief store — the ONLY world access
   -- stream:  this faction's named RNG stream
   -- tick:    the integer now
   return intents -- an array (possibly empty) of event specs
end
```

Decision code is handed these three things and nothing else. Every
returned intent passes full vocabulary validation when the
universe emits it.

## Carriage rows — what carries news

Declared per world in `opts.mechanisms`; validated strictly at
construction. Two shapes (ADR 0005):

```lua
-- radiated: into a neighborhood of the map
{ name = "earshot", shape = "radiated", speed = 1,
   range = { loud = 2, ["local"] = 0, quiet = 0 } }  -- or range = "everywhere"

-- addressed: to a name found in the payload, per kind
{ name = "letters", shape = "addressed", speed = 1,
   to = { ["continent.offer"] = "buyer",
          ["continent.accept"] = "seller" },
   -- optional (card 151): what travelers meet on the way
   encounters = { per_day = 50,               -- one chance in N per day exposed
                  lost = "continent.letter-lost",  -- the world-named loss kind
                  where = "the-roads" } }      -- a place the map holds far away
```

Semantics: the earliest reaching row carries (ties: declaration
order); no reaching row means never delivered — the witness rule.
Range 0 still reaches the event's own location, which is why quiet
self-knowledge is exact. Encounter fates are drawn at departure on
`rng.courier`; a loss lands as an event on its true day,
reason-free. A world that declares `encounters` must also declare
the loss kind in its vocabulary, give it a template, and classify
it in its audit legs.

## Belief — one faction's memory

`Belief.new(owner)`; the courier calls `store:receive(e, learned)`.
Minds and viewers read:

- `beliefs:latest(kind)` — newest believed copy, or nil (and nil is
  a complete answer: nothing about this ever reached you)
- `beliefs:recent(kind, n)` — last n, arrival order, oldest first
- `beliefs:recall(kind)` — everything believed about a kind
- `beliefs:chronology(as_of)` — the private diary, everything in
  arrival order, optionally as this mind knew it at a past tick
- `beliefs:len()` — how much has ever arrived

Every believed copy carries `learned` — the tick the news reached
its owner — beside the event's own `tick`. The gap is the point.

## Travel and Roads — things in motion

- `Travel.new()` → a calendar. `t:schedule(arrives, item)`,
  `t:due(now)` → items landing exactly now, in scheduling order.
  One calendar per owner; the code is shared, the state never is.
- `Roads.new(u, { resolve, cargo_loudness, payment_loudness })` →
  the freight system. `roads:schedule(e)` prices `cargo.shipped` /
  `payment.shipped` departures; `roads:system(catch_up)` returns
  the system function that emits `*.delivered` at dawn. The four
  kind names are a naming contract the engine currently assumes
  rather than declares (a known review finding).

## Annals, Seal, Archive, Chronicle, Audit — the record and its readers

- `Annals.new(vocabulary)`; `:append(tick, spec)` (validation +
  cause checking), `:get(id)` (a copy), `:len()`.
- `Seal.new(vocabulary)` → rolling hash; `:fold(e)`, `:hex()`.
  `Seal.of(annals)` folds an existing log in one call. Same seal,
  same history.
- `Archive.create(path, annals, provenance, opts)` — provenance
  requires `engine_version`, `git_commit`, `seed`, `config`;
  refuses existing paths. `:sync()` per tick; `:close()` writes the
  final checkpoint. See [`universe-file.md`](universe-file.md).
- `Chronicle.new(annals, templates)` with `:lines()` for
  live-following; `Chronicle.line(e, templates)` and
  `Chronicle.believed_line(held, templates)` render one sentence
  (truth single-dated, belief double-dated). Unknown kinds fall
  back to the envelope — readers age, writes are forever.
- `Audit.of(annals, legs, road)` — `road`, when given, is
  `{ days = (from, to, tick) → integer }` (pass a closure over
  `Universe:days`; card 170). Returns the double-entry report:
  `violations` (impossible arithmetic — zero forever),
  `mismatches` / `unexplained` (self-reports vs the fold),
  `world` (the world's own totals), `unclassified` (kinds the legs
  can't book). `Audit.classified(legs, kind)` supports
  declaration-level coverage specs. The `legs` table a world
  supplies: `columns` (with negative-balance messages),
  `commodities`, `money`, and `effects[kind] = false | function(s,
  e, lib)` — `lib` provides `flag`, `mismatch`, `enroll`, `embark`,
  `disembark`, `ship`, `drift`.

## RNG — named streams

`Rng.new(seed)`; `rng:stream(name)` derives a stream from `(seed,
name)` alone, so a new feature never shifts another subsystem's
draws. `stream:int(lo, hi)` is the only die. Streams are cached;
an actor's name is its stream's name, which is why actor names are
unique and why `courier` is reserved.
