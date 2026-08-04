-- src/worlds/space_templates.lua — the space world's own sentences:
-- how its kinds read in a chronicle. Content, not engine (card 160,
-- the last leak): the chronicle's follower and fallback machinery
-- serve every world; the prose was always this world's voice. Moved
-- verbatim — the golden feed's bytes prove it.

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

return templates
