-- tests/continent_spec.lua — Harrow kept honest: the third world
-- boots on an unmodified engine, bilateral trade settles by letter
-- with cause links as receipts, four-column books balance through
-- wars, and the chartered KPI — the famine-season war — precipitates
-- unprompted.

local continent = require "worlds.continent"
local Seal = require "sonder.seal"
local Audit = require "sonder.audit"
local legs = require "worlds.continent_audit"

describe("the continent", function()
   it("runs deterministically: same seed, same history, seal for seal", function()
      local a, b = continent(7), continent(7)
      a:run(150)
      b:run(150)
      assert.equal(Seal.of(a.annals):hex(), Seal.of(b.annals):hex())
   end)

   it("the golden continent: seed 7, 200 days, one exact seal", function()
      -- Harrow's own regression anchor. Re-cut ledger:
      --   9be58120c48a121b — first cut (card 160): five civilizations,
      --                      bilateral letters, single-fire settlement
      --                      (act the morning you learn)
      local u = continent(7)
      u:run(200)
      assert.equal("9be58120c48a121b", Seal.of(u.annals):hex())
   end)

   it("trade settles by letter: offers ride, acceptances ride back, goods and money follow", function()
      local u = continent(7)
      u:run(150)
      local offers, accepts, caravans, strongboxes = 0, 0, 0, 0
      local offer_at, seat = {}, {}
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         local p = e.payload
         if e.kind == "continent.founded" then
            seat[p.name] = e.location
         elseif e.kind == "continent.offer" then
            offers = offers + 1
            offer_at[e.id] = e
         elseif e.kind == "continent.accept" then
            accepts = accepts + 1
            -- an acceptance cannot outrun the letter it answers:
            -- at least the road's days lie between them
            local o = offer_at[e.causes[1]]
            assert.is_not_nil(o, "an acceptance citing no offer")
            local road = u.distance(o.location, e.location, o.tick)
            assert.is_true(e.tick - o.tick >= road,
               "a yes that traveled faster than the question")
         elseif e.kind == "cargo.delivered" then
            caravans = caravans + 1
         elseif e.kind == "payment.delivered" then
            strongboxes = strongboxes + 1
         end
      end
      assert.is_true(offers > 0, "no letters ever rode")
      assert.is_true(accepts > 0, "no one ever said yes")
      assert.is_true(offers > accepts, "every letter answered — too polite")
      assert.is_true(caravans > 0, "no caravan ever arrived")
      assert.is_true(strongboxes > 0, "no strongbox ever arrived")
   end)

   it("cause links are receipts: no acceptance is settled twice", function()
      -- The stateless dedup that makes bilateral settlement
      -- idempotent: a mind ships (or pays) for an acceptance only
      -- if it has no memory of already doing so. Replayed from
      -- truth: at most one shipment and one payment cite any
      -- acceptance.
      local u = continent(7)
      u:run(300)
      local accepted, shipped_for, paid_for = {}, {}, {}
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "continent.accept" then
            accepted[e.id] = true
         elseif e.kind == "cargo.shipped" and accepted[e.causes[1]] then
            assert.is_nil(shipped_for[e.causes[1]],
               "an acceptance shipped twice")
            shipped_for[e.causes[1]] = true
         elseif e.kind == "payment.shipped" and accepted[e.causes[1]] then
            assert.is_nil(paid_for[e.causes[1]],
               "an acceptance paid twice")
            paid_for[e.causes[1]] = true
         end
      end
   end)

   it("four columns balance through wars and letters alike", function()
      local u = continent(7)
      u:run(400)
      local report = Audit.of(u.annals, legs,
         { distance = u.distance, channel_speed = u.channel_speed })
      assert.equal(0, #report.violations,
         table.concat(report.violations, "\n"))
      assert.equal(0, #report.mismatches)
      assert.equal(0, #report.unexplained)
      assert.equal(0, next(report.unclassified) and 1 or 0,
         "Harrow's vocabulary has kinds its own audit cannot book")
   end)

   it("the famine war: lean fields in the valley, knives in the mountains", function()
      -- The chartered KPI. The lean season thins the valley's
      -- harvests; the mountains, who eat more than they grow, run
      -- out of patience four hungry days at a time — and the war
      -- party's road to the granaries runs through the pass, four
      -- days, no recall.
      local u = continent(7)
      u:run(400)
      local declared, marches = nil, {}
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "war.declared" and not declared then
            declared = e
         elseif e.kind == "war.march" then
            marches[id] = e
         elseif e.kind == "war.raid" and declared then
            local m = marches[e.causes[1]]
            if m then
               -- the road through the pass: four days, always
               assert.equal(4, e.tick - m.tick)
               assert.equal("vale-bright", e.location)
            end
         end
      end
      assert.is_not_nil(declared, "four hundred days and no war")
      assert.equal("korrag-height", declared.location)
      assert.equal("hunger", declared.payload.reason)
      -- the declaration cites hunger, and hunger has a season:
      -- some lean day fell within the fortnight before the knives
      local lean_before = false
      for t = math.max(0, declared.tick - 14), declared.tick do
         if t % 60 < 12 then
            lean_before = true
         end
      end
      assert.is_true(lean_before,
         "a hunger war with no lean season behind it")
      for _, cause in ipairs(declared.causes) do
         assert.equal("continent.hunger", u.annals:get(cause).kind)
      end
   end)

   it("every Harrow kind has a Harrow sentence", function()
      local vocabulary = require "worlds.continent_vocabulary"
      local templates = require "worlds.continent_templates"
      for kind in pairs(vocabulary.kinds) do
         assert.equal("function", type(templates[kind]),
            "no sentence for " .. kind)
      end
   end)
end)
