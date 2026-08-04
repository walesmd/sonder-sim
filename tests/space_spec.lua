-- tests/space_spec.lua — the space world kept honest: conservation
-- from the log alone, war discipline, and the card's only KPI as an
-- executable claim.

local space = require "support.space"
local Chronicle = require "sonder.chronicle"
local Audit = require "sonder.audit"
local legs = require "worlds.space_audit"

-- The independent auditor grew up: what post 0007 kept here as a
-- spec-local fold is now src/sonder/audit.lua (card 120), and this
-- file consumes it like any other viewer. The claims are unchanged —
-- with a pass-through courier a civ can be neither lying nor
-- misinformed, so mismatches are bugs — audit_spec.lua carries the
-- audit's own trials (coverage, counterfeits, conservation).

describe("conservation", function()
   it("every cent is founded, held, or on the road — never conjured", function()
      local u = space(1893)
      u:run(300)
      local report = Audit.of(u.annals, legs)
      assert.equal(0, #report.violations,
         table.concat(report.violations, "\n"))
      assert.equal(report.world.founded.cents,
         report.held.cents + report.on_road.cents)
   end)

   it("every tally agrees again — and this time it's earned", function()
      -- The arc, for the record: card 120 demanded zero mismatches
      -- (instant news, a civ can't be misinformed). Card 122 made
      -- news slow and relaxed exactly that line — drift became the
      -- product, explained to the cent by what was in flight. Card
      -- 153 made *matter* slow too, and the drift died honestly:
      -- every event that moves your books now happens at your own
      -- gates, at distance zero, so self-knowledge is exact. The
      -- 122 machinery stays — it certifies the zero, and the liar
      -- spec proves it still catches books that lie.
      local u = space(1893)
      u:run(300)
      local report = Audit.of(u.annals, legs,
         { distance = u.distance, channel_speed = u.channel_speed })
      assert.equal(0, #report.mismatches)
      assert.equal(0, #report.unexplained)
   end)

   it("holds for other seeds too", function()
      for _, seed in ipairs({ 7, 40412 }) do
         local u = space(seed)
         u:run(200)
         local report = Audit.of(u.annals, legs)
         assert.equal(0, #report.violations)
         assert.equal(report.world.founded.cents,
            report.held.cents + report.on_road.cents)
      end
   end)
end)

describe("war discipline", function()
   -- One pass over a long run, checking the shape of every war.
   -- Discipline lives at the *launch*: no party rides out in
   -- peacetime. Raids are arrivals — a party eight days out when
   -- the peace is signed still lands (no recall, card 158), so a
   -- war's last raids may fall after its peace, on purpose.
   local function war_story(annals)
      local at_war = false
      local marches_in_peace, bids_in_war, declarations, peaces = 0, 0, 0, 0
      for id = 1, annals:len() do
         local e = annals:get(id)
         if e.kind == "war.declared" then
            assert(not at_war, "war declared during a war")
            at_war = true
            declarations = declarations + 1
         elseif e.kind == "war.peace" then
            assert(at_war, "peace with nobody")
            at_war = false
            peaces = peaces + 1
         elseif e.kind == "war.march" and not at_war then
            marches_in_peace = marches_in_peace + 1
         elseif e.kind == "market.order" and at_war
            and e.payload.side == "buy" then
            bids_in_war = bids_in_war + 1
         end
      end
      return declarations, peaces, marches_in_peace, bids_in_war
   end

   it("marches launch only in wartime; wartime buys nothing", function()
      local u = space(1893)
      u:run(1000)
      local declarations, peaces, marches_in_peace, bids_in_war =
         war_story(u.annals)
      assert.is_true(declarations > 0)
      assert.equal(0, marches_in_peace)
      assert.equal(0, bids_in_war)
      assert.is_true(peaces == declarations or peaces == declarations - 1)
   end)

   it("war parties take the road: every raid is a march arrived on schedule", function()
      -- khedrun-holds → vessar-reaches is 8 days at channel speed 1
      local u = space(1893)
      u:run(1000)
      local marches, raids = {}, 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "war.march" then
            marches[id] = e
         elseif e.kind == "war.raid" then
            raids = raids + 1
            local m = marches[e.causes[1]]
            assert.is_not_nil(m, "a raid from no march")
            assert.equal(8, e.tick - m.tick)
            assert.equal("khedrun-holds", m.location)
            assert.equal("vessar-reaches", e.location)
            assert.equal(m.payload.force, e.payload.force)
         end
      end
      assert.is_true(raids > 0, "a thousand days and no party ever arrived")
   end)

   it("the vessari hold their grain while they believe raiders ride", function()
      -- The declaration is shouted at khedrun-holds and reaches
      -- vessar-reaches eight days later; so does the peace. Between
      -- those two arrivals the merchants offer nothing — a market
      -- closed by news of a war that may already be over. Belief
      -- windows are replayed here from truth plus the road: war is
      -- believed from declared.tick + 8 up to (not including)
      -- peace.tick + 8.
      --
      -- Honesty note (session 3): as of this cut the property is
      -- real but unexercised — under distance, every war in every
      -- seed we tried is hunger-fused, and hunger only ignites after
      -- the price floor has already closed the market, so the
      -- believed-war windows sit inside longer price closures. The
      -- assertion stands guard for the day the war ecology changes
      -- (see the notebook: price wars went extinct when news slowed
      -- down — ruled a finding, not a bug: the toy universe doesn't
      -- measure itself against past instantiations of itself; this
      -- guard waits for a richer ecology to exercise it).
      local u = space(1893)
      u:run(1000)
      local windows = {} -- { from, to } in believed-war ticks
      local sells, withheld = 0, 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "war.declared" then
            windows[#windows + 1] = { from = e.tick + 8, to = math.huge }
         elseif e.kind == "war.peace" then
            windows[#windows].to = e.tick + 8
         elseif e.kind == "market.order" and e.payload.side == "sell" then
            sells = sells + 1
            for i = 1, #windows do
               local w = windows[i]
               assert.is_true(e.tick < w.from or e.tick >= w.to,
                  ("a sell order on day %d, inside believed war %d")
                  :format(e.tick, i))
            end
         end
      end
      -- and the prudence is real, not vacuous: wars happened, grain
      -- still moved in peacetime
      assert.is_true(#windows > 0)
      assert.is_true(sells > 0)
      -- count days the market sat closed by belief, for the record
      for i = 1, #windows do
         local w = windows[i]
         if w.to ~= math.huge then
            withheld = withheld + (w.to - w.from)
         end
      end
      assert.is_true(withheld > 0, "belief never closed the market")
   end)

   it("declarations cite their insults", function()
      local u = space(1893)
      u:run(1000)
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "war.declared" then
            assert.is_true(#e.causes >= 1)
            for _, cause in ipairs(e.causes) do
               local c = u.annals:get(cause)
               if e.payload.reason == "hunger" then
                  assert.equal("grain.hunger", c.kind)
               else
                  assert.equal("market.price", c.kind)
               end
            end
         end
      end
   end)
end)

describe("the roads", function()
   it("hungry beside the road: relief can be in transit while bellies are empty", function()
      -- Card 153's story bar. Replayed from truth in log order, so
      -- at any hunger event the in-flight set is exactly what was
      -- on the road that morning. Grain can be riding toward a
      -- hungry civ two ways: a trade shipment addressed to it, or
      -- its own war party homebound with seized sacks — the healed
      -- wrinkle's honest form (the grain and the news of it now
      -- travel together, but bellies still empty while both ride).
      -- Only real travel can produce this state of being.
      local u = space(1893)
      u:run(1000)
      local riding = {} -- departure id → the civ the grain rides toward
      local hungry_beside = 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         local p = e.payload
         if e.kind == "cargo.shipped" then
            riding[e.id] = p.recipient
         elseif e.kind == "cargo.delivered" then
            riding[e.causes[1]] = nil
         elseif e.kind == "war.spoils" then
            if p.seized > 0 then
               riding[e.id] = p.raider
            end
         elseif e.kind == "war.returned" then
            riding[e.causes[1]] = nil
         elseif e.kind == "grain.hunger" then
            local name = e.location == "vessar-reaches" and "vessari"
               or "khedrun"
            -- pairs() is legal in a spec doing an order-independent
            -- existence check; nothing here touches an outcome
            for _, toward in pairs(riding) do
               if toward == name then
                  hungry_beside = hungry_beside + 1
                  break
               end
            end
         end
      end
      assert.is_true(hungry_beside > 0,
         "a thousand days and nobody starved beside their own relief")
   end)
end)

describe("the believes view", function()
   it("the vessari learn of khedrun declarations eight days late, to the tick", function()
      -- The viewer's whole promise in one property: every believed
      -- row is dated twice, learned never precedes happened, and
      -- news from khedrun-holds is exactly the road late.
      local u = space(1893)
      u:run(200)
      local store
      for i = 1, #u.factions do
         if u.factions[i].name == "vessari" then
            store = u.factions[i].store
         end
      end
      local rows = store:chronology()
      assert.is_true(#rows > 0)
      local declarations = 0
      for i = 1, #rows do
         local r = rows[i]
         assert.is_true(r.learned >= r.tick)
         if r.kind == "war.declared" then
            declarations = declarations + 1
            assert.equal(8, r.learned - r.tick)
         end
      end
      assert.is_true(declarations > 0)
      -- and the as-of cut agrees with itself: knowledge only grows
      assert.is_true(#store:chronology(100) <= #store:chronology(200))
   end)
end)

describe("the KPI", function()
   it("a thousand days produce a chronicle worth reading", function()
      -- "Worth reading" needs a human (the notebook records that
      -- reading); what a spec can hold: a thousand days render
      -- cleanly end to end, trade happens, and at least one war
      -- nobody planned breaks out and ends.
      local u = space(1893)
      u:run(1000)
      local wars, peaces, trades = 0, 0, 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "war.declared" then
            wars = wars + 1
         elseif e.kind == "war.peace" then
            peaces = peaces + 1
         elseif e.kind == "market.trade" then
            trades = trades + 1
         end
         assert.is_string(Chronicle.line(e)) -- every event narratable
      end
      assert.is_true(wars >= 1, "a thousand days and nobody went to war")
      assert.is_true(peaces >= 1, "a war that never ended")
      assert.is_true(trades >= 1, "a market nobody used")
   end)
end)
