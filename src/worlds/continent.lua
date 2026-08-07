-- src/worlds/continent.lua — Harrow: five civilizations who cannot
-- move away from one another.
--
-- This is content, not engine — the third world (card 160), and the
-- spatial stress: in space, distance is emptiness; here it is
-- someone else's territory. The map is an adjacency graph with
-- interior — the Korrag's grain lifeline runs through the Ashfold's
-- pass or the Selm's tolls — and there is NO exchange anywhere:
-- trade is bilateral, an offer riding to a neighbor and an
-- acceptance riding back, settlement two more journeys. Four
-- events, four road trips, every one priced by the map.
--
-- The charter (docs/worlds/continent/charter.md) is the eval this
-- file answers to. Every civilization here is an example of what
-- the system must support, never a dictation that it exist.

local Universe = require "sonder.universe"
local Travel = require "sonder.travel"
local Roads = require "sonder.roads"

-- The regions and the roads between them, in days. The southern
-- pass (ash-gate) is the shortcut between valley and mountains —
-- position out of all proportion to size, and the Ashfold know it.
local REGIONS = {
   "ash-gate", "korrag-height", "selm-water", "tethri-steppe",
   "vale-bright",
}
local EDGES = {
   { "vale-bright", "selm-water", 2 },
   { "selm-water", "korrag-height", 3 },
   { "vale-bright", "ash-gate", 2 },
   { "ash-gate", "korrag-height", 2 },
   { "tethri-steppe", "selm-water", 2 },
   { "tethri-steppe", "korrag-height", 3 },
}

-- All-pairs shortest paths, computed once at load: Floyd–Warshall
-- over the sorted region list — arrays and integers only, the same
-- answer on every machine. Around versus through, priced honestly.
local DIST = {}
do
   local INF = math.maxinteger // 4
   for i = 1, #REGIONS do
      DIST[REGIONS[i]] = {}
      for j = 1, #REGIONS do
         DIST[REGIONS[i]][REGIONS[j]] = i == j and 0 or INF
      end
   end
   for i = 1, #EDGES do
      local a, b, d = EDGES[i][1], EDGES[i][2], EDGES[i][3]
      DIST[a][b] = d
      DIST[b][a] = d
   end
   for k = 1, #REGIONS do
      for i = 1, #REGIONS do
         for j = 1, #REGIONS do
            local through = DIST[REGIONS[i]][REGIONS[k]]
               + DIST[REGIONS[k]][REGIONS[j]]
            if through < DIST[REGIONS[i]][REGIONS[j]] then
               DIST[REGIONS[i]][REGIONS[j]] = through
            end
         end
      end
   end
end

local function distance(from, to, _)
   local row = DIST[from]
   if not (row and row[to]) then
      return 0 -- the void and anywhere unmapped: adjacent
   end
   return row[to]
end

-- The cast. Four-column endowments; every constant a temperament.
-- sells: standing trade postures (offer when surplus allows, at a
-- cultural price — no exchange means no price discovery, only
-- custom). buys: standing wants (accept when short and solvent).
local CAST = {
   {
      name = "valebright", home = "vale-bright",
      grain = 120, iron = 10, salt = 10, cents = 12000,
      grow_base = 12, grow_spread = 2, lean_base = 3, lean_spread = 1,
      mine = 0, gather = 0, appetite = 6,
      sells = {
         { commodity = "grain", to = "korrag", price = 60, lot = 10,
            reserve = 40 },
         { commodity = "grain", to = "ashfold", price = 60, lot = 6,
            reserve = 40 },
      },
      buys = { iron = 30, salt = 20 },
   },
   {
      name = "korrag", home = "korrag-height",
      grain = 60, iron = 25, salt = 8, cents = 9000,
      grow_base = 2, grow_spread = 1, lean_base = 1, lean_spread = 0,
      mine = 4, gather = 0, appetite = 6,
      sells = {
         { commodity = "iron", to = "valebright", price = 130, lot = 4,
            reserve = 10 },
      },
      buys = { grain = 60 },
      -- the war constants: hunger is the only fuse on Harrow
      hunger_fuse = 4, weariness = 8, relief = 50,
      force_min = 4, force_max = 9, plunder_rate = 40,
      torch_divisor = 3,
   },
   {
      name = "selm", home = "selm-water",
      grain = 40, iron = 6, salt = 6, cents = 15000,
      grow_base = 4, grow_spread = 1, lean_base = 2, lean_spread = 0,
      mine = 0, gather = 0, appetite = 4,
      sells = {},
      buys = { salt = 15 },
   },
   {
      name = "tethri", home = "tethri-steppe",
      grain = 50, iron = 4, salt = 5, cents = 8000,
      grow_base = 6, grow_spread = 1, lean_base = 3, lean_spread = 1,
      mine = 0, gather = 0, appetite = 5,
      sells = {},
      buys = { salt = 12 },
   },
   {
      name = "ashfold", home = "ash-gate",
      grain = 30, iron = 5, salt = 15, cents = 7000,
      grow_base = 2, grow_spread = 1, lean_base = 1, lean_spread = 0,
      mine = 0, gather = 3, appetite = 3,
      sells = {
         { commodity = "salt", to = "valebright", price = 90, lot = 5,
            reserve = 8 },
         { commodity = "salt", to = "selm", price = 90, lot = 5,
            reserve = 8 },
         { commodity = "salt", to = "tethri", price = 90, lot = 4,
            reserve = 8 },
      },
      buys = { grain = 25 },
   },
}

