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
--
-- Since card 160 the sentences are the world's: templates are
-- content (worlds/<name>_templates.lua), because how a raid reads
-- is a voice, and voices belong to universes. The machinery here —
-- the follower, the double-dated believes line, the fallback —
-- serves any of them, and a chronicle handed no templates at all
-- still renders every event from the envelope alone.

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
   return ("%s, magnitude %d, %s%s"):format(e.kind, e.magnitude, e.loudness, shown)
end

local function line(e, templates)
   local template = templates and templates[e.kind]
   local sentence = template and template(e) or fallback(e)
   return ("tick %4d · %-8s · %s"):format(e.tick, e.location, sentence)
end

-- A believed event, double-dated: when this mind learned it ← when
-- it happened. The arrow is card 122 — news traveling — and the gap
-- between the two ticks is each line's staleness, visible by
-- subtraction. Same templates as truth: what differs between the
-- chronicle and a believes feed is never the words, only the dates
-- and the order.
local function believed_line(held, templates)
   local template = templates and templates[held.kind]
   local sentence = template and template(held) or fallback(held)
   return ("tick %4d ← tick %4d · %-8s · %s")
      :format(held.learned, held.tick, held.location, sentence)
end

local Chronicle = {}
Chronicle.__index = Chronicle

local function new(annals, templates)
   return setmetatable({
      annals = annals,
      templates = templates,
      cursor = 0,
   }, Chronicle)
end

-- Everything appended since the last call, rendered. Live-following
-- is calling this again later; replaying from the beginning is a
-- fresh chronicle over the same annals.
function Chronicle:lines()
   local out = {}
   while self.cursor < self.annals:len() do
      self.cursor = self.cursor + 1
      out[#out + 1] = line(self.annals:get(self.cursor), self.templates)
   end
   return out
end

return {
   new = new,
   line = line,
   believed_line = believed_line,
}
