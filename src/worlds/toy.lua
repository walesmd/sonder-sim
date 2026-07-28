-- src/worlds/toy.lua — two civilizations, one commodity, one
-- market. The Vessari price things; the Khedrun cost them out.
--
-- This is content, not engine: the first world the machinery hosts,
-- and the crash-test cast for every law at once. The civilizations
-- are factions (they can be wrong about things); the exchange and
-- the battlefield are systems (physics, entitled to truth). Money is
-- integer cents, grain is integer sacks, and nothing happens except
-- an append.
--
-- The civs are deliberately *stateless*: no patience counter, no
-- cached granary total. A civ's entire mind — its stock, its
-- treasury, whether it is at war, how insulted it feels — is
-- recomputed each day from its belief store. Law 2 says all state
-- views are projections of events; here that extends into the
-- agents' heads, which is what will make slow news (card 122) change
-- what a mind *is*, not just when it reacts.
--
-- War happens when a culture's patience is priced past its
-- temperament. No line below schedules one.

local Universe = require "sonder.universe"

local EXCHANGE = "the-exchange"
local OPENING_PRICE = 100 -- cents per sack, posted at tick 0
local PRICE_STEP_CAP = 4 -- the exchange moves at most this per day

-- The map. Distances in days at channel speed 1, declared once per
-- pair (the lookup tries both directions). The exchange sits on the
-- road between the two civilizations — 3 + 5 = 8, exactly — and the
-- Khedrun live farther out, so their prices always arrive staler
-- and their wars are declared on older grievances. Undeclared pairs
-- are adjacent: the void is at distance zero from everywhere, which
-- is why genesis is heard the instant the universe begins.
local DISTANCES = {
   ["vessar-reaches"] = { ["the-exchange"] = 3, ["khedrun-holds"] = 8 },
   ["khedrun-holds"] = { ["the-exchange"] = 5 },
}

-- The world's answer to "how far?" — consulted by the courier at
-- each event's departure. The tick goes unused because this map
-- stands still; the day the map moves (card 125 and beyond), only
-- this function needs to hear about it.
local function distance(from, to, _)
   if from == to then
      return 0
   end
   local row = DISTANCES[from]
   local d = row and row[to]
   if d == nil then
      row = DISTANCES[to]
      d = row and row[from]
   end
   return d or 0
end

