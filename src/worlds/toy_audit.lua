-- src/worlds/toy_audit.lua — the toy space world's ledger legs:
-- what each of its kinds does to the books, and the conservation
-- laws its closed economy answers to. Content, not engine (card
-- 160) — these lived inside the audit until the office proved the
-- fold was framework and the meaning wasn't.
--
-- The identities, unchanged since card 120: money has no doors at
-- all — every cent held or riding was founded. Matter has exactly
-- two, both recorded events: harvests grow it, eating and the torch
-- destroy it. Movement appears in neither identity, but since card
-- 153 some of what exists is between places, so each carries a road
-- term.

return {
   columns = {
      { key = "grain", negative = "%s holds negative grain (%d sacks)" },
      { key = "cents", negative = "%s holds a negative treasury (%d¢)" },
   },
   commodities = { grain = "grain" },
   money = "cents",

   effects = {
      ["universe.genesis"] = false,
      ["grain.hunger"] = false,
      ["market.order"] = false,
      ["market.price"] = false,
      ["war.declared"] = false,
      ["war.march"] = false,
      ["war.raid"] = false,
      ["war.peace"] = false,

      ["civ.founded"] = function(s, e, lib)
         local p = e.payload
         lib.enroll(s, p.name, e.location,
            { grain = p.grain, cents = p.cents })
         s.world.founded = s.world.founded
            or { grain = 0, cents = 0 }
         s.world.founded.grain = s.world.founded.grain + p.grain
         s.world.founded.cents = s.world.founded.cents + p.cents
      end,

      ["civ.tally"] = function(s, e, lib)
         local p = e.payload
         -- a tally speaks from a civ's home; find whose (founding
         -- order, an array walk — the reverse map isn't kept)
         local owner
         for i = 1, #s.names do
            if s.seats[s.names[i]] == e.location then
               owner = s.names[i]
            end
         end
         local b = owner and s.books[owner]
         if not b then
            lib.flag(s, e.id, "a tally from %s, where nobody was founded",
               e.location)
            return
         end
         -- harvested and eaten are the day's physical record — the
         -- only one there is, so the fold trusts them; stock and
         -- cents are the civ's *claim*, and claims get checked.
         b.grain = b.grain + p.harvested - p.eaten
         local t = s.world.totals or { harvested = 0, eaten = 0,
            burned = 0, seized = 0, plunder = 0,
            traded_units = 0, traded_cents = 0 }
         s.world.totals = t
         t.harvested = t.harvested + p.harvested
         t.eaten = t.eaten + p.eaten
         local road = lib.drift(s, owner, e.tick)
         if b.grain ~= p.stock then
            lib.mismatch(s, e.id, owner, "grain", p.stock, b.grain,
               road and road.grain)
         end
         if b.cents ~= p.cents then
            lib.mismatch(s, e.id, owner, "cents", p.cents, b.cents,
               road and road.cents)
         end
      end,

      ["market.trade"] = function(s, e, lib)
         -- the agreement, not the movement (card 153): what's left
         -- to check is the arithmetic of the promise
         local p = e.payload
         if p.total ~= p.units * p.price then
            lib.flag(s, e.id, "trade total %d¢ is not %d units × %d¢",
               p.total, p.units, p.price)
         end
         if not (s.books[p.buyer] and s.books[p.seller]) then
            lib.flag(s, e.id, "a trade between parties the audit has "
               .. "never met (%s, %s)", p.buyer, p.seller)
            return
         end
         local t = s.world.totals
         t.traded_units = t.traded_units + p.units
         t.traded_cents = t.traded_cents + p.total
      end,

      ["war.spoils"] = function(s, e, lib)
         -- the verdict and a departure leg in one: the target's
         -- losses happen where the raid did; the seized goods ride
         -- home with the party, credited only at war.returned
         local p = e.payload
         local raider, target = s.books[p.raider], s.books[p.target]
         if not (raider and target) then
            lib.flag(s, e.id, "spoils between parties the audit has "
               .. "never met (%s, %s)", p.raider, p.target)
            return
         end
         target.grain = target.grain - p.seized - p.burned
         target.cents = target.cents - p.plunder
         local t = s.world.totals
         t.seized = t.seized + p.seized
         t.plunder = t.plunder + p.plunder
         t.burned = t.burned + p.burned
         lib.embark(s, e, { grain = p.seized, cents = p.plunder })
         lib.ship(s, e, p.target,
            { grain = -p.seized - p.burned, cents = -p.plunder })
      end,

      ["war.returned"] = function(s, e, lib)
         local p = e.payload
         local raider = s.books[p.raider]
         if not raider then
            lib.flag(s, e.id, "a war party returning to %s, whom the "
               .. "audit has never met", p.raider)
            return
         end
         local entry = lib.disembark(s, e.causes[1])
         if not entry then
            lib.flag(s, e.id, "a war party returning with no spoils on "
               .. "the road")
            return
         end
         if entry.grain ~= p.seized or entry.cents ~= p.plunder then
            lib.flag(s, e.id, "a return that does not match its spoils: "
               .. "%d sacks and %d¢ against %d and %d on the road",
               p.seized, p.plunder, entry.grain or 0, entry.cents or 0)
            return
         end
         raider.grain = raider.grain + p.seized
         raider.cents = raider.cents + p.plunder
         lib.ship(s, e, p.raider,
            { grain = p.seized, cents = p.plunder })
      end,
   },

   identities = function(s, lib, last_id)
      local founded = s.world.founded or { grain = 0, cents = 0 }
      local t = s.world.totals or { harvested = 0, eaten = 0, burned = 0 }
      if s.held.cents + s.on_road.cents ~= founded.cents then
         lib.flag(s, last_id, "money is not conserved: %d¢ founded, "
            .. "%d¢ held, %d¢ on roads", founded.cents, s.held.cents,
            s.on_road.cents)
      end
      local grain_expected = founded.grain + t.harvested
         - t.eaten - t.burned
      if s.held.grain + s.on_road.grain ~= grain_expected then
         lib.flag(s, last_id, "matter is not conserved: expected %d "
            .. "sacks (%d founded + %d harvested − %d eaten − %d "
            .. "burned), held %d with %d on roads", grain_expected,
            founded.grain, t.harvested, t.eaten, t.burned,
            s.held.grain, s.on_road.grain)
      end
   end,

   -- One line for the host to print: the world knows what its own
   -- books are called (main.lua --audit).
   summary = function(report)
      local function comma(n)
         local grouped = tostring(n):reverse():gsub("(%d%d%d)", "%1,")
            :reverse():gsub("^,", "")
         return grouped
      end
      local f = report.world.founded or { grain = 0, cents = 0 }
      local t = report.world.totals or { harvested = 0, eaten = 0, burned = 0 }
      return ("audit: %s¢ founded, %s¢ held; %s sacks founded, +%s "
         .. "harvested, −%s eaten, −%s burned, %s held")
         :format(comma(f.cents), comma(report.held.cents),
            comma(f.grain), comma(t.harvested), comma(t.eaten),
            comma(t.burned), comma(report.held.grain))
   end,
}
