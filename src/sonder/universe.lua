-- src/sonder/universe.lua — the heartbeat.
--
-- A universe is a seed, a tick counter, named RNG streams, an annals,
-- and an ordered list of systems. step() advances the counter and
-- runs every system once, in registration order — an array walked by
-- index, because pairs() order is unspecified and must never be
-- allowed near an outcome.

local Rng = require "sonder.rng"
local Annals = require "sonder.annals"

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

-- A system runs each tick as fn(universe, stream, tick). It is handed
-- exactly one source of chance: its own named stream. Nothing hands it
-- the wall clock, because the sim doesn't have one.
function Universe:add_system(name, fn)
   self.systems[#self.systems + 1] = { name = name, fn = fn }
end

function Universe:step()
   self.tick = self.tick + 1
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
end

function Universe:run(ticks)
   for _ = 1, ticks do
      self:step()
   end
end

return Universe
