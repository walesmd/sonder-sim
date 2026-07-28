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
--     independent fold. With today's pass-through courier this is
--     always a bug: a civ can be neither lying nor misinformed. The
--     day news travels at ship speed (card 122), drift between
--     belief and truth becomes the product, not the crime — specs
--     will relax THIS list, and only this list.

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

local function mismatch(s, id, name, field, reported, audited)
   s.mismatches[#s.mismatches + 1] = {
      id = id, name = name, field = field,
      reported = reported, audited = audited,
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
      if b.grain ~= p.stock then
         mismatch(s, e.id, name, "grain", p.stock, b.grain)
      end
      if b.cents ~= p.cents then
         mismatch(s, e.id, name, "cents", p.cents, b.cents)
      end
   end,

   ["market.trade"] = function(s, e)
      local p = e.payload
      if p.total ~= p.units * p.price then
         flag(s, e.id, "trade total %d¢ is not %d units × %d¢",
            p.total, p.units, p.price)
      end
      local buyer, seller = s.books[p.buyer], s.books[p.seller]
      if not (buyer and seller) then
         flag(s, e.id, "a trade between parties the audit has never "
            .. "met (%s, %s)", p.buyer, p.seller)
         return
      end
      buyer.grain = buyer.grain + p.units
      buyer.cents = buyer.cents - p.total
      seller.grain = seller.grain - p.units
      seller.cents = seller.cents + p.total
      s.totals.traded_units = s.totals.traded_units + p.units
      s.totals.traded_cents = s.totals.traded_cents + p.total
   end,

   ["war.spoils"] = function(s, e)
      local p = e.payload
      local raider, target = s.books[p.raider], s.books[p.target]
      if not (raider and target) then
         flag(s, e.id, "spoils between parties the audit has never "
            .. "met (%s, %s)", p.raider, p.target)
         return
      end
      raider.grain = raider.grain + p.seized
      raider.cents = raider.cents + p.plunder
      target.grain = target.grain - p.seized - p.burned
      target.cents = target.cents - p.plunder
      s.totals.seized = s.totals.seized + p.seized
      s.totals.plunder = s.totals.plunder + p.plunder
      s.totals.burned = s.totals.burned + p.burned
   end,
}

-- Is a kind one this audit knows how to book? (The coverage spec
-- walks the vocabulary through this.)
function Audit.classified(kind)
   return effects[kind] ~= nil
end

-- Fold the annals into a report. Pure: same log, same report, on
-- every machine — which is why the negative-balance sweep iterates
-- founding order, never pairs().
function Audit.of(annals)
   local s = {
      books = {}, names = {}, homes = {},
      founded = { grain = 0, cents = 0 },
      totals = { harvested = 0, eaten = 0, burned = 0,
         seized = 0, plunder = 0, traded_units = 0, traded_cents = 0 },
      violations = {}, mismatches = {}, unclassified = {},
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
   -- Money has no doors at all: every cent held was founded. Matter
   -- has exactly two, both recorded events: harvests grow it, eating
   -- and the torch destroy it. Trades and spoils only move things,
   -- so they appear in neither identity.
   if held.cents ~= s.founded.cents then
      flag(s, annals:len(), "money is not conserved: %d¢ founded, "
         .. "%d¢ held", s.founded.cents, held.cents)
   end
   local grain_expected = s.founded.grain + s.totals.harvested
      - s.totals.eaten - s.totals.burned
   if held.grain ~= grain_expected then
      flag(s, annals:len(), "matter is not conserved: expected %d "
         .. "sacks (%d founded + %d harvested − %d eaten − %d "
         .. "burned), held %d", grain_expected, s.founded.grain,
         s.totals.harvested, s.totals.eaten, s.totals.burned,
         held.grain)
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
      unclassified = s.unclassified,
   }
end

return Audit
