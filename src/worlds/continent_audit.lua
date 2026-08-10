-- src/worlds/continent_audit.lua — Harrow's ledger legs: the first
-- four-column books (grain, iron, salt, cents), which is the
-- multi-commodity case the audit machinery generalized for. Grain
-- has three doors (grown in, eaten and burned out); iron and salt
-- have one each (mined, gathered — nothing consumes them yet, so
-- they accumulate as stores of value, noted honestly); money is
-- closed, the space world's rule: every cent held or riding was
-- founded.

return {
   columns = {
      { key = "grain", negative = "%s holds negative grain (%d sacks)" },
      { key = "iron", negative = "%s holds negative iron (%d ingots)" },
      { key = "salt", negative = "%s holds negative salt (%d measures)" },
      { key = "cents", negative = "%s holds a negative treasury (%d¢)" },
   },
   commodities = { grain = "grain", iron = "iron", salt = "salt" },
   money = "cents",

   effects = {
      ["universe.genesis"] = false,
      ["continent.hunger"] = false,
      ["continent.offer"] = false,
      ["continent.accept"] = false,
      -- a lost letter moves no books: the offer it carried was
      -- never a holding, and the audit checks arithmetic, not luck
      ["continent.letter-lost"] = false,
      ["war.declared"] = false,
      ["war.march"] = false,
      ["war.raid"] = false,
      ["war.peace"] = false,

      ["continent.founded"] = function(s, e, lib)
         local p = e.payload
         lib.enroll(s, p.name, e.location, { grain = p.grain,
            iron = p.iron, salt = p.salt, cents = p.cents })
         local f = s.world.founded or { grain = 0, iron = 0,
            salt = 0, cents = 0 }
         s.world.founded = f
         f.grain = f.grain + p.grain
         f.iron = f.iron + p.iron
         f.salt = f.salt + p.salt
         f.cents = f.cents + p.cents
         s.world.totals = s.world.totals or { grew = 0, mined = 0,
            gathered = 0, eaten = 0, burned = 0 }
      end,

      ["continent.tally"] = function(s, e, lib)
         local p = e.payload
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
         b.grain = b.grain + p.grew - p.eaten
         b.iron = b.iron + p.mined
         b.salt = b.salt + p.gathered
         local t = s.world.totals
         t.grew = t.grew + p.grew
         t.mined = t.mined + p.mined
         t.gathered = t.gathered + p.gathered
         t.eaten = t.eaten + p.eaten
         local road = lib.drift(s, owner, e.tick)
         for _, entry in ipairs(s.legs.columns) do
            local col = entry.key
            if b[col] ~= p[col] then
               lib.mismatch(s, e.id, owner, col, p[col], b[col],
                  road and road[col])
            end
         end
      end,

      ["war.spoils"] = function(s, e, lib)
         local p = e.payload
         local raider, target = s.books[p.raider], s.books[p.target]
         if not (raider and target) then
            lib.flag(s, e.id, "spoils between parties the audit has "
               .. "never met (%s, %s)", p.raider, p.target)
            return
         end
         target.grain = target.grain - p.seized - p.burned
         target.cents = target.cents - p.plunder
         s.world.totals.burned = s.world.totals.burned + p.burned
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
            lib.flag(s, e.id, "a war party returning with no spoils "
               .. "on the road")
            return
         end
         if entry.grain ~= p.seized or entry.cents ~= p.plunder then
            lib.flag(s, e.id, "a return that does not match its spoils")
            return
         end
         raider.grain = raider.grain + p.seized
         raider.cents = raider.cents + p.plunder
         lib.ship(s, e, p.raider,
            { grain = p.seized, cents = p.plunder })
      end,
   },

   identities = function(s, lib, last_id)
      local f = s.world.founded
         or { grain = 0, iron = 0, salt = 0, cents = 0 }
      local t = s.world.totals or { grew = 0, mined = 0,
         gathered = 0, eaten = 0, burned = 0 }
      if s.held.cents + s.on_road.cents ~= f.cents then
         lib.flag(s, last_id, "money is not conserved: %d¢ founded, "
            .. "%d¢ held, %d¢ on roads", f.cents, s.held.cents,
            s.on_road.cents)
      end
      local grain_expected = f.grain + t.grew - t.eaten - t.burned
      if s.held.grain + s.on_road.grain ~= grain_expected then
         lib.flag(s, last_id, "grain is not conserved: expected %d, "
            .. "held %d with %d on roads", grain_expected,
            s.held.grain, s.on_road.grain)
      end
      if s.held.iron + s.on_road.iron ~= f.iron + t.mined then
         lib.flag(s, last_id, "iron is not conserved: expected %d, "
            .. "held %d with %d on roads", f.iron + t.mined,
            s.held.iron, s.on_road.iron)
      end
      if s.held.salt + s.on_road.salt ~= f.salt + t.gathered then
         lib.flag(s, last_id, "salt is not conserved: expected %d, "
            .. "held %d with %d on roads", f.salt + t.gathered,
            s.held.salt, s.on_road.salt)
      end
   end,

   summary = function(report)
      local t = report.world.totals or { grew = 0, mined = 0,
         gathered = 0, eaten = 0, burned = 0 }
      return ("audit: %d¢ held; grain +%d grown −%d eaten −%d burned, "
         .. "%d held; %d iron and %d salt above ground")
         :format(report.held.cents, t.grew, t.eaten, t.burned,
            report.held.grain, report.held.iron, report.held.salt)
   end,
}
