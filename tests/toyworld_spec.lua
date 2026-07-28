-- tests/toyworld_spec.lua — the toy world kept honest: conservation
-- from the log alone, war discipline, and the card's only KPI as an
-- executable claim.

local toy = require "support.toy"
local Chronicle = require "sonder.chronicle"
local Audit = require "sonder.audit"

-- The independent auditor grew up: what post 0007 kept here as a
-- spec-local fold is now src/sonder/audit.lua (card 120), and this
-- file consumes it like any other viewer. The claims are unchanged —
-- with a pass-through courier a civ can be neither lying nor
-- misinformed, so mismatches are bugs — audit_spec.lua carries the
-- audit's own trials (coverage, counterfeits, conservation).

describe("conservation", function()
   it("every cent is founded, traded, or plundered — never conjured", function()
      local u = toy(1893)
      u:run(300)
      local report = Audit.of(u.annals)
      assert.equal(0, #report.violations,
         table.concat(report.violations, "\n"))
      assert.equal(report.founded.cents, report.held.cents)
   end)

   it("every tally agrees with the independent audit", function()
      -- Run long enough to cross war and peace both. Card 122 will
      -- relax exactly this assertion — mismatches, never violations.
      local u = toy(1893)
      u:run(300)
      assert.equal(0, #Audit.of(u.annals).mismatches)
   end)

   it("holds for other seeds too", function()
      for _, seed in ipairs({ 7, 40412 }) do
         local u = toy(seed)
         u:run(200)
         local report = Audit.of(u.annals)
         assert.equal(0, #report.violations)
         assert.equal(report.founded.cents, report.held.cents)
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
      local u = toy(1893)
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
      local u = toy(1893)
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

   it("declarations cite their insults", function()
      local u = toy(1893)
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

describe("the KPI", function()
   it("a thousand days produce a chronicle worth reading", function()
      -- "Worth reading" needs a human (the notebook records that
      -- reading); what a spec can hold: a thousand days render
      -- cleanly end to end, trade happens, and at least one war
      -- nobody planned breaks out and ends.
      local u = toy(1893)
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
