-- src/sonder/audit.lua — the double-entry audit: the fold is the
-- engine's, the books' meaning is the world's.
--
-- A projection (law 2): a pure fold over a prefix of the annals,
-- computable by anyone holding the events and the world's legs. The
-- annals already rejects events with the wrong *shape*; this module
-- checks the *arithmetic*. Grammar at the door, accounting at the
-- telescope.
--
-- Since card 160 the audit is machinery only. A world supplies its
-- LEGS (worlds/<name>_audit.lua): the ordered book columns and their
-- negative-balance phrasings, the commodity→column map, which column
-- is money, an effects entry for every world kind (false =
-- classified-and-neutral; a function applies the ledger legs), and
-- the conservation identities checked at the end — closed systems
-- and open ones alike declare themselves. The engine supplies what
-- the litmus proved framework-shaped: the fold, the road ledger and
-- the framework cargo/payment legs, the belief-drift certification,
-- the negative-balance sweep, and the three findings it keeps apart:
--
--   violations — arithmetic that cannot be right in any universe.
--   mismatches — a claim disagreeing with the independent fold;
--     with the road supplied, each is held to
--     reported + in-flight == audited, to the cent.
--   unexplained — mismatches no road accounts for: lies.
--     (nil without a road — unchecked is not clean.)

local Audit = {}

-- The helper library handed to every leg. Legs never touch s's
-- internals directly except through these; that's what keeps the
-- fold's discipline (determinism, copies, ordered walks) in one
-- place.
local lib = {}

