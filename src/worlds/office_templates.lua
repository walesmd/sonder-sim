-- src/worlds/office_templates.lua — how Bellwether & Co. reads in a
-- chronicle: the office's own voice, including its own wording for
-- the framework's cargo and payment kinds — a shipment between
-- desks is not a caravan, and the sentence should know it.

local templates = {}

templates["universe.genesis"] = function(e)
   return ("Bellwether & Co. opens its doors (seed %d)")
      :format(e.payload.seed)
end

templates["office.hired"] = function(e)
   local p = e.payload
   if p.salary == 0 then
      return ("%s keeps the company books: %d¢ in the treasury")
         :format(p.name, p.cents)
   end
   return ("%s joins as %s, %d¢ a week"):format(p.name, p.role, p.salary)
end

templates["office.tally"] = function(e)
   local p = e.payload
   return ("the day's books: %d made, %d¢ spent — %d work on hand, %d¢ in pocket")
      :format(p.made, p.spent, p.work, p.cents)
end

templates["office.pitch"] = function(e)
   return ("%s works the phones (%d units ready)")
      :format(e.payload.seller, e.magnitude)
end

templates["office.deal"] = function(e)
   local p = e.payload
   return ("a client says yes to %s: %d units at %d¢ (%d¢)")
      :format(p.seller, p.units, p.price, p.total)
end

templates["office.deal_lost"] = function(e)
   return ("a client tells %s no, quietly"):format(e.payload.seller)
end

templates["office.delivered"] = function(e)
   local p = e.payload
   return ("%d units go out the door for a client of %s")
      :format(p.units, p.seller)
end

templates["office.revenue"] = function(e)
   local p = e.payload
   return ("%d¢ arrives in the treasury — %s's client pays")
      :format(p.amount, p.seller)
end

templates["cargo.shipped"] = function(e)
   local p = e.payload
   return ("%s sends %d %s along to %s")
      :format(p.sender, p.units, p.commodity, p.recipient)
end

templates["cargo.delivered"] = function(e)
   local p = e.payload
   return ("%d %s from %s lands on %s's desk")
      :format(p.units, p.commodity, p.sender, p.recipient)
end

templates["payment.shipped"] = function(e)
   local p = e.payload
   return ("%s sends %d¢ to %s"):format(p.payer, p.amount, p.payee)
end

templates["payment.delivered"] = function(e)
   local p = e.payload
   return ("%d¢ from %s reaches %s"):format(p.amount, p.payer, p.payee)
end

return templates
