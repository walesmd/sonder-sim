-- src/sonder/audit.lua — the double-entry audit: every credit that
-- leaves one treasury arrives in another, and matter is conserved
-- unless explicitly grown or burned — both doors with signs on them.
--
-- A projection (law 2): a pure fold over a prefix of the annals,
-- computable by anyone holding the events. The spec suite computes
-- it, main.lua's --audit computes it, a stranger holding your
-- universe file computes it, and they must all get the same report.
-- The annals already rejects events with the wrong *shape*; this
-- module checks the *arithmetic*. Grammar at the door, accounting at
-- the telescope.
--
-- The audit never raises. It returns a report, and two findings are
-- deliberately kept apart in it:
--
--   violations — arithmetic that cannot be right in any universe:
--     value conjured or vanished, a treasury driven negative, a
--     trade whose total is not units × price, conservation broken
--     across the whole history.
--   mismatches — a civ's self-reported tally disagreeing with the
--     independent fold. Once news travels at ship speed (card 122),
--     drift is the product, not the crime: a tally written while a
--     trade's news is still on the road is honestly stale. But
--     honesty has an arithmetic: hand Audit.of the world's road —
--     { distance, channel_speed }, the same map the courier reads —
--     and it replays what was still in flight at each tally,
--     holding every mismatch to reported + in-flight == audited,
--     to the cent. A mismatch that passes is *explained*:
--     ignorance, working as built. One that fails lands in
--     report.unexplained: somebody's books are lying, and no road
--     accounts for it. Without the road the audit still lists
--     mismatches; it just can't certify them (unexplained is nil,
--     not empty — "unchecked" is not "clean").

local Audit = {}

-- What each kind of event does to the books. Every kind in the
-- vocabulary must appear here — audit_spec walks the vocabulary and
-- holds that line — because an unclassified kind cannot default to
-- "touches nothing": a future mining kind silently treated as
-- neutral would rot the audit from the inside. `false` means
-- classified-and-neutral (no ledger legs); a function applies the
-- legs. Kinds met in the wild that this era doesn't know (foreign
-- logs, future vocabularies) are counted in report.unclassified
-- rather than crashing the fold — writes are forever, readers age.

