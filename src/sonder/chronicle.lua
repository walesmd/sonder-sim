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

-- 1212 → "1,212": money reads better with its thousands marked.
local function comma(n)
   local s, sign = tostring(n), ""
   if s:sub(1, 1) == "-" then
      sign, s = "-", s:sub(2)
   end
   local grouped = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
   return sign .. grouped
end

templates["universe.genesis"] = function(e)
   return ("a universe begins (seed %d)"):format(e.payload.seed)
end

templates["civ.founded"] = function(e)
   return ("the %s enter history with %d sacks of grain and %s¢"):format(
      e.payload.name, e.payload.grain, comma(e.payload.cents))
end

templates["civ.tally"] = function(e)
   return ("the day's books: %d sacks in the granary (+%d, −%d), %s¢ in the treasury")
      :format(e.payload.stock, e.payload.harvested, e.payload.eaten,
         comma(e.payload.cents))
end

templates["grain.hunger"] = function(e)
   return ("hunger — the granaries came up %d %s short"):format(
      e.payload.shortfall,
      e.payload.shortfall == 1 and "sack" or "sacks")
end

templates["market.order"] = function(e)
   if e.payload.side == "buy" then
      return ("a bid for %d sacks at up to %d¢"):format(
         e.payload.units, e.payload.limit)
   end
   return ("%d sacks on offer at %d¢ or better"):format(
      e.payload.units, e.payload.limit)
end

templates["market.trade"] = function(e)
   return ("%d sacks pass from the %s to the %s at %d¢ (%s¢ paid)")
      :format(e.payload.units, e.payload.seller, e.payload.buyer,
         e.payload.price, comma(e.payload.total))
end

templates["market.price"] = function(e)
   if e.payload.delta == 0 then
      return ("grain holds at %d¢"):format(e.payload.price)
   end
   return ("grain settles at %d¢ (%+d)"):format(e.payload.price,
      e.payload.delta)
end

templates["war.declared"] = function(e)
   if e.payload.reason == "hunger" then
      return ("the %s declare war on the %s — %d hungry days were the last insult")
         :format(e.payload.aggressor, e.payload.target, e.payload.measure)
   end
   return ("the %s declare war on the %s — grain at %d¢ was the last insult")
      :format(e.payload.aggressor, e.payload.target, e.payload.measure)
end

templates["cargo.shipped"] = function(e)
   return ("the %s dispatch %d %s to the %s")
      :format(e.payload.sender, e.payload.units, e.payload.commodity,
         e.payload.recipient)
end

templates["cargo.delivered"] = function(e)
   return ("%d %s from the %s reach the %s")
      :format(e.payload.units, e.payload.commodity, e.payload.sender,
         e.payload.recipient)
end

templates["payment.shipped"] = function(e)
   return ("the %s send %d¢ to the %s")
      :format(e.payload.payer, e.payload.amount, e.payload.payee)
end

templates["payment.delivered"] = function(e)
   return ("%d¢ from the %s reach the %s")
      :format(e.payload.amount, e.payload.payer, e.payload.payee)
end

templates["war.returned"] = function(e)
   return ("the %s war party returns home with %d sacks and %d¢")
      :format(e.payload.raider, e.payload.seized, e.payload.plunder)
end

templates["war.march"] = function(e)
   return ("a %s war party rides out against the %s (force %d)")
      :format(e.payload.raider, e.payload.target, e.payload.force)
end

templates["war.raid"] = function(e)
   return ("a %s war party falls on the %s granaries (force %d)")
      :format(e.payload.raider, e.payload.target, e.payload.force)
end

templates["war.spoils"] = function(e)
   local p = e.payload
   if p.seized == 0 and p.plunder == 0 and p.burned == 0 then
      return ("the %s raiders find the %s stores bare"):format(
         p.raider, p.target)
   end
   local torched = p.burned > 0
      and (" and put %d to the torch"):format(p.burned) or ""
   return ("the %s raiders carry off %d sacks and %s¢ from the %s%s"):format(
      p.raider, p.seized, comma(p.plunder), p.target, torched)
end

templates["war.peace"] = function(e)
   return ("the %s sheathe — grain at %d¢ buys more than blood"):format(
      e.payload.name, e.payload.price)
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
   return ("%s, magnitude %d, %s%s"):format(e.kind, e.magnitude, e.loudness, shown)
end

local function line(e)
   local template = templates[e.kind]
   local sentence = template and template(e) or fallback(e)
   return ("tick %4d · %-8s · %s"):format(e.tick, e.location, sentence)
end

-- A believed event, double-dated: when this mind learned it ← when
-- it happened. The arrow is card 122 — news traveling — and the gap
-- between the two ticks is each line's staleness, visible by
-- subtraction. Same templates as truth: what differs between the
-- chronicle and a believes feed is never the words, only the dates
-- and the order.
local function believed_line(held)
   local template = templates[held.kind]
   local sentence = template and template(held) or fallback(held)
   return ("tick %4d ← tick %4d · %-8s · %s")
      :format(held.learned, held.tick, held.location, sentence)
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
   believed_line = believed_line,
   -- Exported for the coverage spec: this repo's own viewer must have
   -- a sentence for every kind in this repo's vocabulary. Not sim API.
   _templates = templates,
}
