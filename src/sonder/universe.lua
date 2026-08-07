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
-- courier lives here too (card 122): news crosses distance on the
-- mechanisms the world declares (card 150, sonder/carriage.lua) —
-- the field row by default, a radiated medium with infinite range
-- at channel speed, which is the old ceil(distance ÷ channel_speed)
-- arithmetic as one honest row of data. A world past rung 1 of
-- ADR 0005's ladder declares real rows instead, and the witness
-- rule applies: an event no row carries to a faction is never
-- delivered to it. The pass-through era (v0.1, everyone briefly
-- omniscient) remains the degenerate case: nil distance means
-- everywhere is adjacent and news is instant.

local Rng = require "sonder.rng"
local Annals = require "sonder.annals"
local Belief = require "sonder.belief"
local Travel = require "sonder.travel"
local Carriage = require "sonder.carriage"

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
      factions = {}, -- array of {name, home, decide, store, cursor, pending}
      names = {}, -- every actor name ever claimed, systems and factions
      losses = Travel.new(), -- letters the roads have already taken,
      -- awaiting the day the loss actually lands (card 151)
   }, Universe)
   -- The courier draws its own dice now (card 151) and owns the
   -- stream name outright: no world actor may claim "courier",
   -- because sharing a stream couples draws — law 1's oldest rule.
   u.names["courier"] = true
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

function Universe:step()
   self.tick = self.tick + 1
   -- Dawn: losses whose day has come become events (card 151). The
   -- fate was sealed at departure; the annals stamps the day the
   -- rider actually dies — quiet, on the road, reason-free (the
   -- universe does not fake knowledge it lacks; card 165 will
   -- generate causes as facts). Located wherever the row said, a
   -- place worlds map far from every home: witnessed by no one.
   local lost = self.losses:due(self.tick)
   for i = 1, #lost do
      local l = lost[i]
      self:emit{
         kind = l.kind,
         location = l.where,
         magnitude = 1,
         loudness = "quiet",
         payload = { from = l.from, to = l.to },
         causes = { l.cause },
      }
   end
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
      -- Which mechanism carries each event, and when it lands, is
      -- the carriage's answer (card 150): the rows this world
      -- declared, earliest arrival winning. nil is the witness rule
      -- (ADR 0005) — nothing carried it, so for this faction it
      -- never happened; the cursor moves on and no row ever forms.
      -- Rows with an encounter profile (card 151) roll the dice at
      -- departure, one chance per day of exposure, on the courier's
      -- own stream: the fate is sealed when the rider sets out,
      -- exactly as the delay always was, but the loss *lands* on
      -- the day it happens (never before the next dawn — a fate
      -- sealed mid-scan still needs a dawn to be discovered by).
      while faction.cursor < self.annals:len() do
         faction.cursor = faction.cursor + 1
         local e = self.annals:get(faction.cursor)
         local arrives, row =
            self.carriage:arrival(e, faction.name, faction.home)
         if arrives ~= nil and row.encounters ~= nil then
            local enc = row.encounters
            local dice = self.rng:stream("courier")
            for day = 1, arrives - e.tick do
               if dice:int(1, enc.per_day) == 1 then
                  self.losses:schedule(
                     math.max(e.tick + day, self.tick + 1),
                     { kind = enc.lost, where = enc.where,
                        from = e.location, to = faction.home,
                        cause = e.id })
                  arrives = nil
                  break
               end
            end
         end
         if arrives == nil then
            -- unwitnessed, uncarried, or lost: never delivered
         elseif arrives <= self.tick then
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