local SEAT = {}
for i = 1, #CAST do
   SEAT[CAST[i].name] = CAST[i].home
end

-- The seasons: every sixty days the valley runs twelve lean days.
-- Deterministic weather from tick arithmetic — famine as a season,
-- not a die roll — with the day-to-day jitter still drawn from each
-- civ's own stream.
local LEAN_CYCLE, LEAN_DAYS = 60, 12
local function lean(tick)
   return tick % LEAN_CYCLE < LEAN_DAYS
end

-- ---------------------------------------------------------------
-- Believed bookkeeping: four columns, the same watermark discipline
-- as every world since card 122.
-- ---------------------------------------------------------------

local WINDOW = 4 * #CAST -- sized to the crowd (the office's lesson)

local function my_latest_tally(beliefs, civ)
   local tallies = beliefs:recent("continent.tally", WINDOW)
   for i = #tallies, 1, -1 do
      if tallies[i].location == civ.home then
         return tallies[i]
      end
   end
   return nil
end

local function my_founding(beliefs, civ)
   local founded = beliefs:recent("continent.founded", #CAST + 2)
   for i = #founded, 1, -1 do
      if founded[i].payload.name == civ.name then
         return founded[i]
      end
   end
   return nil
end

local COLUMNS = { "grain", "iron", "salt", "cents" }

local function believed_books(beliefs, civ)
   local b, since, absorbed = {}, nil, nil
   local tally = my_latest_tally(beliefs, civ)
   local basis = tally or my_founding(beliefs, civ)
   for i = 1, #COLUMNS do
      b[COLUMNS[i]] = basis.payload[COLUMNS[i]]
   end
   since, absorbed = basis.id, basis.tick
   for _, c in ipairs(beliefs:recent("cargo.shipped", WINDOW)) do
      if c.learned > absorbed and c.payload.sender == civ.name then
         b[c.payload.commodity] = b[c.payload.commodity] - c.payload.units
      end
   end
   for _, c in ipairs(beliefs:recent("cargo.delivered", WINDOW)) do
      if c.learned > absorbed and c.payload.recipient == civ.name then
         b[c.payload.commodity] = b[c.payload.commodity] + c.payload.units
      end
   end
   for _, m in ipairs(beliefs:recent("payment.shipped", WINDOW)) do
      if m.learned > absorbed and m.payload.payer == civ.name then
         b.cents = b.cents - m.payload.amount
      end
   end
   for _, m in ipairs(beliefs:recent("payment.delivered", WINDOW)) do
      if m.learned > absorbed and m.payload.payee == civ.name then
         b.cents = b.cents + m.payload.amount
      end
   end
   for _, s in ipairs(beliefs:recent("war.spoils", WINDOW)) do
      if s.learned > absorbed and s.payload.target == civ.name then
         b.grain = b.grain - s.payload.seized - s.payload.burned
         b.cents = b.cents - s.payload.plunder
      end
   end
   for _, w in ipairs(beliefs:recent("war.returned", WINDOW)) do
      if w.learned > absorbed and w.payload.raider == civ.name then
         b.grain = b.grain + w.payload.seized
         b.cents = b.cents + w.payload.plunder
      end
   end
   return b, since
end

-- Settlement is single-fire: a mind acts on a letter the morning it
-- learns of it — learned == tick — and never again. The courier
-- delivers each event into a store exactly once, so the learned
-- stamp is an exactly-once guarantee the minds get for free; the
-- first draft scanned recent memory for "have I settled this?" and
-- earned the card's third window bug (an old acceptance outlived
-- the memory of having shipped for it, and shipped twice). If the
-- single morning finds the seller short or the buyer broke, the
-- deal defaults, half-settled — chartered settlement risk, honest
-- and audit-clean; recourse is card 159's business.

