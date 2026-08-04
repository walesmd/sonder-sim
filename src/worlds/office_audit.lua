-- src/worlds/office_audit.lua — Bellwether & Co.'s ledger legs: the
-- project's first OPEN system declaring itself to the audit. Money
-- has two mouths here — revenue in when a client pays, daily living
-- and rent out through every tally's spent column — and work has
-- two of its own: made at desks, delivered out the door. The audit
-- machinery neither knows nor cares that this economy breathes; the
-- identities below say exactly how.

return {
   columns = {
      { key = "work", negative = "%s holds negative work (%d units)" },
      { key = "cents", negative = "%s holds a negative treasury (%d¢)" },
   },
   commodities = { work = "work" },
   money = "cents",

   effects = {
      ["universe.genesis"] = false,
      ["office.pitch"] = false,
      ["office.deal_lost"] = false,

      ["office.hired"] = function(s, e, lib)
         local p = e.payload
         lib.enroll(s, p.name, e.location, { work = 0, cents = p.cents })
         s.world.founded = s.world.founded or { cents = 0 }
         s.world.founded.cents = s.world.founded.cents + p.cents
         s.world.totals = s.world.totals
            or { made = 0, spent = 0, delivered = 0, revenue = 0 }
      end,

      ["office.tally"] = function(s, e, lib)
         local p = e.payload
         local b = s.books[e.location] -- a person is a place
         if not b then
            lib.flag(s, e.id, "a tally from %s, whom nobody hired",
               e.location)
            return
         end
         -- made and spent are the day's physical record and two of
         -- the open system's doors; work and cents are claims, and
         -- claims get checked
         b.work = b.work + p.made
         b.cents = b.cents - p.spent
         local t = s.world.totals
         t.made = t.made + p.made
         t.spent = t.spent + p.spent
         local road = lib.drift(s, e.location, e.tick)
         if b.work ~= p.work then
            lib.mismatch(s, e.id, e.location, "work", p.work, b.work,
               road and road.work)
         end
         if b.cents ~= p.cents then
            lib.mismatch(s, e.id, e.location, "cents", p.cents, b.cents,
               road and road.cents)
         end
      end,

      ["office.deal"] = function(s, e, lib)
         local p = e.payload
         if p.total ~= p.units * p.price then
            lib.flag(s, e.id, "deal total %d¢ is not %d units × %d¢",
               p.total, p.units, p.price)
         end
         if not s.books[p.seller] then
            lib.flag(s, e.id, "a deal by %s, whom nobody hired", p.seller)
         end
      end,

      ["office.delivered"] = function(s, e, lib)
         -- the work column's outbound door: finished units leave
         -- the company for a client (lawful because recorded)
         local p = e.payload
         local b = s.books[p.seller]
         if not b then
            lib.flag(s, e.id, "a delivery by %s, whom nobody hired",
               p.seller)
            return
         end
         b.work = b.work - p.units
         s.world.totals.delivered = s.world.totals.delivered + p.units
         lib.ship(s, e, p.seller, { work = -p.units })
      end,

      ["office.revenue"] = function(s, e, lib)
         -- the cents column's inbound mouth: a client's money
         -- arrives in the treasury mara keeps
         local p = e.payload
         local b = s.books["mara"]
         if not b then
            lib.flag(s, e.id, "revenue before anyone kept books")
            return
         end
         b.cents = b.cents + p.amount
         s.world.totals.revenue = s.world.totals.revenue + p.amount
         lib.ship(s, e, "mara", { cents = p.amount })
      end,
   },

   identities = function(s, lib, last_id)
      local founded = s.world.founded or { cents = 0 }
      local t = s.world.totals
         or { made = 0, spent = 0, delivered = 0, revenue = 0 }
      -- an open system's money: what was brought in savings plus
      -- what clients paid, less what living and rent burned, is
      -- what's held or riding — to the cent
      local cents_expected = founded.cents + t.revenue - t.spent
      if s.held.cents + s.on_road.cents ~= cents_expected then
         lib.flag(s, last_id, "money is not conserved: expected %d¢ "
            .. "(%d¢ founded + %d¢ revenue − %d¢ spent), held %d¢ "
            .. "with %d¢ on roads", cents_expected, founded.cents,
            t.revenue, t.spent, s.held.cents, s.on_road.cents)
      end
      -- and its work: made less delivered is held or riding
      local work_expected = t.made - t.delivered
      if s.held.work + s.on_road.work ~= work_expected then
         lib.flag(s, last_id, "work is not conserved: expected %d "
            .. "units (%d made − %d delivered), held %d with %d on "
            .. "roads", work_expected, t.made, t.delivered,
            s.held.work, s.on_road.work)
      end
   end,

   summary = function(report)
      local t = report.world.totals
         or { made = 0, spent = 0, delivered = 0, revenue = 0 }
      return ("audit: %d¢ revenue in, %d¢ spent out, %d¢ held; %d "
         .. "units made, %d delivered, %d held")
         :format(t.revenue, t.spent, report.held.cents, t.made,
            t.delivered, report.held.work)
   end,
}
