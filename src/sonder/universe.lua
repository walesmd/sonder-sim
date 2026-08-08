-- src/sonder/universe.lua — the heartbeat.
--
-- A universe is a seed, a tick counter, named RNG streams, an annals,
-- an ordered list of systems, and an ordered list of factions.
-- step() advances the counter, runs every system once, then gives
-- every faction its turn — all in registration order, arrays walked
-- by index, because pairs() order is unspecified and must never be
-- allowed near an outcome.
--
-- Systems are ambient physics: they see the universe and emit
-- directly. Factions are the governed side of law 3: their decision
-- code is handed a belief store, a stream, and the tick — never the
-- universe — and *returns* intents for the universe to emit. The
-- courier (card 122; its own module since card 168 —
-- sonder/courier.lua) delivers news on the mechanisms the world
-- declares (card 150, sonder/carriage.lua) — the field row by
-- default, a radiated medium with infinite range at channel speed.
-- A world past rung 1 of ADR 0005's ladder declares real rows
-- instead, and the witness rule applies: an event no row carries
-- to a faction is never delivered to it. The pass-through era
-- (v0.1, everyone briefly omniscient) remains the degenerate case:
-- nil distance means everywhere is adjacent and news is instant.

local Rng = require "sonder.rng"
local Annals = require "sonder.annals"
local Belief = require "sonder.belief"
local Carriage = require "sonder.carriage"
local Courier = require "sonder.courier"

local Universe = {}
Universe.__index = Universe

-- opts (all optional):
--   distance — the world's answer to "how far?": a function
--     (from, to, tick) → days at channel speed 1, consulted per event
--     at its departure. Declared by content, consumed only here; nil
--     means everywhere is adjacent. The tick parameter is passed even
--     though today's tables ignore it — the door a moving map (card
--     125 and beyond) walks through without touching this file.
--   channel_speed — the divisor that turns distance into delay;
--     default 1. A parameter, not a constant, on lore's orders.
--   mechanisms — the world's carriage rows (card 150; ADR 0005):
--     what carries news here, and how fast. Optional; a world that
--     declares nothing gets the field row at channel speed — the
--     pass-through era as one honest row of data.
--   vocabulary — required (card 160): what can happen in this
--     world, declared by the world. The engine's only demand is
--     universe.genesis, because the engine emits it itself.
function Universe.new(seed, opts)
   assert(math.type(seed) == "integer", "universe: seed must be an integer")
   opts = opts or {}
   assert(type(opts.vocabulary) == "table",
      "universe: a world must supply its vocabulary (opts.vocabulary)")
   assert(opts.distance == nil or type(opts.distance) == "function",
      "universe: opts.distance must be a function (from, to, tick) -> days")
   local channel_speed = opts.channel_speed or 1
   assert(math.type(channel_speed) == "integer" and channel_speed >= 1,
      "universe: opts.channel_speed must be a positive integer")
   local u = setmetatable({
      seed = seed,
      tick = 0, -- integer sim-time; the only clock the sim has
      rng = Rng.new(seed),
      annals = Annals.new(opts.vocabulary),
      distance = opts.distance,
      channel_speed = channel_speed,
      carriage = Carriage.new(
         opts.mechanisms or { Carriage.field(channel_speed) },
         opts.distance),
      systems = {}, -- array of {name, fn}; order is part of the physics
      factions = {}, -- array of {name, home, decide, store}
      names = {}, -- every actor name ever claimed, systems and factions
   }, Universe)
   -- The courier (extracted card 168: sonder/courier.lua) draws its
   -- own dice and owns the stream name outright: no world actor may
   -- claim "courier", because sharing a stream couples draws —
   -- law 1's oldest rule.
   u.names["courier"] = true
   u.courier = Courier.new(u.annals, u.carriage, u.rng:stream("courier"))
   -- In the beginning there was an event, because there is nothing
   -- else for there to be (law 2). Every cause chain in this universe
   -- terminates here, at id 1. Magnitude 0 reads odd on the largest
   -- thing that will ever happen, but magnitude has no scale until
   -- the toy world (card 118) gives it one, and 0 is an honest
   -- "unscaled".
   u:emit{
      kind = "universe.genesis",
      location = "the-void",
      magnitude = 0,
      loudness = "loud",
      payload = { seed = seed },
      causes = {},
   }
   return u
end

-- Systems change the world only by announcing what happened. emit
-- stamps sim-time itself — callers don't get to lie about when — and
-- returns the new event's id, ready to be cited as a later event's
-- cause. Invalid events raise; there is no soft-failure path into
-- the log.
function Universe:emit(spec)
   return self.annals:append(self.tick, spec)
end

-- Actor names are unique across systems and factions together: the
-- name picks the RNG stream, and two actors sharing a stream would
-- couple their draws — a law-1 violation dressed as a convenience.
local function claim(self, name, what)
   assert(type(name) == "string" and #name > 0,
      "universe: " .. what .. " name must be a non-empty string")
   assert(not self.names[name],
      ("universe: the name %q is already taken"):format(name))
   self.names[name] = true
end

-- A system runs each tick as fn(universe, stream, tick). It is handed
-- exactly one source of chance: its own named stream. Nothing hands it
-- the wall clock, because the sim doesn't have one.
function Universe:add_system(name, fn)
   claim(self, name, "system")
   self.systems[#self.systems + 1] = { name = name, fn = fn }
end

-- A faction decides each tick as decide(beliefs, stream, tick) and
-- returns an array of intents (event specs, possibly empty) for the
-- universe to emit. That argument list is law 3's whole enforcement:
-- decision code cannot reach what it was never handed — no universe,
-- no annals, no emit. Not "please don't"; there is no door.
-- A faction lives somewhere: home is the name news travels to —
-- an address, not a fixed point. The map decides where a name is,
-- and a name is free to move (a hull that sails is still an
-- address). Its own distant deeds report back to the same place.
function Universe:add_faction(name, home, decide)
   claim(self, name, "faction")
   assert(type(home) == "string" and #home > 0,
      "universe: " .. name .. ": home must be a non-empty string")
   local store = Belief.new(name)
   self.factions[#self.factions + 1] = {
      name = name,
      home = home,
      decide = decide,
      store = store,
   }
   self.courier:enroll(name, home, store)
end

-- One tick, in the order that is the physics: dawn (the courier's
-- losses land as events — emission stays this file's door), then
-- systems, then each faction in registration order — the courier
-- delivers to it, it decides on what it believes, and its intents
-- are emitted through full validation. How news travels, wears,
-- and dies lives in sonder/courier.lua (card 168); what remains
-- here is only the heartbeat.
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
      assert(type(intents) == "table",
         "universe: " .. faction.name .. ": decide must return an array"
         .. " of intents (perhaps empty), not " .. type(intents))
      for j = 1, #intents do
         self:emit(intents[j])
      end
   end
end

function Universe:run(ticks)
   for _ = 1, ticks do
      self:step()
   end
end

return Universe
