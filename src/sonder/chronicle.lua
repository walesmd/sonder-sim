-- src/sonder/chronicle.lua — the first projection: readable lines.
--
-- A chronicle is a viewer, not a subsystem: it reads the annals
-- through get(), keeps a cursor, and the sim runs bit-identically
-- whether zero or a thousand of these exist (law 4). The strictness
-- asymmetry lands here: the annals rejects what it doesn't recognize,
-- because writes are forever; a viewer renders what it doesn't
-- recognize, because readers age. This chronicle will one day meet
-- annals written by engine versions that don't exist yet — lineage,
-- synopsis, and seed reports all guarantee it — and an unknown kind
-- isn't corruption, it's the future. The generic fallback below is
-- built from the envelope, which every event of every era carries.

local templates = {}

templates["universe.genesis"] = function(e)
   return ("a universe begins (seed %d)"):format(e.payload.seed)
end

templates["market.drift"] = function(e)
   if e.payload.drift == 0 then
      return "the market holds steady"
   end
   return ("the market drifts %+d"):format(e.payload.drift)
end

templates["war.muster"] = function(e)
   if e.payload.muster == 0 then
      return "the war office musters nobody"
   end
   return ("the war office musters %d %s"):format(e.payload.muster,
      e.payload.muster == 1 and "levy" or "levies")
end

-- The unknown-kind fallback. pairs() is allowed here — this is a
-- viewer, and no outcome can ever read a chronicle — but the keys
-- are sorted anyway: the same log should render the same feed on
-- every machine, because golden tests and diffing two feeds both
-- depend on it.
local function fallback(e)
   local keys = {}
   for k in pairs(e.payload) do
      keys[#keys + 1] = tostring(k)
   end
   table.sort(keys)
   for i = 1, #keys do
      local k = keys[i]
      keys[i] = ("%s=%s"):format(k, tostring(e.payload[k]))
   end
   local shown = #keys > 0 and (" — " .. table.concat(keys, ", ")) or ""
   return ("%s, magnitude %d, %s%s"):format(e.kind, e.magnitude, e.visibility, shown)
end

local function line(e)
   local template = templates[e.kind]
   local sentence = template and template(e) or fallback(e)
   return ("tick %4d · %-8s · %s"):format(e.tick, e.location, sentence)
end

local Chronicle = {}
Chronicle.__index = Chronicle

local function new(annals)
   return setmetatable({ annals = annals, cursor = 0 }, Chronicle)
end

-- Everything appended since the last call, rendered. Live-following
-- is calling this again later; replaying from the beginning is a
-- fresh chronicle over the same annals.
function Chronicle:lines()
   local out = {}
   while self.cursor < self.annals:len() do
      self.cursor = self.cursor + 1
      out[#out + 1] = line(self.annals:get(self.cursor))
   end
   return out
end

return {
   new = new,
   line = line,
   -- Exported for the coverage spec: this repo's own viewer must have
   -- a sentence for every kind in this repo's vocabulary. Not sim API.
   _templates = templates,
}
