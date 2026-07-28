-- src/sonder/annals.lua — the append-only event log.
--
-- Law 2: nothing "happens" except an append here; every state view,
-- chronicle, and statistic is a projection of this array. An event's
-- id is its position — the nth append is event n — deterministic
-- because emission order is deterministic (systems run in array
-- order, law 1). Strictness is asymmetric across the log's two
-- sides, on purpose: append() rejects anything malformed with a hard
-- error, because a bad event written today is corrupted history
-- forever, while viewers stay tolerant of kinds they don't know,
-- because readers age (see chronicle.lua). And the log keeps no
-- reference to caller tables and hands out copies, never rows:
-- history that could be edited in place would be append-only by
-- politeness, and laws get structure.

local default_vocabulary = require "sonder.vocabulary"

local Annals = {}
Annals.__index = Annals

local GENESIS = "universe.genesis"

function Annals.new(vocabulary)
   vocabulary = vocabulary or default_vocabulary
   local loudnesses = {}
   for i = 1, #vocabulary.loudnesses do
      loudnesses[vocabulary.loudnesses[i]] = true
   end
   return setmetatable({
      vocabulary = vocabulary,
      loudnesses = loudnesses,
      events = {},
   }, Annals)
end

function Annals:len()
   return #self.events
end

-- The envelope: every event of every era carries exactly these
-- (plus the id and tick the annals stamps itself).
local ENVELOPE = { "kind", "location", "magnitude", "loudness", "payload", "causes" }
local IS_ENVELOPE = {}
for i = 1, #ENVELOPE do
   IS_ENVELOPE[ENVELOPE[i]] = true
end

local function count_keys(t)
   local n = 0
   for _ in pairs(t) do
      n = n + 1
   end
   return n
end

-- Name the strangers, sorted so the error reads the same on every
-- machine. (pairs() can't touch an outcome here — errors abort the
-- run — but a habit is cheaper than a judgment call.)
local function strangers(t, known)
   local out = {}
   for k in pairs(t) do
      if not known[k] then
         out[#out + 1] = tostring(k)
      end
   end
   table.sort(out)
   return table.concat(out, ", ")
end

-- Validate, copy, append. Returns the new event's id; raises on
-- anything malformed — there is no soft-failure path into the log.
function Annals:append(tick, spec)
   assert(math.type(tick) == "integer" and tick >= 0,
      "annals: tick must be a non-negative integer")
   local newest = self.events[#self.events]
   assert(not newest or newest.tick <= tick,
      "annals: time does not flow backwards")
   assert(type(spec) == "table", "annals: event must be a table")

   local kind = spec.kind
   local entry = type(kind) == "string" and self.vocabulary.kinds[kind] or nil
   if not entry then
      error(("annals: unregistered kind %q"):format(tostring(kind)))
   end

   assert(type(spec.location) == "string" and #spec.location > 0,
      "annals: " .. kind .. ": location must be a non-empty string")
   assert(math.type(spec.magnitude) == "integer",
      "annals: " .. kind .. ": magnitude must be an integer")
   assert(type(spec.loudness) == "string" and self.loudnesses[spec.loudness],
      "annals: " .. kind .. ": loudness must be one of the declared set")

   -- Payload: exactly the declared fields, correctly typed, nothing
   -- else. Copied field by field off the declaration array, so the
   -- caller's table is never stored and never iterated.
   assert(type(spec.payload) == "table",
      "annals: " .. kind .. ": payload must be a table")
   local declared = entry.payload
   local payload = {}
   for i = 1, #declared do
      local name, want = declared[i][1], declared[i][2]
      local value = spec.payload[name]
      if want == "integer" then
         if math.type(value) ~= "integer" then
            error(("annals: %s: payload field %q must be an integer"):format(kind, name))
         end
      elseif type(value) ~= "string" then
         error(("annals: %s: payload field %q must be a string"):format(kind, name))
      end
      payload[name] = value
   end
   if count_keys(spec.payload) ~= #declared then
      error(("annals: %s: unknown payload fields: %s")
         :format(kind, strangers(spec.payload, payload)))
   end

   -- Causes: something always causes an event — markets don't just
   -- move, wars don't just start. Only genesis may cite nothing, and
   -- genesis happens exactly once, as event 1. A cause must be the id
   -- of an event already in the log: only the past causes the present.
   assert(type(spec.causes) == "table",
      "annals: " .. kind .. ": causes must be a table")
   if kind == GENESIS then
      assert(#self.events == 0, "annals: genesis happens once, first")
      assert(next(spec.causes) == nil, "annals: genesis is the uncaused event")
   else
      assert(#spec.causes > 0,
         "annals: " .. kind .. ": every event cites at least one cause"
         .. " (only genesis is uncaused)")
   end
   local causes = {}
   for i = 1, #spec.causes do
      local c = spec.causes[i]
      if math.type(c) ~= "integer" or c < 1 or c > #self.events then
         error(("annals: %s: cause %s is not the id of a past event")
            :format(kind, tostring(c)))
      end
      causes[i] = c
   end
   if count_keys(spec.causes) ~= #causes then
      error("annals: " .. kind .. ": causes must be a plain array of ids")
   end

   -- All six envelope fields checked present above, so any surplus
   -- key is a stranger.
   if count_keys(spec) ~= #ENVELOPE then
      error(("annals: %s: unknown envelope fields: %s")
         :format(kind, strangers(spec, IS_ENVELOPE)))
   end

   local id = #self.events + 1
   self.events[id] = {
      id = id,
      tick = tick,
      kind = kind,
      location = spec.location,
      magnitude = spec.magnitude,
      loudness = spec.loudness,
      payload = payload,
      causes = causes,
   }
   return id
end

-- A copy, never the row: what get() returns can be scribbled on
-- without rewriting history. nil for ids history hasn't reached.
function Annals:get(id)
   if math.type(id) ~= "integer" then
      return nil
   end
   local e = self.events[id]
   if not e then
      return nil
   end
   local declared = self.vocabulary.kinds[e.kind].payload
   local payload = {}
   for i = 1, #declared do
      local name = declared[i][1]
      payload[name] = e.payload[name]
   end
   return {
      id = e.id,
      tick = e.tick,
      kind = e.kind,
      location = e.location,
      magnitude = e.magnitude,
      loudness = e.loudness,
      payload = payload,
      causes = table.move(e.causes, 1, #e.causes, 1, {}),
   }
end

return Annals
