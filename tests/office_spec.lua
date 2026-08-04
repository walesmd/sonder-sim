-- tests/office_spec.lua — Bellwether & Co. kept honest: the second
-- world boots on an unmodified engine, its economy flows, and its
-- chartered KPI story — the unplanned rumor cascade — precipitates
-- from beliefs and social distance, unprompted.

local office = require "worlds.office"
local Seal = require "sonder.seal"

describe("the office", function()
   it("runs deterministically: same seed, same company, seal for seal", function()
      local a, b = office(7), office(7)
      a:run(120)
      b:run(120)
      assert.equal(Seal.of(a.annals):hex(), Seal.of(b.annals):hex())
   end)

   it("the business actually runs: work flows, deals close, salaries ride", function()
      local u = office(7)
      u:run(120)
      local shipped, delivered, deals, revenue, paydays, lost = 0, 0, 0, 0, 0, 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "cargo.shipped" then
            shipped = shipped + e.payload.units
         elseif e.kind == "cargo.delivered" then
            delivered = delivered + e.payload.units
         elseif e.kind == "office.deal" then
            deals = deals + 1
         elseif e.kind == "office.revenue" then
            revenue = revenue + e.payload.amount
         elseif e.kind == "payment.delivered" then
            paydays = paydays + 1
         elseif e.kind == "office.deal_lost" then
            lost = lost + 1
         end
      end
      assert.is_true(shipped > 0, "no work ever left a desk")
      assert.is_true(delivered > 0, "no work ever arrived")
      assert.is_true(shipped >= delivered, "more arrived than departed")
      assert.is_true(deals > 0, "a company that never sold anything")
      assert.equal(deals * 660, revenue) -- every deal's money arrived
      assert.is_true(paydays > 0, "nobody ever got paid")
      assert.is_true(lost > 0, "a company that never heard no")
   end)

   it("the rumor cascade: behavior changes before the office collectively knows", function()
      -- The chartered KPI, replayed from truth. A client says no,
      -- quietly, at one seller's desk. The seller goes silent the
      -- next day. But the news is four hops from the make-team, so
      -- for several days the org is behaving differently — pitches
      -- stopped, soon production dimming — while some of its people
      -- have not yet heard why. Only social distance can produce
      -- this shape.
      local u = office(7)
      u:run(120)
      local lost_tick, lost_seller
      local pitches = {} -- seller → array of ticks
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "office.deal_lost" and not lost_tick then
            lost_tick, lost_seller = e.tick, e.payload.seller
         elseif e.kind == "office.pitch" then
            local s = e.payload.seller
            pitches[s] = pitches[s] or {}
            pitches[s][#pitches[s] + 1] = e.tick
         end
      end
      assert.is_not_nil(lost_tick, "no client ever said no")

      -- the seller was active going in, and went silent after
      local before, after = false, false
      for _, t in ipairs(pitches[lost_seller]) do
         if t >= lost_tick - 3 and t <= lost_tick then
            before = true
         end
         if t > lost_tick and t <= lost_tick + 5 then
            after = true
         end
      end
      assert.is_true(before, "the seller wasn't even pitching")
      assert.is_false(after, "the seller shrugged the loss off")

      -- while the make-team was still days from hearing: the news
      -- travels the chart, and the chart is long
      local lag = u.distance(lost_seller, "dane", lost_tick)
      assert.is_true(lag >= 3,
         "the org chart should keep makers days behind sales news")

      -- and dane's private chronology agrees, to the tick: learned
      -- exactly the road late
      local store
      for i = 1, #u.factions do
         if u.factions[i].name == "dane" then
            store = u.factions[i].store
         end
      end
      for _, held in ipairs(store:chronology()) do
         if held.kind == "office.deal_lost" and held.tick == lost_tick then
            assert.equal(lost_tick + lag, held.learned)
         end
      end
   end)

   it("an employee's newspaper reads like a life", function()
      -- The believes viewer was built for empires; it must work for
      -- a person with no changes (the litmus, executed). Everything
      -- dane knows arrived at his desk no earlier than it happened.
      local u = office(7)
      u:run(60)
      local store
      for i = 1, #u.factions do
         if u.factions[i].name == "dane" then
            store = u.factions[i].store
         end
      end
      local rows = store:chronology()
      assert.is_true(#rows > 0)
      for i = 1, #rows do
         assert.is_true(rows[i].learned >= rows[i].tick)
      end
      -- and knowledge only grows
      assert.is_true(#store:chronology(30) <= #store:chronology(60))
   end)
end)
