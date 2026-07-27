-- tests/toyworld_spec.lua — the toy world kept honest: conservation
-- from the log alone, war discipline, and the card's only KPI as an
-- executable claim.

local toy = require "support.toy"
local Chronicle = require "sonder.chronicle"

-- The independent auditor: fold the entire annals into per-civ books,
-- trusting nothing but founding events and the arithmetic of trades,
-- raids, harvests, and meals. This is card 120's double-entry audit
-- in miniature, and it must agree with every self-reported tally —
-- a civ whose beliefs drift from the ledger is either lying or
-- misinformed, and with a pass-through courier it can be neither.
local function audit(annals)
   local books = {}
   local minted, burned_total = 0, 0
   for id = 1, annals:len() do
      local e = annals:get(id)
      local p = e.payload
      if e.kind == "civ.founded" then
         books[p.name] = { grain = p.grain, cents = p.cents, home = e.location }
         minted = minted + p.cents
      elseif e.kind == "civ.tally" then
         local mine
         for _, b in pairs(books) do
            if b.home == e.location then
               mine = b
            end
         end
         mine.grain = mine.grain + p.harvested - p.eaten
         assert(mine.grain == p.stock, ("tally at event %d self-reports "
            .. "%d sacks; the audit says %d"):format(id, p.stock, mine.grain))
         assert(mine.cents == p.cents, ("tally at event %d self-reports "
            .. "%d cents; the audit says %d"):format(id, p.cents, mine.cents))
      elseif e.kind == "market.trade" then
         assert(p.total == p.units * p.price, "trade total is not units × price")
         local buyer, seller = books[p.buyer], books[p.seller]
         buyer.grain = buyer.grain + p.units
         buyer.cents = buyer.cents - p.total
         seller.grain = seller.grain - p.units
         seller.cents = seller.cents + p.total
      elseif e.kind == "war.spoils" then
         local raider, target = books[p.raider], books[p.target]
         raider.grain = raider.grain + p.seized
         raider.cents = raider.cents + p.plunder
         target.grain = target.grain - p.seized - p.burned
         target.cents = target.cents - p.plunder
         burned_total = burned_total + p.burned
      end
      for name, b in pairs(books) do
         assert(b.grain >= 0, name .. " holds negative grain at event " .. id)
         assert(b.cents >= 0, name .. " holds negative cents at event " .. id)
      end
   end
   local cents_now = 0
   for _, b in pairs(books) do
      cents_now = cents_now + b.cents
   end
   return books, minted, cents_now, burned_total
end

describe("conservation", function()
   it("every cent is founded, traded, or plundered — never conjured", function()
      local u = toy(1893)
      u:run(300)
      local _, minted, cents_now = audit(u.annals)
      assert.equal(minted, cents_now)
   end)

   it("every tally agrees with the independent audit", function()
      -- audit() asserts per-tally as it folds; surviving the fold is
      -- the assertion. Run long enough to cross war and peace both.
      local u = toy(1893)
      u:run(300)
      audit(u.annals)
   end)

   it("holds for other seeds too", function()
      for _, seed in ipairs({ 7, 40412 }) do
         local u = toy(seed)
         u:run(200)
         local _, minted, cents_now = audit(u.annals)
         assert.equal(minted, cents_now)
      end
   end)
end)

describe("war discipline", function()
   -- One pass over a long run, checking the shape of every war.
   local function war_story(annals)
      local at_war = false
      local raids_in_peace, bids_in_war, declarations, peaces = 0, 0, 0, 0
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
         elseif e.kind == "war.raid" and not at_war then
            raids_in_peace = raids_in_peace + 1
         elseif e.kind == "market.order" and at_war
            and e.payload.side == "buy" then
            bids_in_war = bids_in_war + 1
         end
      end
      return declarations, peaces, raids_in_peace, bids_in_war
   end

   it("raids happen only in wartime; wartime buys nothing", function()
      local u = toy(1893)
      u:run(1000)
      local declarations, peaces, raids_in_peace, bids_in_war =
         war_story(u.annals)
      assert.is_true(declarations > 0)
      -- A raid intent from the war's last day resolves one tick after
      -- the peace — the battle system is a day behind the diplomats,
      -- exactly like the market. Allow one straggler per war.
      assert.is_true(raids_in_peace <= declarations)
      assert.equal(0, bids_in_war)
      assert.is_true(peaces == declarations or peaces == declarations - 1)
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
