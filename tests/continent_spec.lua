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
      --   c6dc5ef5b428aa85 — re-cut (card 151): the roads can lose a
      --                      letter — one encounter per fifty
      --                      rider-days, drawn on rng.courier at
      --                      departure, landing on its true day. The
      --                      project's first deliberate history
      --                      fork; engine 0.2.0 under the card-150
      --                      convention (a seal re-cut never ships
      --                      without a minor bump)
      local u = continent(7)
      u:run(200)
      assert.equal("c6dc5ef5b428aa85", Seal.of(u.annals):hex())
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

   -- Card 150's pilot: the field is retired on Harrow. Earshot and
   -- letters carry everything the minds ever read — which is why the
   -- golden seal above did not move — and everything else now
   -- reaches no one, because nothing carries it. The witness rule,
   -- observable.

   local function store_of(u, name)
      for i = 1, #u.factions do
         if u.factions[i].name == name then
            return u.factions[i].store
         end
      end
   end

   it("the witness rule, lived: the steppe never hears the mountains' hunger", function()
      local u = continent(7)
      u:run(400)
      local hungers = 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "continent.hunger"
            and e.location == "korrag-height" then
            hungers = hungers + 1
         end
      end
      assert.is_true(hungers > 0, "the mountains never even went hungry")
      -- the mountains know their own hunger; the steppe, three days
      -- of territory away, has no rows about it — not late: never
      local korrag = store_of(u, "korrag"):recall("continent.hunger")
      assert.is_true(#korrag > 0)
      local tethri = store_of(u, "tethri"):recall("continent.hunger")
      for i = 1, #tethri do
         assert.is_not.equal("korrag-height", tethri[i].location,
            "hunger crossed the steppe with no carrier")
      end
   end)

   it("letters reach their addressee at road pace, and nobody else", function()
      local u = continent(7)
      u:run(150)
      -- the mountains receive the valley's grain offers four days
      -- after they were written: around the passes, priced honestly
      local korrag = store_of(u, "korrag"):recall("continent.offer")
      local from_valley = 0
      for i = 1, #korrag do
         local o = korrag[i]
         if o.payload.seller == "valebright" then
            from_valley = from_valley + 1
            assert.equal("korrag", o.payload.buyer)
            assert.equal(4, o.learned - o.tick,
               "a letter that did not take the road")
         end
      end
      assert.is_true(from_valley > 0, "the valley never wrote")
      -- the Selm — everyone's neighbor by water — no longer read
      -- everyone's mail: no offer between two other civilizations
      -- ever lands in their store
      local selm = store_of(u, "selm"):recall("continent.offer")
      for i = 1, #selm do
         local p = selm[i].payload
         assert.is_true(p.buyer == "selm" or p.seller == "selm",
            "a letter between strangers landed on the Selm's table")
      end
   end)

   -- Card 151: the roads can lose a letter. The fate is drawn at
   -- departure on the courier's own stream; the loss lands on its
   -- true day, on the road, reason-free, witnessed by no one.

   it("the roads take letters, on their true day, citing what they carried", function()
      local u = continent(7)
      u:run(400)
      local losses = 0
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "continent.letter-lost" then
            losses = losses + 1
            assert.equal("the-roads", e.location)
            local carried = u.annals:get(e.causes[1])
            assert.is_true(carried.kind == "continent.offer"
               or carried.kind == "continent.accept",
               "a loss that carried nothing")
            -- strictly after departure (the annals does not stamp
            -- a death before it happens), within the road's days
            local road = u.distance(carried.location,
               e.payload.to, carried.tick)
            assert.is_true(e.tick > carried.tick,
               "a loss stamped before the rider set out")
            assert.is_true(e.tick - carried.tick <= road,
               "a rider lost after they would have arrived")
         end
      end
      assert.is_true(losses > 0, "four hundred days and safe roads")
   end)

   it("a lost letter is witnessed by no one: the first oblivion in production", function()
      local u = continent(7)
      u:run(400)
      for i = 1, #u.factions do
         assert.equal(0,
            #u.factions[i].store:recall("continent.letter-lost"),
            u.factions[i].name .. " somehow heard a rider die alone")
      end
   end)

   it("a lost acceptance half-settles: paid, never shipped, chartered risk", function()
      -- The buyer acts on their own yes at their own gates; the
      -- seller never learns it. Payment rides to a seller who never
      -- ships — a strongbox arriving for no reason the seller
      -- knows. Settlement risk the charter blessed; recourse is
      -- card 159's business. The audit stays clean throughout (the
      -- four-columns spec above runs the same 400 days).
      local u = continent(7)
      u:run(400)
      local accept_ids, shipped, paid = {}, {}, {}
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         if e.kind == "continent.accept" then
            accept_ids[#accept_ids + 1] = e.id
         elseif e.kind == "cargo.shipped" then
            shipped[e.causes[1]] = true
         elseif e.kind == "payment.shipped" then
            paid[e.causes[1]] = true
         end
      end
      local half = 0
      for i = 1, #accept_ids do
         local id = accept_ids[i]
         if paid[id] and not shipped[id] then
            half = half + 1
         end
      end
      assert.is_true(half > 0,
         "no trade ever half-settled — the roads are too kind")
   end)

   it("earshot ends where the range says: foundings carry one pass, not two", function()
      local u = continent(7)
      u:run(5)
      -- from selm-water: the valley (2 days) and the steppe (2) are
      -- in earshot of a loud founding; the mountains (3) and the
      -- gate (4) are not, and no later tick changes that
      local heard = {}
      local founded = store_of(u, "selm"):recall("continent.founded")
      for i = 1, #founded do
         heard[founded[i].payload.name] = true
      end
      assert.is_true(heard.selm and heard.valebright and heard.tethri)
      assert.is_nil(heard.korrag)
      assert.is_nil(heard.ashfold)
   end)
end)
