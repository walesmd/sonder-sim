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
-- courier lives here too (card 122): news crosses distance, so an
-- event reaches each faction ceil(distance ÷ channel speed) ticks
-- after it happens, and every store becomes a private chronology.
-- The pass-through era (v0.1, everyone briefly omniscient) ended
-- exactly as promised: without any decide() noticing. A universe
-- built without a distance function still gets that era — nil
-- distance means everywhere is adjacent and news is instant.

local Rng = require "sonder.rng"
local Annals = require "sonder.annals"
local Belief = require "sonder.belief"
local Travel = require "sonder.travel"

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
      systems = {}, -- array of {name, fn}; order is part of the physics
      factions = {}, -- array of {name, home, decide, store, cursor, pending}
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
   self.factions[#self.factions + 1] = {
      name = name,
      home = home,
      decide = decide,
      store = Belief.new(name),
      cursor = 0, -- the courier's bookmark into the annals
      pending = Travel.new(), -- this faction's in-flight news
   }
end

-- How long news takes: distance at the event's departure, divided by
-- the channel speed, rounded up — in integer arithmetic, because a
-- delay decides outcomes and law 1 tolerates no floats near one.
local function delay(self, e, faction)
   if not self.distance then
      return 0
   end
   local d = self.distance(e.location, faction.home, e.tick)
   assert(math.type(d) == "integer" and d >= 0,
      ("universe: distance(%q, %q) must be a non-negative integer")
      :format(e.location, faction.home))
   return (d + self.channel_speed - 1) // self.channel_speed
end

function Universe:step()
   self.tick = self.tick + 1
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
   for i = 1, #self.factions do
      local faction = self.factions[i]
      -- The courier (card 122; calendar extracted card 153). An
      -- event departs its location when emitted and reaches this
      -- faction's home after delay() ticks. What is due today goes
      -- first — in-flight events are older than anything the
      -- bookmark hasn't seen, so ids stay ordered within the tick —
      -- then the bookmark advances over everything new: what has
      -- already arrived is handed over now, the rest goes on the
      -- calendar (sonder/travel.lua, which carries the determinism
      -- argument). Each believed copy is stamped with the tick this
      -- faction learned it, so the store keeps a private
      -- chronology: the order news reached it, not the order things
      -- happened. That gap is the card.
      local due = faction.pending:due(self.tick)
      for j = 1, #due do
         faction.store:receive(due[j], self.tick)
      end
      while faction.cursor < self.annals:len() do
         faction.cursor = faction.cursor + 1
         local e = self.annals:get(faction.cursor)
         local arrives = e.tick + delay(self, e, faction)
         if arrives <= self.tick then
            faction.store:receive(e, self.tick)
         else
            faction.pending:schedule(arrives, e)
         end
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