function lib.flag(s, id, fmt, ...)
   s.violations[#s.violations + 1] =
      ("event %d: " .. fmt):format(id, ...)
end

function lib.mismatch(s, id, name, field, reported, audited, on_road)
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

-- An actor enters the books: one row per declared column, opening
-- balances where the world says so, zero elsewhere. Homes feed the
-- belief-drift machinery; founding order feeds every ordered sweep.
function lib.enroll(s, name, home, opening)
   local b = {}
   for i = 1, #s.legs.columns do
      local col = s.legs.columns[i].key
      b[col] = opening[col] or 0
   end
   s.books[name] = b
   s.names[#s.names + 1] = name
   s.seats[name] = home
   s.pending[name] = {}
end

-- Value takes to the road: an entry on the road ledger under the
-- departure's own event id, drained exactly by the arrival that
-- cites it. deltas is {column = amount}; sums are commutative, so
-- the pairs() walk touches no ordered outcome.
function lib.embark(s, e, deltas)
   s.roads[e.id] = deltas
   for col, n in pairs(deltas) do
      s.on_road[col] = s.on_road[col] + n
   end
end

-- The arrival's claim against the road ledger; nil if nothing under
-- that departure id. Draining is the caller's assertion that the
-- entry matched — the engine only does the arithmetic.
function lib.disembark(s, cause_id)
   local entry = s.roads[cause_id]
   if not entry then
      return nil
   end
   s.roads[cause_id] = nil
   for col, n in pairs(entry) do
      s.on_road[col] = s.on_road[col] - n
   end
   return entry
end

-- News of a book-moving event starts riding toward an actor's home —
-- the same integer ceiling the courier uses. Until it lands, its
-- effect is what that actor's claims are honestly missing.
function lib.ship(s, e, name, deltas)
   if not s.road then
      return
   end
   local list = s.pending[name]
   list[#list + 1] = {
      arrives = e.tick + s.road.days(e.location, s.seats[name], e.tick),
      deltas = deltas,
   }
end

-- What is still on the road to this actor at a claim's moment, per
-- column — and so honestly absent from the claim. Landed entries
-- prune; they are in the actor's own books by the courier's
-- contract.
function lib.drift(s, name, tick)
   if not s.road then
      return nil
   end
   local sums = {}
   for i = 1, #s.legs.columns do
      sums[s.legs.columns[i].key] = 0
   end
   local kept = {}
   local list = s.pending[name]
   for i = 1, #list do
      local x = list[i]
      if x.arrives > tick then
         kept[#kept + 1] = x
         for col, n in pairs(x.deltas) do
            sums[col] = sums[col] + n
         end
      end
   end
   s.pending[name] = kept
   return sums
end

-- The framework legs: the road grammar means the same thing in
-- every world — matter and money between places, net zero per
-- shipment. Which column moves is the world's commodity map's
-- answer.
local framework_effects = {
   ["cargo.shipped"] = function(s, e)
      local p = e.payload
      local sender = s.books[p.sender]
      if not (sender and s.books[p.recipient]) then
         lib.flag(s, e.id, "cargo between parties the audit has never "
            .. "met (%s, %s)", p.sender, p.recipient)
         return
      end
      local col = s.legs.commodities[p.commodity]
      if not col then
         lib.flag(s, e.id, "cargo in a commodity the audit cannot book (%s)",
            p.commodity)
         return
      end
      sender[col] = sender[col] - p.units
      lib.embark(s, e, { [col] = p.units })
      lib.ship(s, e, p.sender, { [col] = -p.units })
   end,

   ["cargo.delivered"] = function(s, e)
      local p = e.payload
      local recipient = s.books[p.recipient]
      if not recipient then
         lib.flag(s, e.id, "a delivery to %s, whom the audit has never met",
            p.recipient)
         return
      end
      local col = s.legs.commodities[p.commodity]
      local entry = lib.disembark(s, e.causes[1])
      if not entry then
         lib.flag(s, e.id, "a delivery citing no departure on the road")
         return
      end
      if not col or entry[col] ~= p.units then
         lib.flag(s, e.id, "a delivery that does not match its departure: "
            .. "%d units against %d on the road", p.units,
            col and entry[col] or 0)
         return
      end
      recipient[col] = recipient[col] + p.units
      lib.ship(s, e, p.recipient, { [col] = p.units })
   end,

   ["payment.shipped"] = function(s, e)
      local p = e.payload
      local payer = s.books[p.payer]
      if not (payer and s.books[p.payee]) then
         lib.flag(s, e.id, "payment between parties the audit has never "
            .. "met (%s, %s)", p.payer, p.payee)
         return
      end
      local money = s.legs.money
      payer[money] = payer[money] - p.amount
      lib.embark(s, e, { [money] = p.amount })
      lib.ship(s, e, p.payer, { [money] = -p.amount })
   end,

   ["payment.delivered"] = function(s, e)
      local p = e.payload
      local payee = s.books[p.payee]
      if not payee then
         lib.flag(s, e.id, "a payment to %s, whom the audit has never met",
            p.payee)
         return
      end
      local money = s.legs.money
      local entry = lib.disembark(s, e.causes[1])
      if not entry then
         lib.flag(s, e.id, "a payment delivery citing no departure on the road")
         return
      end
      if entry[money] ~= p.amount then
         lib.flag(s, e.id, "a payment that does not match its departure: "
            .. "%d¢ against %d¢ on the road", p.amount, entry[money] or 0)
         return
      end
      payee[money] = payee[money] + p.amount
      lib.ship(s, e, p.payee, { [money] = p.amount })
   end,
}

-- Is a kind one this audit (engine plus these legs) knows how to
-- book? The coverage spec walks each world's vocabulary through
-- this: an unclassified kind cannot default to "touches nothing".
function Audit.classified(legs, kind)
   return framework_effects[kind] ~= nil or legs.effects[kind] ~= nil
end

-- Fold the annals into a report, under a world's legs. Pure: same
-- log, same legs, same report, on every machine. The optional road
-- — { days = (from, to, tick) → integer }, the same pricing the
-- freight rides (Universe:days, card 170) — lets the fold certify
-- mismatches; annals + legs + road produce the same report for any
-- holder of all three. (An honest limit, on the record since card
-- 166: this explains drift by *freight* pace, not by carriage
-- rows — a world whose news and freight travel differently owes
-- the audit a richer road when its migration card arrives; see
-- card 163.)
function Audit.of(annals, legs, road)
   assert(type(legs) == "table" and type(legs.effects) == "table"
      and type(legs.columns) == "table"
      and type(legs.identities) == "function",
      "audit: a world's legs are required (columns, effects, identities)")
   if road ~= nil then
      assert(type(road) == "table" and type(road.days) == "function",
         "audit: road must carry days(from, to, tick)")
      road = { days = road.days }
   end
   local s = {
      legs = legs,
      books = {}, names = {}, seats = {},
      violations = {}, mismatches = {}, unclassified = {},
      road = road, pending = {},
      unexplained = road and {} or nil,
      roads = {},
      on_road = {},
      world = {}, -- the legs' own scratch: founded, totals, whatever
   }
   for i = 1, #legs.columns do
      s.on_road[legs.columns[i].key] = 0
   end

   for id = 1, annals:len() do
      local e = annals:get(id)
      local effect = framework_effects[e.kind]
      if effect == nil then
         effect = legs.effects[e.kind]
      end
      if type(effect) == "function" then
         effect(s, e, lib)
      elseif effect == nil then
         s.unclassified[e.kind] = (s.unclassified[e.kind] or 0) + 1
      end
      -- the negative sweep, in founding order and declared column
      -- order — nothing here walks pairs()
      for i = 1, #s.names do
         local b = s.books[s.names[i]]
         for j = 1, #legs.columns do
            local col = legs.columns[j]
            if b[col.key] < 0 then
               lib.flag(s, id, col.negative, s.names[i], b[col.key])
            end
         end
      end
   end

   local held = {}
   for j = 1, #legs.columns do
      held[legs.columns[j].key] = 0
   end
   for i = 1, #s.names do
      local b = s.books[s.names[i]]
      for j = 1, #legs.columns do
         local col = legs.columns[j].key
         held[col] = held[col] + b[col]
      end
   end
   s.held = held

   -- the world's conservation laws, whatever they are — closed
   -- systems and open ones alike declare themselves
   legs.identities(s, lib, annals:len())

   return {
      events = annals:len(),
      books = s.books,
      names = s.names,
      held = held,
      on_road = s.on_road,
      world = s.world,
      violations = s.violations,
      mismatches = s.mismatches,
      unexplained = s.unexplained, -- nil without a road: unchecked ≠ clean
      unclassified = s.unclassified,
   }
end

return Audit
