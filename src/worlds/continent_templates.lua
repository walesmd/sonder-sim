-- src/worlds/continent_templates.lua — how Harrow reads in a
-- chronicle: a continent's voice for its own kinds and its own
-- wording for the shared grammar — a caravan is not a memo.

local templates = {}

templates["universe.genesis"] = function(e)
   return ("a continent wakes (seed %d)"):format(e.payload.seed)
end

templates["continent.founded"] = function(e)
   local p = e.payload
   return ("the %s enter history: %d grain, %d iron, %d salt, %d¢")
      :format(p.name, p.grain, p.iron, p.salt, p.cents)
end

templates["continent.tally"] = function(e)
   local p = e.payload
   return ("the day's books: +%d grown +%d mined +%d gathered, −%d eaten — %d grain, %d iron, %d salt, %d¢")
      :format(p.grew, p.mined, p.gathered, p.eaten,
         p.grain, p.iron, p.salt, p.cents)
end

templates["continent.hunger"] = function(e)
   return ("the granaries come up %d short"):format(e.payload.shortfall)
end

templates["continent.offer"] = function(e)
   local p = e.payload
   return ("a letter rides from the %s to the %s: %d %s at %d¢ apiece")
      :format(p.seller, p.buyer, p.units, p.commodity, p.price)
end

templates["continent.accept"] = function(e)
   local p = e.payload
   return ("the %s say yes to the %s: %d %s for %d¢")
      :format(p.buyer, p.seller, p.units, p.commodity, p.total)
end

templates["continent.letter-lost"] = function(e)
   local p = e.payload
   return ("somewhere on the road from %s to %s, a letter is lost")
      :format(p.from, p.to)
end

templates["war.declared"] = function(e)
   local p = e.payload
   return ("the %s declare war on the %s — %d hungry days were the last insult")
      :format(p.aggressor, p.target, p.measure)
end

templates["war.march"] = function(e)
   local p = e.payload
   return ("a %s war party rides out against the %s (force %d)")
      :format(p.raider, p.target, p.force)
end

templates["war.raid"] = function(e)
   local p = e.payload
   return ("a %s war party falls on the %s granaries (force %d)")
      :format(p.raider, p.target, p.force)
end

templates["war.spoils"] = function(e)
   local p = e.payload
   if p.seized == 0 and p.plunder == 0 and p.burned == 0 then
      return ("the %s raiders find the %s stores bare")
         :format(p.raider, p.target)
   end
   return ("the %s raiders carry off %d sacks and %d¢ from the %s and put %d to the torch")
      :format(p.raider, p.seized, p.plunder, p.target, p.burned)
end

templates["war.returned"] = function(e)
   local p = e.payload
   return ("the %s war party returns through the passes with %d sacks and %d¢")
      :format(p.raider, p.seized, p.plunder)
end

templates["war.peace"] = function(e)
   local p = e.payload
   return ("the %s sheathe — %d sacks in the granary buy more than blood")
      :format(p.name, p.measure)
end

templates["cargo.shipped"] = function(e)
   local p = e.payload
   return ("a caravan leaves the %s for the %s: %d %s")
      :format(p.sender, p.recipient, p.units, p.commodity)
end

templates["cargo.delivered"] = function(e)
   local p = e.payload
   return ("a caravan from the %s reaches the %s: %d %s")
      :format(p.sender, p.recipient, p.units, p.commodity)
end

templates["payment.shipped"] = function(e)
   local p = e.payload
   return ("a strongbox leaves the %s for the %s: %d¢")
      :format(p.payer, p.payee, p.amount)
end

templates["payment.delivered"] = function(e)
   local p = e.payload
   return ("a strongbox from the %s reaches the %s: %d¢")
      :format(p.payer, p.payee, p.amount)
end

return templates