-- ---------------------------------------------------------------
-- The minds. One decide for everyone: keep the day's books, trade
-- by letter, and — if your constants carry knives — reach for them
-- when the hunger fuse burns.
-- ---------------------------------------------------------------

local function decide_for(civ)
   return function(beliefs, stream, tick)
      local b, prev = believed_books(beliefs, civ)

      -- the day's production and appetite
      local grew
      if lean(tick) then
         grew = civ.lean_base + stream:int(0, civ.lean_spread)
      else
         grew = civ.grow_base + stream:int(0, civ.grow_spread)
      end
      local mined, gathered = civ.mine, civ.gather
      local available = b.grain + grew
      local eaten = math.min(civ.appetite, available)
      local intents = {}
      local tally = {
         kind = "continent.tally",
         location = civ.home,
         magnitude = available - eaten,
         loudness = "quiet",
         payload = { grew = grew, mined = mined, gathered = gathered,
            eaten = eaten,
            grain = available - eaten,
            iron = b.iron + mined,
            salt = b.salt + gathered,
            cents = b.cents },
         causes = { prev },
      }
      intents[#intents + 1] = tally
      b.grain = available - eaten
      b.iron = b.iron + mined
      b.salt = b.salt + gathered
      if eaten < civ.appetite then
         intents[#intents + 1] = {
            kind = "continent.hunger",
            location = civ.home,
            magnitude = civ.appetite - eaten,
            loudness = "local",
            payload = { shortfall = civ.appetite - eaten },
            causes = { prev },
         }
      end

      -- the war office, for those who keep one (hunger is Harrow's
      -- only fuse; no recall, the usual physics)
      if civ.hunger_fuse then
         local declared = beliefs:latest("war.declared")
         local peace = beliefs:latest("war.peace")
         local at_war = declared ~= nil
            and (peace == nil or peace.id < declared.id)
         if at_war then
            local weary = tick - declared.tick >= civ.weariness
            if weary or b.grain >= civ.relief then
               intents[#intents + 1] = {
                  kind = "war.peace",
                  location = civ.home,
                  magnitude = b.grain,
                  loudness = "loud",
                  payload = { name = civ.name, measure = b.grain },
                  causes = { declared.id },
               }
            else
               local force = stream:int(civ.force_min, civ.force_max)
               intents[#intents + 1] = {
                  kind = "war.march",
                  location = civ.home,
                  magnitude = force,
                  loudness = "local",
                  payload = { raider = civ.name, target = "valebright",
                     force = force },
                  causes = { declared.id },
               }
            end
            return intents
         end
         local hungers = beliefs:recent("continent.hunger", 10)
         local hungry, causes = 0, {}
         for i = 1, #hungers do
            local h = hungers[i]
            if h.location == civ.home and h.tick > tick - 7
               and (peace == nil or h.id > peace.id) then
               hungry = hungry + 1
               causes[#causes + 1] = h.id
            end
         end
         if hungry >= civ.hunger_fuse then
            intents[#intents + 1] = {
               kind = "war.declared",
               location = civ.home,
               magnitude = hungry,
               loudness = "loud",
               payload = { aggressor = civ.name, target = "valebright",
                  reason = "hunger", measure = hungry },
               causes = causes,
            }
            return intents
         end
      end

      -- trade by letter: honor acceptances first (ship what you
      -- sold, pay for what you bought), then write new offers
      for _, a in ipairs(beliefs:recent("continent.accept", WINDOW)) do
         local p = a.payload
         if p.seller == civ.name and a.learned == tick
            and b[p.commodity] and b[p.commodity] >= p.units then
            b[p.commodity] = b[p.commodity] - p.units
            intents[#intents + 1] = {
               kind = "cargo.shipped",
               location = civ.home,
               magnitude = p.units,
               loudness = "local",
               payload = { commodity = p.commodity, units = p.units,
                  sender = civ.name, recipient = p.buyer },
               causes = { a.id },
            }
         end
         if p.buyer == civ.name and a.learned == tick
            and b.cents >= p.total then
            b.cents = b.cents - p.total
            intents[#intents + 1] = {
               kind = "payment.shipped",
               location = civ.home,
               magnitude = p.total,
               loudness = "quiet",
               payload = { amount = p.total, payer = civ.name,
                  payee = p.seller },
               causes = { a.id },
            }
         end
      end
      for _, o in ipairs(beliefs:recent("continent.offer", WINDOW)) do
         local p = o.payload
         if p.buyer == civ.name and o.learned == tick
            and civ.buys[p.commodity]
            and b[p.commodity] < civ.buys[p.commodity]
            and b.cents >= p.total then
            intents[#intents + 1] = {
               kind = "continent.accept",
               location = civ.home,
               magnitude = p.units,
               loudness = "quiet",
               payload = { buyer = civ.name, seller = p.seller,
                  commodity = p.commodity, units = p.units,
                  total = p.total },
               causes = { o.id },
            }
         end
      end
      for i = 1, #civ.sells do
         local s = civ.sells[i]
         if b[s.commodity] - s.reserve >= s.lot then
            -- one standing letter at a time per counterparty and
            -- good: don't re-offer while a recent one may still be
            -- riding or awaiting an answer
            local recent_offer = false
            for _, o in ipairs(beliefs:recent("continent.offer", WINDOW)) do
               local p = o.payload
               if p.seller == civ.name and p.buyer == s.to
                  and p.commodity == s.commodity
                  and o.tick > tick - 8 then
                  recent_offer = true
               end
            end
            if not recent_offer then
               intents[#intents + 1] = {
                  kind = "continent.offer",
                  location = civ.home,
                  magnitude = s.lot,
                  loudness = "local",
                  payload = { seller = civ.name, buyer = s.to,
                     commodity = s.commodity, units = s.lot,
                     price = s.price, total = s.lot * s.price },
                  causes = { prev },
               }
            end
         end
      end
      return intents
   end
end

-- ---------------------------------------------------------------
-- Physics: the roads and the battlefield. No exchange, no clients —
-- Harrow's only institutions are distance and consequence.
-- ---------------------------------------------------------------

local function add_physics(u)
   local ledger = {}
   local roads = Roads.new(u, {
      resolve = function(name) return SEAT[name] end,
      payment_loudness = "quiet",
   })
   local marches = Travel.new()
   local parties = Travel.new()
   local cursor = 0

   local function travel_days(from, to, tick)
      local d = distance(from, to, tick)
      return (d + u.channel_speed - 1) // u.channel_speed
   end

   local function catch_up()
      while cursor < u.annals:len() do
         cursor = cursor + 1
         local e = u.annals:get(cursor)
         local p = e.payload
         if e.kind == "continent.founded" then
            ledger[p.name] = { grain = p.grain, iron = p.iron,
               salt = p.salt, cents = p.cents }
         elseif e.kind == "continent.tally" then
            -- a tally speaks from a home; resolve the owner
            local b
            for i = 1, #CAST do
               if CAST[i].home == e.location then
                  b = ledger[CAST[i].name]
               end
            end
            b.grain = b.grain + p.grew - p.eaten
            b.iron = b.iron + p.mined
            b.salt = b.salt + p.gathered
         elseif e.kind == "cargo.shipped" then
            ledger[p.sender][p.commodity] =
               ledger[p.sender][p.commodity] - p.units
            roads:schedule(e)
         elseif e.kind == "cargo.delivered" then
            ledger[p.recipient][p.commodity] =
               ledger[p.recipient][p.commodity] + p.units
         elseif e.kind == "payment.shipped" then
            ledger[p.payer].cents = ledger[p.payer].cents - p.amount
            roads:schedule(e)
         elseif e.kind == "payment.delivered" then
            ledger[p.payee].cents = ledger[p.payee].cents + p.amount
         elseif e.kind == "war.spoils" then
            local target = ledger[p.target]
            target.grain = target.grain - p.seized - p.burned
            target.cents = target.cents - p.plunder
         elseif e.kind == "war.returned" then
            local raider = ledger[p.raider]
            raider.grain = raider.grain + p.seized
            raider.cents = raider.cents + p.plunder
         elseif e.kind == "war.march" then
            marches:schedule(
               e.tick + travel_days(e.location, SEAT[p.target], e.tick),
               { id = e.id, raider = p.raider, target = p.target,
                  force = p.force })
         end
      end
   end

   u:add_system("roads", roads:system(catch_up))

   u:add_system("battle", function(universe, _, tick)
      catch_up()
      local home = parties:due(tick)
      for i = 1, #home do
         local w = home[i]
         universe:emit{
            kind = "war.returned",
            location = w.home,
            magnitude = w.seized,
            loudness = "local",
            payload = { raider = w.raider, target = w.target,
               seized = w.seized, plunder = w.plunder },
            causes = { w.spoils },
         }
         catch_up()
      end
      local arrivals = marches:due(tick)
      for i = 1, #arrivals do
         local m = arrivals[i]
         local where = SEAT[m.target]
         local raid = universe:emit{
            kind = "war.raid",
            location = where,
            magnitude = m.force,
            loudness = "local",
            payload = { raider = m.raider, target = m.target,
               force = m.force },
            causes = { m.id },
         }
         catch_up()
         local target = ledger[m.target]
         local korrag -- the raider's constants carry the torch rate
         for j = 1, #CAST do
            if CAST[j].name == m.raider then
               korrag = CAST[j]
            end
         end
         local seized = math.min(m.force, target.grain)
         local burned = math.min(m.force // korrag.torch_divisor,
            target.grain - seized)
         local plunder = math.min(m.force * korrag.plunder_rate,
            target.cents)
         local spoils = universe:emit{
            kind = "war.spoils",
            location = where,
            magnitude = seized + burned,
            loudness = "local",
            payload = { raider = m.raider, target = m.target,
               seized = seized, plunder = plunder, burned = burned },
            causes = { raid },
         }
         catch_up()
         parties:schedule(
            tick + travel_days(where, SEAT[m.raider], tick),
            { spoils = spoils, raider = m.raider, target = m.target,
               seized = seized, plunder = plunder,
               home = SEAT[m.raider] })
      end
   end)
end

-- ---------------------------------------------------------------
-- Harrow, assembled.
-- ---------------------------------------------------------------

return function(seed)
   local u = Universe.new(seed, {
      distance = distance,
      -- Rung 2 of ADR 0005's ladder (card 150): Harrow is the pilot,
      -- and the field is retired here. Two rows replace it. Earshot
      -- is the continent's natural medium — a loud act carries two
      -- days over the passes (a declaration of war is heard next
      -- door); local and quiet acts stay at their own gates, which
      -- makes self-knowledge exact with no further machinery. The
      -- letters row is the charter's "trade travels by letter" made
      -- literal: an offer rides to its named buyer, an acceptance
      -- back to its named seller, at road pace, and reaches nobody
      -- else — the Selm no longer read everyone's mail for free.
      -- Everything else the field used to deliver — another civ's
      -- tallies, a distant raid, a stranger's founding — now reaches
      -- no one, because nothing carries it: the witness rule, lived.
      -- The seal does not move: no mind here ever read what the
      -- field over-delivered, so history is bit-identical and only
      -- the belief stores grow honestly ignorant.
      mechanisms = {
         { name = "earshot", shape = "radiated", speed = 1,
            range = { loud = 2, ["local"] = 0, quiet = 0 } },
         { name = "letters", shape = "addressed", speed = 1,
            to = { ["continent.offer"] = "buyer",
               ["continent.accept"] = "seller" } },
      },
      vocabulary = require "worlds.continent_vocabulary",
   })
   for i = 1, #CAST do
      local c = CAST[i]
      u:emit{
         kind = "continent.founded",
         location = c.home,
         magnitude = c.grain,
         loudness = "loud",
         payload = { name = c.name, grain = c.grain, iron = c.iron,
            salt = c.salt, cents = c.cents },
         causes = { 1 },
      }
   end
   add_physics(u)
   for i = 1, #CAST do
      local c = CAST[i]
      u:add_faction(c.name, c.home, decide_for(c))
   end
   return u
end
