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
-- courier lives here too: pass-through for v0.1 (deliver everything,
-- immediately; everyone briefly omniscient), replaced wholesale by
-- card 122 without any decide() noticing.

local Rng = require "sonder.rng"
local Annals = require "sonder.annals"
local Belief = require "sonder.belief"

local Universe = {}
Universe.__index = Universe

function Universe.new(seed)
   assert(math.type(seed) == "integer", "universe: seed must be an integer")
   local u = setmetatable({
      seed = seed,
      tick = 0, -- integer sim-time; the only clock the sim has
      rng = Rng.new(seed),
      annals = Annals.new(),
      systems = {}, -- array of {name, fn}; order is part of the physics
      factions = {}, -- array of {name, decide, store, cursor}; ditto
      names = {}, -- every actor name ever claimed, systems and factions
   }, Universe)
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
      visibility = "public",
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
function Universe:add_faction(name, decide)
   claim(self, name, "faction")
   self.factions[#self.factions + 1] = {
      name = name,
      decide = decide,
      store = Belief.new(name),
      cursor = 0, -- the courier's bookmark into the annals
   }
end

function Universe:step()
   self.tick = self.tick + 1
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
   for i = 1, #self.factions do
      local faction = self.factions[i]
      -- The courier, pass-through edition: everything the faction
      -- hasn't heard yet, delivered as copies, in log order. Card 122
      -- replaces exactly this loop with distance, delay, and loss —
      -- nothing downstream of the store will notice.
      while faction.cursor < self.annals:len() do
         faction.cursor = faction.cursor + 1
         faction.store:receive(self.annals:get(faction.cursor))
      end
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
