-- src/sonder/carriage.lua — the mechanism rows: what carries news,
-- and how fast (card 150; ADR 0005).
--
-- Rung 1 of ADR 0005's migration ladder: the courier's "when does
-- this event reach this faction" arithmetic, extracted from code
-- into rows a world declares. A mechanism is data, never code — a
-- row with five columns on paper (speed, coverage, failure profile,
-- cost, owner); the engine consumes the two today's worlds
-- exercise, speed and coverage, and the remaining columns arrive
-- with the cards that own them (151 failure, 159 cost — the build
-- map in notebook 161). The field model this module retires
-- survives as its own degenerate row: radiated, range "everywhere",
-- no owner, no failure, no cost — a natural medium with infinite
-- range, now declared instead of assumed.
--
-- Two shapes, per the ADR, and only two:
--
--   radiated  — delivery into a neighborhood of the map: the event
--               reaches every faction whose home lies within
--               range[loudness] of the event's location. Range 0
--               means the location itself — which makes quiet
--               self-knowledge exact with no actor identity
--               machinery: your own acts at your own gates are
--               always in earshot.
--   addressed — delivery to a name: the row declares, per event
--               kind, which payload field names the recipient
--               faction (a letter's "buyer"). Only that faction
--               receives, at road pace from the event's location
--               to its home.
--
-- The witness rule (ADR 0005) is the nil case: when no row reaches
-- a faction, the event is never delivered to it — not delayed,
-- never. The annals still holds the truth (law 2); what needs a
-- carrier is the propagating copy.
--
-- Determinism (law 1): rows are an array walked by index; the
-- earliest arrival across reaching rows wins, ties broken by row
-- order; integer arithmetic throughout, no pairs() near an outcome.

local Carriage = {}
Carriage.__index = Carriage

local LOUDNESS = { "loud", "local", "quiet" }

local function validate_row(i, row)
   local where = ("carriage: row %d"):format(i)
   assert(type(row) == "table", where .. " must be a table")
   assert(type(row.name) == "string" and #row.name > 0,
      where .. " needs a name")
   where = ("carriage: %q"):format(row.name)
   assert(math.type(row.speed) == "integer" and row.speed >= 1,
      where .. ": speed must be a positive integer (distance per tick)")
   if row.shape == "radiated" then
      local range = row.range
      if range ~= "everywhere" then
         assert(type(range) == "table",
            where .. ': range must be "everywhere" or a table over loudness')
         for j = 1, #LOUDNESS do
            local r = range[LOUDNESS[j]]
            assert(math.type(r) == "integer" and r >= 0,
               ("%s: range.%s must be a non-negative integer")
               :format(where, LOUDNESS[j]))
         end
      end
   elseif row.shape == "addressed" then
      assert(type(row.to) == "table" and next(row.to) ~= nil,
         where .. ": an addressed row needs to = { [kind] = payload field }")
      for kind, field in pairs(row.to) do
         -- pairs() is legal here, narrowly: validation only accepts
         -- or raises — no outcome depends on visit order.
         assert(type(kind) == "string" and type(field) == "string",
            where .. ": to must map event kind to a payload field name")
      end
   else
      error(where .. ': shape must be "radiated" or "addressed"')
   end
   -- The encounter profile (card 151): the road doesn't kill
   -- riders; what they meet on it does, and exposure scales with
   -- the days spent exposed — one chance-in-per_day draw per day
   -- of travel, on the courier's own stream. Today's sole outcome
   -- is loss, recorded as the world-named event kind (the world
   -- provides the words; the engine provides the dice), located at
   -- the world-named `where`. Deliberately reason-free: the
   -- universe does not fake knowledge it lacks — causes arrive
   -- with the encounter engine (card 165), which will generate
   -- them as facts, never as flavor. Addressed rows only, for now:
   -- per-listener wear on radiated rows is blur, and blur waits
   -- for its first consumer.
   if row.encounters ~= nil then
      assert(row.shape == "addressed",
         where .. ": encounters ride addressed rows only, today")
      local enc = row.encounters
      assert(type(enc) == "table"
            and math.type(enc.per_day) == "integer" and enc.per_day >= 2
            and type(enc.lost) == "string" and #enc.lost > 0
            and type(enc.where) == "string" and #enc.where > 0,
         where .. ": encounters needs { per_day = N >= 2, "
         .. "lost = event kind, where = location }")
   end
end

-- rows: the world's declared mechanisms, in declaration order.
-- distance: the world's map, (from, to, tick) → days, or nil for
-- the pass-through convention (everywhere adjacent, distance 0).
function Carriage.new(rows, distance)
   assert(type(rows) == "table" and #rows >= 1,
      "carriage: a universe needs at least one mechanism row")
   assert(distance == nil or type(distance) == "function",
      "carriage: distance must be a function (from, to, tick) -> days")
   for i = 1, #rows do
      validate_row(i, rows[i])
   end
   return setmetatable({ rows = rows, distance = distance }, Carriage)
end

-- The field row, as data: the licensed placeholder of cards 122 and
-- 161, a natural medium with infinite range at the given speed.
-- Worlds still on rung 1 declare exactly this; the engine defaults
-- to it when a world declares nothing, so the pass-through era
-- (v0.1, everyone omniscient) remains one honest row.
function Carriage.field(speed)
   return { name = "the-field", shape = "radiated", speed = speed,
      range = "everywhere" }
end

-- When does event e reach the faction called name, at home?
-- Returns the arrival tick and the row that carries it, or nil —
-- and nil is a complete answer: nothing carried it, so for this
-- faction it never happened. The returned row is where the caller
-- finds the encounter profile; when several rows reach, the
-- earliest carries (ties to declaration order), and its fate is
-- the delivery's fate — surviving-alternative semantics wait for
-- the first world that declares a kind both radiated and
-- addressed.
function Carriage:arrival(e, name, home)
   local d = 0
   if self.distance then
      d = self.distance(e.location, home, e.tick)
      assert(math.type(d) == "integer" and d >= 0,
         ("carriage: distance(%q, %q) must be a non-negative integer")
         :format(e.location, home))
   end
   local best, carrier
   for i = 1, #self.rows do
      local row = self.rows[i]
      local reaches
      if row.shape == "radiated" then
         reaches = row.range == "everywhere" or d <= row.range[e.loudness]
      else
         local field = row.to[e.kind]
         reaches = field ~= nil and e.payload[field] == name
      end
      if reaches then
         local arrives = e.tick + (d + row.speed - 1) // row.speed
         if best == nil or arrives < best then
            best = arrives
            carrier = row
         end
      end
   end
   return best, carrier
end

return Carriage