local function flag(s, id, fmt, ...)
   s.violations[#s.violations + 1] =
      ("event %d: " .. fmt):format(id, ...)
end

local function mismatch(s, id, name, field, reported, audited, on_road)
   local row = {
      id = id, name = name, field = field,
      reported = reported, audited = audited,
   }
   if on_road ~= nil then
      row.in_flight = on_road
      row.explained = reported + on_road == audited
      if not row.explained then
         s.unexplained[#s.unexplained + 1] = row
      end
   end
   s.mismatches[#s.mismatches + 1] = row
end

-- When a money-moving event happens, its news starts riding toward
-- each involved civ's home — the same integer ceiling the courier
-- uses, replayed from the log. Until it lands, its effect is what a
-- civ's claim is honestly missing.
local function ship(s, e, name, grain, cents)
   if not s.road then
      return
   end
   local d = s.road.distance(e.location, s.seats[name], e.tick)
   local speed = s.road.channel_speed
   local list = s.pending[name]
   list[#list + 1] = {
      arrives = e.tick + (d + speed - 1) // speed,
      grain = grain, cents = cents,
   }
end

local effects = {
   ["universe.genesis"] = false,
   ["grain.hunger"] = false,
   ["market.order"] = false,
   ["market.price"] = false,
   ["war.declared"] = false,
   ["war.march"] = false,
   ["war.raid"] = false,
   ["war.peace"] = false,

   ["civ.founded"] = function(s, e)
      local p = e.payload
      s.books[p.name] = { grain = p.grain, cents = p.cents }
      s.names[#s.names + 1] = p.name
      s.homes[e.location] = p.name
      s.seats[p.name] = e.location
      s.pending[p.name] = {}
      s.founded.grain = s.founded.grain + p.grain
      s.founded.cents = s.founded.cents + p.cents
   end,

   ["civ.tally"] = function(s, e)
      local p = e.payload
      local name = s.homes[e.location]
      local b = name and s.books[name]
      if not b then
         flag(s, e.id, "a tally from %s, where nobody was founded",
            e.location)
         return
      end
      -- harvested and eaten are the day's physical record — the only
      -- one there is, so the fold trusts them; stock and cents are
      -- the civ's *claim* about its own books, and claims get checked.
      b.grain = b.grain + p.harvested - p.eaten
      s.totals.harvested = s.totals.harvested + p.harvested
      s.totals.eaten = s.totals.eaten + p.eaten
      -- What is still on the road to this civ — and so honestly
      -- absent from its claim. Entries that have landed are in the
      -- civ's own books by the courier's contract, so they prune;
      -- entries still riding sum into the expected drift.
      local road_grain, road_cents
      if s.road then
         road_grain, road_cents = 0, 0
         local kept = {}
         local list = s.pending[name]
         for i = 1, #list do
            local x = list[i]
            if x.arrives > e.tick then
               kept[#kept + 1] = x
               road_grain = road_grain + x.grain
               road_cents = road_cents + x.cents
            end
         end
         s.pending[name] = kept
      end
      if b.grain ~= p.stock then
         mismatch(s, e.id, name, "grain", p.stock, b.grain, road_grain)
      end
      if b.cents ~= p.cents then
         mismatch(s, e.id, name, "cents", p.cents, b.cents, road_cents)
      end
   end,

   ["market.trade"] = function(s, e)
      -- Since card 153 the trade is the agreement, not the movement:
      -- the goods and the payment ride the roads as cargo/payment
      -- events and the books move on those legs. What's left to
      -- check here is the arithmetic of the promise itself.
      local p = e.payload
      if p.total ~= p.units * p.price then
         flag(s, e.id, "trade total %d¢ is not %d units × %d¢",
            p.total, p.units, p.price)
      end
      if not (s.books[p.buyer] and s.books[p.seller]) then
         flag(s, e.id, "a trade between parties the audit has never "
            .. "met (%s, %s)", p.buyer, p.seller)
         return
      end
      s.totals.traded_units = s.totals.traded_units + p.units
      s.totals.traded_cents = s.totals.traded_cents + p.total
   end,

   -- The road legs (card 153). A departure debits the sender and
   -- puts the goods on the road ledger under the departure's own
   -- event id; the arrival cites that id, drains it exactly, and
   -- credits the recipient. Net zero per shipment, to the sack and
   -- the cent — and the audit never checks punctuality, only
   -- conservation: how long a road takes is physics' business.
   ["cargo.shipped"] = function(s, e)
      local p = e.payload
      local sender = s.books[p.sender]
      if not (sender and s.books[p.recipient]) then
         flag(s, e.id, "cargo between parties the audit has never "
            .. "met (%s, %s)", p.sender, p.recipient)
         return
      end
      if p.commodity ~= "grain" then
         flag(s, e.id, "cargo in a commodity the audit cannot book (%s)",
            p.commodity)
         return
      end
      sender.grain = sender.grain - p.units
      s.roads[e.id] = { grain = p.units, cents = 0 }
      s.on_road.grain = s.on_road.grain + p.units
      ship(s, e, p.sender, -p.units, 0)
   end,

   ["cargo.delivered"] = function(s, e)
      local p = e.payload
      local recipient = s.books[p.recipient]
      if not recipient then
         flag(s, e.id, "a delivery to %s, whom the audit has never met",
            p.recipient)
         return
      end
      local road = s.roads[e.causes[1]]
      if not road then
         flag(s, e.id, "a delivery citing no departure on the road")
         return
      end
      if p.commodity ~= "grain" or road.grain ~= p.units then
         flag(s, e.id, "a delivery that does not match its departure: "
            .. "%d units against %d on the road", p.units, road.grain)
         return
      end
      s.roads[e.causes[1]] = nil
      s.on_road.grain = s.on_road.grain - p.units
      recipient.grain = recipient.grain + p.units
      ship(s, e, p.recipient, p.units, 0)
   end,

   ["payment.shipped"] = function(s, e)
      local p = e.payload
      local payer = s.books[p.payer]
      if not (payer and s.books[p.payee]) then
         flag(s, e.id, "payment between parties the audit has never "
            .. "met (%s, %s)", p.payer, p.payee)
         return
      end
      payer.cents = payer.cents - p.amount
      s.roads[e.id] = { grain = 0, cents = p.amount }
      s.on_road.cents = s.on_road.cents + p.amount
      ship(s, e, p.payer, 0, -p.amount)
   end,

   ["payment.delivered"] = function(s, e)
      local p = e.payload
      local payee = s.books[p.payee]
      if not payee then
         flag(s, e.id, "a payment to %s, whom the audit has never met",
            p.payee)
         return
      end
      local road = s.roads[e.causes[1]]
      if not road then
         flag(s, e.id, "a payment delivery citing no departure on the road")
         return
      end
      if road.cents ~= p.amount then
         flag(s, e.id, "a payment that does not match its departure: "
            .. "%d¢ against %d¢ on the road", p.amount, road.cents)
         return
      end
      s.roads[e.causes[1]] = nil
      s.on_road.cents = s.on_road.cents - p.amount
      payee.cents = payee.cents + p.amount
      ship(s, e, p.payee, 0, p.amount)
   end,

   ["war.spoils"] = function(s, e)
      -- The verdict and a departure leg in one (card 153): the
      -- target's losses happen here, where the raid did, but the
      -- seized goods leave WITH the party — onto the road ledger
      -- under this event's id, credited to the raider only when
      -- war.returned cites it.
      local p = e.payload
      local raider, target = s.books[p.raider], s.books[p.target]
      if not (raider and target) then
         flag(s, e.id, "spoils between parties the audit has never "
            .. "met (%s, %s)", p.raider, p.target)
         return
      end
      target.grain = target.grain - p.seized - p.burned
      target.cents = target.cents - p.plunder
      s.totals.seized = s.totals.seized + p.seized
      s.totals.plunder = s.totals.plunder + p.plunder
      s.totals.burned = s.totals.burned + p.burned
      s.roads[e.id] = { grain = p.seized, cents = p.plunder }
      s.on_road.grain = s.on_road.grain + p.seized
      s.on_road.cents = s.on_road.cents + p.plunder
      ship(s, e, p.target, -p.seized - p.burned, -p.plunder)
   end,

   ["war.returned"] = function(s, e)
      local p = e.payload
      local raider = s.books[p.raider]
      if not raider then
         flag(s, e.id, "a war party returning to %s, whom the audit "
            .. "has never met", p.raider)
         return
      end
      local road = s.roads[e.causes[1]]
      if not road then
         flag(s, e.id, "a war party returning with no spoils on the road")
         return
      end
      if road.grain ~= p.seized or road.cents ~= p.plunder then
         flag(s, e.id, "a return that does not match its spoils: "
            .. "%d sacks and %d¢ against %d and %d on the road",
            p.seized, p.plunder, road.grain, road.cents)
         return
      end
      s.roads[e.causes[1]] = nil
      s.on_road.grain = s.on_road.grain - p.seized
      s.on_road.cents = s.on_road.cents - p.plunder
      raider.grain = raider.grain + p.seized
      raider.cents = raider.cents + p.plunder
      ship(s, e, p.raider, p.seized, p.plunder)
   end,
}

-- Is a kind one this audit knows how to book? (The coverage spec
-- walks the vocabulary through this.)
function Audit.classified(kind)
   return effects[kind] ~= nil
end

-- Fold the annals into a report. Pure: same log, same report, on
-- every machine — which is why the negative-balance sweep iterates
-- founding order, never pairs(). The optional road —
-- { distance = function(from, to, tick) -> days, channel_speed }, the
-- same map and divisor the courier reads — lets the fold certify
-- mismatches (see the header); annals + road produce the same
-- report for any holder of both.
function Audit.of(annals, road)
   if road ~= nil then
      assert(type(road) == "table" and type(road.distance) == "function",
         "audit: road must carry distance(from, to, tick)")
      road = { distance = road.distance,
         channel_speed = road.channel_speed or 1 }
      assert(math.type(road.channel_speed) == "integer"
         and road.channel_speed >= 1,
         "audit: road.channel_speed must be a positive integer")
   end
   local s = {
      books = {}, names = {}, homes = {}, seats = {},
      founded = { grain = 0, cents = 0 },
      totals = { harvested = 0, eaten = 0, burned = 0,
         seized = 0, plunder = 0, traded_units = 0, traded_cents = 0 },
      violations = {}, mismatches = {}, unclassified = {},
      road = road, pending = {},
      unexplained = road and {} or nil,
      -- The road ledger (card 153): matter and money between places,
      -- one entry per departure event id, drained exactly by the
      -- arrival that cites it. on_road runs incrementally so the
      -- conservation identities never iterate a hash.
      roads = {},
      on_road = { grain = 0, cents = 0 },
   }
   for id = 1, annals:len() do
      local e = annals:get(id)
      local effect = effects[e.kind]
      if effect then
         effect(s, e)
      elseif effect == nil then
         s.unclassified[e.kind] = (s.unclassified[e.kind] or 0) + 1
      end
      for i = 1, #s.names do
         local b = s.books[s.names[i]]
         if b.grain < 0 then
            flag(s, id, "%s holds negative grain (%d sacks)",
               s.names[i], b.grain)
         end
         if b.cents < 0 then
            flag(s, id, "%s holds a negative treasury (%d¢)",
               s.names[i], b.cents)
         end
      end
   end

   local held = { grain = 0, cents = 0 }
   for i = 1, #s.names do
      local b = s.books[s.names[i]]
      held.grain = held.grain + b.grain
      held.cents = held.cents + b.cents
   end
   -- The two conservation laws, checked across the whole history.
   -- Money has no doors at all: every cent held or riding was
   -- founded. Matter has exactly two, both recorded events: harvests
   -- grow it, eating and the torch destroy it. Movement appears in
   -- neither identity — but since card 153 some of what exists is
   -- *between places*, so each identity carries a road term. Net
   -- zero, with roads.
   if held.cents + s.on_road.cents ~= s.founded.cents then
      flag(s, annals:len(), "money is not conserved: %d¢ founded, "
         .. "%d¢ held, %d¢ on roads", s.founded.cents, held.cents,
         s.on_road.cents)
   end
   local grain_expected = s.founded.grain + s.totals.harvested
      - s.totals.eaten - s.totals.burned
   if held.grain + s.on_road.grain ~= grain_expected then
      flag(s, annals:len(), "matter is not conserved: expected %d "
         .. "sacks (%d founded + %d harvested − %d eaten − %d "
         .. "burned), held %d with %d on roads", grain_expected,
         s.founded.grain, s.totals.harvested, s.totals.eaten,
         s.totals.burned, held.grain, s.on_road.grain)
   end

   return {
      events = annals:len(),
      books = s.books,
      names = s.names,
      founded = s.founded,
      held = held,
      totals = s.totals,
      violations = s.violations,
      mismatches = s.mismatches,
      unexplained = s.unexplained, -- nil without a road: unchecked ≠ clean
      unclassified = s.unclassified,
      on_road = s.on_road, -- matter and money between places, right now
   }
end

return Audit