-- The cast. Tuned against the 1000-day acceptance run (see the
-- card's notebook); every constant is a temperament in disguise.
local VESSARI = {
   name = "vessari", home = "vessar-reaches",
   grain = 160, cents = 10000, -- endowment, on the record at founding
   harvest_base = 10, harvest_spread = 4, -- 10..14 sacks a day
   appetite = 8, -- sacks eaten a day
   reserve = 50, -- sacks held back from any market
   lot = 12, -- most they'll offer in a day
   undercut = 2, -- they price to move: limit = believed price − this
   floor = 80, -- but merchants don't dump: no offers below this
}
local KHEDRUN = {
   name = "khedrun", home = "khedrun-holds",
   grain = 80, cents = 14000,
   harvest_base = 6, harvest_spread = 2, -- 6..8 sacks a day
   appetite = 10, -- a warrior culture eats like one
   target = 100, -- the granary level that feels safe
   lot = 15,
   premium = 3, -- impatient buyers pay up: limit = price + this
   temperament = 150, -- the price that reads as an insult
   fuse = 7, -- insults in a row before the knives come out
   hunger_fuse = 4, -- or this many hungry days in recent memory
   relief = 110, -- the price at which blood stops paying
   weariness = 10, -- days of war before the horde goes home regardless
   force_min = 6, force_max = 12, -- war party sizes
   plunder_rate = 50, -- cents carried off per point of force
   -- What a war party can't carry, some of it burns: a sack per two
   -- points of force. Burning is why the Vessari hoard can't grow
   -- forever, and why a long war leaves real scarcity behind it.
   torch_divisor = 2,
}

-- ---------------------------------------------------------------
-- Believed bookkeeping: pure functions of a belief store. Nothing
-- in this section can reach truth; that's the point of it.
-- ---------------------------------------------------------------

-- Both civs' reports still arrive in every store — the other civ's
-- just arrive eight days stale now — so "my" latest tally is a short
-- backward scan, not a latest(). The margins on these recent()
-- windows are generous: arrivals stay at most one tally per civ, one
-- trade, one spoils per day, staggered by distance, never bunched.
local function my_latest_tally(beliefs, civ)
   local tallies = beliefs:recent("civ.tally", 6)
   for i = #tallies, 1, -1 do
      if tallies[i].location == civ.home then
         return tallies[i]
      end
   end
   return nil
end

local function my_founding(beliefs, civ)
   local founded = beliefs:recent("civ.founded", 4)
   for i = #founded, 1, -1 do
      if founded[i].payload.name == civ.name then
         return founded[i]
      end
   end
   return nil
end

-- What the civ believes it holds: the last self-report, plus every
-- believed trade and raid the books haven't absorbed yet. Returns
-- grain, cents, and the id of the report it grew from (the day's
-- bookkeeping cause).
--
-- "Absorbed yet" is judged by the courier's `learned` stamp, never
-- by event id: news that crossed distance carries an old id, and an
-- id watermark would drop it forever the moment it finally arrived
-- (the adversarial review caught exactly that — the Khedrun's
-- believed treasury froze at its founding value for sixty days
-- while phantom hunger tripped the war fuse). The tally written on
-- day T absorbed everything learned by day T, by induction: each
-- believed trade or spoils integrates into exactly the first tally
-- decided after it lands. So the filter is learned > basis day.
local function believed_books(beliefs, civ)
   local grain, cents, since, absorbed
   local tally = my_latest_tally(beliefs, civ)
   if tally then
      grain, cents, since = tally.payload.stock, tally.payload.cents, tally.id
      absorbed = tally.tick
   else
      local founded = my_founding(beliefs, civ)
      grain, cents, since = founded.payload.grain, founded.payload.cents, founded.id
      absorbed = founded.tick
   end
   for _, t in ipairs(beliefs:recent("market.trade", 6)) do
      if t.learned > absorbed then
         if t.payload.buyer == civ.name then
            grain, cents = grain + t.payload.units, cents - t.payload.total
         elseif t.payload.seller == civ.name then
            grain, cents = grain - t.payload.units, cents + t.payload.total
         end
      end
   end
   for _, s in ipairs(beliefs:recent("war.spoils", 6)) do
      if s.learned > absorbed then
         if s.payload.raider == civ.name then
            grain = grain + s.payload.seized
            cents = cents + s.payload.plunder
         elseif s.payload.target == civ.name then
            grain = grain - s.payload.seized - s.payload.burned
            cents = cents - s.payload.plunder
         end
      end
   end
   return grain, cents, since
end

-- The day begins the same way for everyone: harvest, eat, report.
-- Returns the intents so far plus the closing stock and treasury the
-- rest of the day's decisions run on.
local function open_the_day(civ, beliefs, stream)
   local grain, cents, prev = believed_books(beliefs, civ)
   local harvested = civ.harvest_base + stream:int(0, civ.harvest_spread)
   local available = grain + harvested
   local eaten = math.min(civ.appetite, available)
   local stock = available - eaten
   local intents = { {
      kind = "civ.tally",
      location = civ.home,
      magnitude = stock,
      loudness = "local",
      payload = { harvested = harvested, eaten = eaten,
         stock = stock, cents = cents },
      causes = { prev },
   } }
   if eaten < civ.appetite then
      local shortfall = civ.appetite - eaten
      intents[#intents + 1] = {
         kind = "grain.hunger",
         location = civ.home,
         magnitude = shortfall,
         loudness = "local",
         payload = { shortfall = shortfall },
         causes = { prev },
      }
   end
   return intents, stock, cents
end

-- ---------------------------------------------------------------
-- The Vessari: they price things.
-- ---------------------------------------------------------------

local function vessari_decide(beliefs, stream)
   local intents, stock = open_the_day(VESSARI, beliefs, stream)
   local price = beliefs:latest("market.price")
   local surplus = stock - VESSARI.reserve
   -- Merchants, not charities: they undercut the posted price to
   -- move grain, but below the floor they hold their stores and
   -- wait for the market to remember what grain is worth.
   if price and surplus > 0 then
      local limit = price.payload.price - VESSARI.undercut
      if limit >= VESSARI.floor then
         local units = math.min(surplus, VESSARI.lot)
         intents[#intents + 1] = {
            kind = "market.order",
            location = VESSARI.home,
            magnitude = units,
            loudness = "loud",
            payload = { side = "sell", units = units, limit = limit },
            causes = { price.id },
         }
      end
   end
   return intents
end

-- ---------------------------------------------------------------
-- The Khedrun: they cost them out.
-- ---------------------------------------------------------------

local function khedrun_decide(beliefs, stream, tick)
   local intents, stock, cents = open_the_day(KHEDRUN, beliefs, stream)
   local price = beliefs:latest("market.price")
   local declared = beliefs:latest("war.declared")
   local peace = beliefs:latest("war.peace")
   local at_war = declared ~= nil and (peace == nil or peace.id < declared.id)

   if at_war then
      -- Peace when the war has bought what it set out to buy: cheap
      -- grain ends a war that prices started (a hunger war began
      -- with prices low — relief means nothing to it), full
      -- granaries end either kind, and a weary horde goes home
      -- regardless. Otherwise another war party rides.
      local weary = tick - declared.tick >= KHEDRUN.weariness
      local relieved = declared.payload.reason == "price"
         and price.payload.price <= KHEDRUN.relief
      if relieved or stock >= KHEDRUN.target or weary then
         intents[#intents + 1] = {
            kind = "war.peace",
            location = KHEDRUN.home,
            magnitude = price.payload.price,
            loudness = "loud",
            payload = { name = KHEDRUN.name, price = price.payload.price },
            causes = { declared.id, price.id },
         }
      else
         local force = stream:int(KHEDRUN.force_min, KHEDRUN.force_max)
         intents[#intents + 1] = {
            kind = "war.raid",
            location = VESSARI.home, -- the raid happens where the grain is
            magnitude = force,
            loudness = "local",
            payload = { raider = KHEDRUN.name, target = VESSARI.name,
               force = force },
            causes = { declared.id },
         }
      end
      return intents
   end

   -- Peacetime. How insulted are we? Two fuses, and both count only
   -- what happened since the last peace — old grudges were settled
   -- by the old war.
   local settled = peace and peace.id or 0

   -- The price fuse: the last `fuse` believed prices, all above
   -- temperament. The declaration cites every price that burned it.
   local fuseful = beliefs:recent("market.price", KHEDRUN.fuse)
   if #fuseful >= KHEDRUN.fuse and fuseful[1].id > settled then
      local burning, causes = true, {}
      for i = 1, #fuseful do
         if fuseful[i].payload.price <= KHEDRUN.temperament then
            burning = false
            break
         end
         causes[#causes + 1] = fuseful[i].id
      end
      if burning then
         local last = fuseful[#fuseful].payload.price
         intents[#intents + 1] = {
            kind = "war.declared",
            location = KHEDRUN.home,
            magnitude = last,
            loudness = "loud",
            payload = { aggressor = KHEDRUN.name, target = VESSARI.name,
               reason = "price", measure = last },
            causes = causes,
         }
         return intents
      end
   end

   -- The hunger fuse: empty bellies in recent memory. Being unable
   -- to afford grain is also being priced out — this is the fuse
   -- poverty burns, and it's why a broke Khedrun goes to war instead
   -- of quietly starving.
   local hungers = beliefs:recent("grain.hunger", 8)
   local hungry, hunger_causes = 0, {}
   for i = 1, #hungers do
      local h = hungers[i]
      if h.location == KHEDRUN.home and h.id > settled
         and h.tick > tick - 7 then
         hungry = hungry + 1
         hunger_causes[#hunger_causes + 1] = h.id
      end
   end
   if hungry >= KHEDRUN.hunger_fuse then
      intents[#intents + 1] = {
         kind = "war.declared",
         location = KHEDRUN.home,
         magnitude = hungry,
         loudness = "loud",
         payload = { aggressor = KHEDRUN.name, target = VESSARI.name,
            reason = "hunger", measure = hungry },
         causes = hunger_causes,
      }
      return intents
   end

   -- Not insulted enough: go shopping for the gap.
   local need = KHEDRUN.target - stock
   if price and need > 0 then
      local limit = price.payload.price + KHEDRUN.premium
      local affordable = cents // limit
      local units = math.min(need, KHEDRUN.lot, affordable)
      if units > 0 then
         intents[#intents + 1] = {
            kind = "market.order",
            location = KHEDRUN.home,
            magnitude = units,
            loudness = "loud",
            payload = { side = "buy", units = units, limit = limit },
            causes = { price.id },
         }
      end
   end
   return intents
end

-- ---------------------------------------------------------------
-- Physics: the exchange and the battlefield. Systems, entitled to
-- truth — and the keepers of the actual books, because factions
-- cannot be trusted with conservation (law 1's money edition).
-- ---------------------------------------------------------------

local function integer_toward_zero(n, d)
   if n >= 0 then
      return n // d
   end
   return -((-n) // d)
end

local function add_physics(u)
   -- The ledger: truth, folded from the annals. Incremental (a
   -- cursor), so it's a cache of the log, never a second authority —
   -- and catch_up() runs after every emit, so nothing in a tick can
   -- act on books that don't include its own consequences (that's
   -- how a raid can never seize grain a same-day trade already
   -- moved).
   local ledger = {} -- civ name → { grain, cents }
   local homes = {} -- location → civ name, learned from foundings
   local price, price_id -- the posted price and the event that posted it
   local orders, raids = {}, {} -- recent, pruned to yesterday's
   local cursor = 0

   local function catch_up()
      while cursor < u.annals:len() do
         cursor = cursor + 1
         local e = u.annals:get(cursor)
         local p = e.payload
         if e.kind == "civ.founded" then
            ledger[p.name] = { grain = p.grain, cents = p.cents }
            homes[e.location] = p.name
         elseif e.kind == "civ.tally" then
            local books = ledger[homes[e.location]]
            books.grain = books.grain + p.harvested - p.eaten
         elseif e.kind == "market.trade" then
            local buyer, seller = ledger[p.buyer], ledger[p.seller]
            buyer.grain = buyer.grain + p.units
            buyer.cents = buyer.cents - p.total
            seller.grain = seller.grain - p.units
            seller.cents = seller.cents + p.total
         elseif e.kind == "war.spoils" then
            local raider, target = ledger[p.raider], ledger[p.target]
            raider.grain = raider.grain + p.seized
            target.grain = target.grain - p.seized - p.burned
            raider.cents = raider.cents + p.plunder
            target.cents = target.cents - p.plunder
         elseif e.kind == "market.price" then
            price, price_id = p.price, e.id
         elseif e.kind == "market.order" then
            orders[#orders + 1] = { id = e.id, tick = e.tick,
               civ = homes[e.location], side = p.side,
               units = p.units, limit = p.limit }
         elseif e.kind == "war.raid" then
            raids[#raids + 1] = { id = e.id, tick = e.tick,
               location = e.location,
               raider = p.raider, target = p.target, force = p.force }
         end
      end
   end

   local function prune(list, tick)
      local kept = {}
      for i = 1, #list do
         if list[i].tick >= tick - 1 then
            kept[#kept + 1] = list[i]
         end
      end
      return kept
   end

   -- The exchange. Yesterday's orders meet this morning's market:
   -- willing prices cross → a trade, clamped to what the buyer can
   -- pay and the seller actually holds; then the posted price moves
   -- toward the unfilled imbalance, at most PRICE_STEP_CAP a day.
   -- Naive on purpose — the card asked for a price that a reader
   -- can watch think.
   u:add_system("exchange", function(universe, _, tick)
      catch_up()
      orders = prune(orders, tick)
      local bids, offers = {}, {}
      local bid_units, offer_units = 0, 0
      for i = 1, #orders do
         local o = orders[i]
         if o.tick == tick - 1 then
            if o.side == "buy" then
               bids[#bids + 1] = o
               bid_units = bid_units + o.units
            else
               offers[#offers + 1] = o
               offer_units = offer_units + o.units
            end
         end
      end

      if #bids > 0 and #offers > 0 then
         local bid, offer = bids[1], offers[1] -- two civs: one of each, at most
         if bid.limit >= offer.limit then
            local at = math.min(math.max(price, offer.limit), bid.limit)
            local buyer, seller = ledger[bid.civ], ledger[offer.civ]
            local units = math.min(bid.units, offer.units,
               buyer.cents // at, seller.grain)
            if units > 0 then
               universe:emit{
                  kind = "market.trade",
                  location = EXCHANGE,
                  magnitude = units,
                  loudness = "loud",
                  payload = { buyer = bid.civ, seller = offer.civ,
                     units = units, price = at, total = units * at },
                  causes = { bid.id, offer.id },
               }
               catch_up()
            end
         end
      end

      if bid_units ~= offer_units and (#bids > 0 or #offers > 0) then
         local delta = integer_toward_zero(bid_units - offer_units, 2)
         if delta > PRICE_STEP_CAP then
            delta = PRICE_STEP_CAP
         elseif delta < -PRICE_STEP_CAP then
            delta = -PRICE_STEP_CAP
         end
         if delta ~= 0 then
            local reposted = math.max(price + delta, 1)
            if reposted ~= price then
               local causes = { price_id }
               for i = 1, #bids do causes[#causes + 1] = bids[i].id end
               for i = 1, #offers do causes[#causes + 1] = offers[i].id end
               universe:emit{
                  kind = "market.price",
                  location = EXCHANGE,
                  magnitude = reposted - price >= 0 and reposted - price
                     or price - reposted,
                  loudness = "loud",
                  payload = { price = reposted, delta = reposted - price },
                  causes = causes,
               }
               catch_up()
            end
         end
      end
   end)

   -- The battlefield. Yesterday's war parties reach the granaries
   -- this morning; what they seize is the *actual* stock's verdict,
   -- not the raider's plan — factions ride on beliefs, physics pays
   -- out on truth.
   u:add_system("battle", function(universe, _, tick)
      catch_up()
      raids = prune(raids, tick)
      for i = 1, #raids do
         local raid = raids[i]
         if raid.tick == tick - 1 then
            local target = ledger[raid.target]
            local seized = math.min(raid.force, target.grain)
            local burned = math.min(raid.force // KHEDRUN.torch_divisor,
               target.grain - seized)
            local plunder = math.min(raid.force * KHEDRUN.plunder_rate,
               target.cents)
            universe:emit{
               kind = "war.spoils",
               location = raid.location,
               magnitude = seized + burned,
               loudness = "local",
               payload = { raider = raid.raider, target = raid.target,
                  seized = seized, plunder = plunder, burned = burned },
               causes = { raid.id },
            }
            catch_up()
         end
      end
   end)
end

-- ---------------------------------------------------------------
-- The world, assembled.
-- ---------------------------------------------------------------

local function found(u, civ)
   return u:emit{
      kind = "civ.founded",
      location = civ.home,
      magnitude = civ.grain,
      loudness = "loud",
      payload = { name = civ.name, grain = civ.grain, cents = civ.cents },
      causes = { 1 }, -- genesis; a founding needs no other excuse yet
   }
end

return function(seed)
   local u = Universe.new(seed, { distance = distance })
   found(u, VESSARI)
   found(u, KHEDRUN)
   u:emit{
      kind = "market.price",
      location = EXCHANGE,
      magnitude = 0,
      loudness = "loud",
      payload = { price = OPENING_PRICE, delta = 0 },
      causes = { 1 },
   }
   add_physics(u)
   u:add_faction(VESSARI.name, VESSARI.home, vessari_decide)
   u:add_faction(KHEDRUN.name, KHEDRUN.home, khedrun_decide)
   return u
end
