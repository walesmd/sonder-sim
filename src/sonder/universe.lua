-- src/sonder/universe.lua — the heartbeat.
--
-- A universe is a seed, a tick counter, named RNG streams, and an
-- ordered list of systems. step() advances the counter and runs every
-- system once, in registration order — an array walked by index,
-- because pairs() order is unspecified and must never be allowed near
-- an outcome.

local Rng = require "sonder.rng"

local Universe = {}
Universe.__index = Universe

function Universe.new(seed)
   assert(math.type(seed) == "integer", "universe: seed must be an integer")
   return setmetatable({
      seed = seed,
      tick = 0, -- integer sim-time; the only clock the sim has
      rng = Rng.new(seed),
      systems = {}, -- array of {name, fn}; order is part of the physics
   }, Universe)
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
