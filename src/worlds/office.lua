-- src/worlds/office.lua — Bellwether & Co.: one employer, ten
-- minds, and a business they are trying to build together.
--
-- This is content, not engine — and deliberately the strangest
-- content yet (card 160): the second world, built to prove the
-- engine never knew what space was. Every employee is a faction in
-- the engine's sense — a decision-maker with a belief store and a
-- private chronology — which makes this the constitution's
-- notable-figures zoom tier, arrived early. Distance is social: the
-- org chart is the map, and news, salaries, and work product all
-- ride it at the courier's usual pace. The economy is the project's
-- first OPEN system: money enters as client revenue and leaves as
-- daily living and rent; work is made at desks and delivered out
-- the door. Its identities are declared to match.
--
-- The charter (docs/worlds/office/charter.md) is the eval this file
-- answers to. Everyone here is an example of what the system must
-- support, never a dictation that they exist.

local Universe = require "sonder.universe"
local Travel = require "sonder.travel"
local Roads = require "sonder.roads"

-- The cast. Salaries are weekly; cents are starting savings;
-- temperament constants are per-role, the Vessari/Khedrun pattern
-- at human scale.
local COMPANY_CENTS = 40000 -- the treasury mara keeps
local SAVINGS = 150 -- everyone else starts with pocket money
local SPEND = 15 -- daily living, clamped to what's held
local RENT = 250 -- weekly, from the treasury, out the door
local PAYDAY = 7 -- every seventh day
local MAKE, MAKE_LOW = 2, 1 -- units a maker makes: heartened, not
local LOT = 6 -- work ships up the chart in batches
local DEAL_UNITS, DEAL_PRICE = 12, 55 -- what a client says yes to
local DEAL_CHANCE = 3 -- one-in-three per pitched day
local LOST_CHANCE = 18 -- one-in-eighteen: the client says no, quietly
local MORALE_DAYS = 8 -- how long bad news dims a mind

local CAST = {
   { name = "mara", role = "founder", salary = 0, boss = nil },
   { name = "sef", role = "manager", salary = 150, boss = "mara" },
   { name = "tobin", role = "manager", salary = 150, boss = "mara" },
   { name = "amity", role = "ops", salary = 110, boss = "mara" },
   { name = "ivo", role = "seller", salary = 130, boss = "sef" },
   { name = "prue", role = "seller", salary = 130, boss = "sef" },
   { name = "dane", role = "maker", salary = 100, boss = "tobin" },
   { name = "okka", role = "maker", salary = 100, boss = "tobin" },
   { name = "lish", role = "maker", salary = 100, boss = "tobin" },
   { name = "vern", role = "maker", salary = 100, boss = "tobin" },
}

local BOSS = {}
for i = 1, #CAST do
   BOSS[CAST[i].name] = CAST[i].boss
end

-- The map: the org chart. A person is a place (an address that
-- sits), and distance is hops through the chart — same team is
-- close, cross-department is far, and news crosses the company at
-- the courier's usual pace. The engine neither knows nor cares
-- that this map has no geometry: distance was always the world's
-- answer to give.
local function depth_path(name)
   local path = {}
   while name do
      path[#path + 1] = name
      name = BOSS[name]
   end
   return path
end

local function on_chart(name)
   return name == "mara" or BOSS[name] ~= nil
end

local function distance(from, to, _)
   if from == to then
      return 0
   end
   if not (on_chart(from) and on_chart(to)) then
      return 0 -- the void, clients, anywhere off the chart: adjacent
   end
   local a, b = depth_path(from), depth_path(to)
   -- hops to the lowest common ancestor, counted from both sides
   local seen = {}
   for i = 1, #a do
      seen[a[i]] = i - 1 -- hops from `from` up to this ancestor
   end
   for j = 1, #b do
      if seen[b[j]] then
         return seen[b[j]] + (j - 1)
      end
   end
   return #a + #b -- disjoint charts; cannot happen with one company
end

-- ---------------------------------------------------------------
-- Believed bookkeeping: pure functions of a belief store, the space
-- world's pattern at desk scale. A person's books are two columns —
-- cents and work — and every event that moves them happens at their
-- own desk, so self-knowledge stays exact (card 153's dividend).
-- ---------------------------------------------------------------

-- Belief windows are sized to the crowd, not the couple: ten
-- people's events arrive at every desk, and paydays emit nine
-- payments in one burst. A window of 8 — generous for two
-- civilizations — silently evicted sef's salary from mara's fold
-- every single week (found the hard way: 113 phantom mismatches in
-- 120 days, every one exactly 150¢ — the first payment out the
-- door). Three mornings' worth of the whole cast is margin.
local WINDOW = 3 * #CAST

local function my_latest_tally(beliefs, name)
   local tallies = beliefs:recent("office.tally", WINDOW)
   for i = #tallies, 1, -1 do
      if tallies[i].location == name then
         return tallies[i]
      end
   end
   return nil
end

local function my_hiring(beliefs, name)
   local hired = beliefs:recent("office.hired", #CAST + 2)
   for i = #hired, 1, -1 do
      if hired[i].payload.name == name then
         return hired[i]
      end
   end
   return nil
end

local function believed_books(beliefs, name)
   local work, cents, since, absorbed
   local tally = my_latest_tally(beliefs, name)
   if tally then
      work, cents, since = tally.payload.work, tally.payload.cents, tally.id
      absorbed = tally.tick
   else
      local hired = my_hiring(beliefs, name)
      work, cents, since = 0, hired.payload.cents, hired.id
      absorbed = hired.tick
   end
   for _, c in ipairs(beliefs:recent("cargo.shipped", WINDOW)) do
      if c.learned > absorbed and c.payload.sender == name then
         work = work - c.payload.units
      end
   end
   for _, c in ipairs(beliefs:recent("cargo.delivered", WINDOW)) do
      if c.learned > absorbed and c.payload.recipient == name then
         work = work + c.payload.units
      end
   end
   for _, m in ipairs(beliefs:recent("payment.shipped", WINDOW)) do
      if m.learned > absorbed and m.payload.payer == name then
         cents = cents - m.payload.amount
      end
   end
   for _, m in ipairs(beliefs:recent("payment.delivered", WINDOW)) do
      if m.learned > absorbed and m.payload.payee == name then
         cents = cents + m.payload.amount
      end
   end
   for _, d in ipairs(beliefs:recent("office.delivered", WINDOW)) do
      if d.learned > absorbed and d.payload.seller == name then
         work = work - d.payload.units
      end
   end
   for _, r in ipairs(beliefs:recent("office.revenue", WINDOW)) do
      if r.learned > absorbed and name == "mara" then
         cents = cents + r.payload.amount
      end
   end
   return work, cents, since
end

-- Bad news dims a mind for a while: any deal lost in recent believed
-- memory, still fresh by its own date. Morale is a reading of the
-- belief store, so it dims when the news *arrives*, not when the
-- thing happened — four desks away, that is four days later.
local function discouraged(beliefs, tick)
   local losses = beliefs:recent("office.deal_lost", 4)
   for i = 1, #losses do
      if losses[i].tick > tick - MORALE_DAYS then
         return true
      end
   end
   return false
end

-- The day begins the same way for everyone: spend a little to live,
-- make what your role makes, and write the day's books. The tally
-- goes first in the day's intents, so its claims describe the books
-- before anything ships (the audit checks claims at the tally's own
-- position in the log).
local function open_the_day(person, beliefs, made, extra_spend)
   local work, cents, prev = believed_books(beliefs, person.name)
   local spent = math.min(cents, SPEND + (extra_spend or 0))
   work = work + made
   cents = cents - spent
   return { {
      kind = "office.tally",
      location = person.name,
      magnitude = work,
      loudness = "quiet",
      payload = { made = made, spent = spent, work = work, cents = cents },
      causes = { prev },
   } }, work, cents
end

-- Ship a batch of work up (or across) the chart. Minds dispatch
-- their own shipments — safe since card 153, because a mind's
-- knowledge of its own books is exact.
local function ship_work(from, to, units, cause)
   return {
      kind = "cargo.shipped",
      location = from,
      magnitude = units,
      loudness = "local",
      payload = { commodity = "work", units = units,
         sender = from, recipient = to },
      causes = { cause },
   }
end

local function maker_decide(person)
   return function(beliefs, _, tick)
      local made = discouraged(beliefs, tick) and MAKE_LOW or MAKE
      local intents, work = open_the_day(person, beliefs, made)
      if work >= LOT then
         intents[#intents + 1] = ship_work(person.name, person.boss,
            LOT, intents[1].causes[1])
      end
      return intents
   end
end

local function manager_decide(person)
   -- tobin forwards the make-team's output to sales; sef hands it
   -- to whichever seller's turn it is. Managers don't make; they
   -- move.
   return function(beliefs, _, tick)
      local intents, work = open_the_day(person, beliefs, 0)
      if work >= LOT then
         local to
         if person.name == "tobin" then
            to = "sef"
         else
            to = (tick % 2 == 0) and "ivo" or "prue"
         end
         intents[#intents + 1] = ship_work(person.name, to, LOT,
            intents[1].causes[1])
      end
      return intents
   end
end

local function seller_decide(person)
   return function(beliefs, _, tick)
      local intents, work = open_the_day(person, beliefs, 0)
      -- A heartened seller with anything to sell works the phones.
      -- A discouraged one sits on full inventory — the observable
      -- half of the rumor cascade.
      if work > 0 and not discouraged(beliefs, tick) then
         intents[#intents + 1] = {
            kind = "office.pitch",
            location = person.name,
            magnitude = work,
            loudness = "local",
            payload = { seller = person.name },
            causes = { intents[1].causes[1] },
         }
      end
      return intents
   end
end

local function founder_decide(person)
   return function(beliefs, _, tick)
      -- the rent leaves through mara's own tally, weekly, mid-week
      local rent = (tick % PAYDAY == 3) and RENT or 0
      local intents, _, cents = open_the_day(person, beliefs, 0, rent)
      local basis = intents[1].causes[1]
      if tick % PAYDAY == 0 then
         for i = 1, #CAST do
            local p = CAST[i]
            if p.salary > 0 and cents >= p.salary then
               cents = cents - p.salary
               intents[#intents + 1] = {
                  kind = "payment.shipped",
                  location = person.name,
                  magnitude = p.salary,
                  loudness = "quiet",
                  payload = { amount = p.salary,
                     payer = person.name, payee = p.name },
                  causes = { basis },
               }
            end
         end
      end
      return intents
   end
end

local function ops_decide(person)
   -- amity keeps the lights on: the rent leaves through her tally's
   -- spent column, on mara's behalf, every week. (v1 flavor; the
   -- books amity keeps versus the books mara believes is a
   -- chartered story for a later cut.)
   return function(beliefs, _, tick)
      local intents = open_the_day(person, beliefs, 0)
      return intents
   end
end

local DECIDERS = {
   founder = founder_decide,
   manager = manager_decide,
   seller = seller_decide,
   maker = maker_decide,
   ops = ops_decide,
}

-- ---------------------------------------------------------------
-- Physics: the clients and the roads. Systems, entitled to truth.
-- ---------------------------------------------------------------

local function add_physics(u)
   local ledger = {} -- name → { work, cents }, folded truth
   local roads = Roads.new(u, {
      resolve = function(name) return name end, -- a person is a place
      payment_loudness = "quiet", -- a payslip lands without fanfare
   })
   local pitches = {} -- yesterday's, gathered in scan order
   local cursor = 0

   local function catch_up()
      while cursor < u.annals:len() do
         cursor = cursor + 1
         local e = u.annals:get(cursor)
         local p = e.payload
         if e.kind == "office.hired" then
            ledger[p.name] = { work = 0, cents = p.cents }
         elseif e.kind == "office.tally" then
            local b = ledger[e.location]
            b.work = b.work + p.made
            b.cents = b.cents - p.spent
         elseif e.kind == "cargo.shipped" then
            ledger[p.sender].work = ledger[p.sender].work - p.units
            roads:schedule(e)
         elseif e.kind == "cargo.delivered" then
            ledger[p.recipient].work = ledger[p.recipient].work + p.units
         elseif e.kind == "payment.shipped" then
            ledger[p.payer].cents = ledger[p.payer].cents - p.amount
            roads:schedule(e)
         elseif e.kind == "payment.delivered" then
            ledger[p.payee].cents = ledger[p.payee].cents + p.amount
         elseif e.kind == "office.delivered" then
            ledger[p.seller].work = ledger[p.seller].work - p.units
         elseif e.kind == "office.revenue" then
            ledger["mara"].cents = ledger["mara"].cents + p.amount
         elseif e.kind == "office.pitch" then
            pitches[#pitches + 1] = { id = e.id, tick = e.tick,
               seller = p.seller }
         end
      end
   end

   -- The roads (extracted to sonder/roads.lua at card 160, when
   -- this copy — the second — plus the continent's would-be third
   -- made it the rule of three's business). The mail arrives at
   -- dawn; a payslip lands quietly.
   u:add_system("roads", roads:system(catch_up))

   -- The clients: the world outside the office, with a checkbook
   -- and no inner life (v1: environment, not minds — making them
   -- believable actors is a chartered, declined card). Yesterday's
   -- pitches get today's answers: mostly silence, sometimes a yes
   -- that turns work into revenue, occasionally a quiet no that
   -- starts a rumor.
   u:add_system("clients", function(universe, stream, tick)
      catch_up()
      local yesterdays = {}
      for i = 1, #pitches do
         if pitches[i].tick == tick - 1 then
            yesterdays[#yesterdays + 1] = pitches[i]
         end
      end
      pitches = yesterdays -- older pitches expire unanswered
      for i = 1, #yesterdays do
         local pitch = yesterdays[i]
         local held = ledger[pitch.seller].work
         if held >= DEAL_UNITS and stream:int(1, DEAL_CHANCE) == 1 then
            local deal = universe:emit{
               kind = "office.deal",
               location = pitch.seller,
               magnitude = DEAL_UNITS,
               loudness = "loud",
               payload = { seller = pitch.seller, units = DEAL_UNITS,
                  price = DEAL_PRICE, total = DEAL_UNITS * DEAL_PRICE },
               causes = { pitch.id },
            }
            catch_up()
            universe:emit{
               kind = "office.delivered",
               location = pitch.seller,
               magnitude = DEAL_UNITS,
               loudness = "local",
               payload = { seller = pitch.seller, units = DEAL_UNITS },
               causes = { deal },
            }
            catch_up()
            universe:emit{
               kind = "office.revenue",
               location = "mara",
               magnitude = DEAL_UNITS * DEAL_PRICE,
               loudness = "quiet",
               payload = { seller = pitch.seller,
                  amount = DEAL_UNITS * DEAL_PRICE },
               causes = { deal },
            }
            catch_up()
         elseif stream:int(1, LOST_CHANCE) == 1 then
            universe:emit{
               kind = "office.deal_lost",
               location = pitch.seller,
               magnitude = 0,
               loudness = "quiet",
               payload = { seller = pitch.seller },
               causes = { pitch.id },
            }
            catch_up()
         end
      end
   end)
end

-- ---------------------------------------------------------------
-- The company, assembled.
-- ---------------------------------------------------------------

return function(seed)
   local u = Universe.new(seed, {
      distance = distance,
      vocabulary = require "worlds.office_vocabulary",
   })
   for i = 1, #CAST do
      local p = CAST[i]
      u:emit{
         kind = "office.hired",
         location = p.name,
         magnitude = p.salary,
         loudness = "loud",
         payload = { name = p.name, role = p.role, salary = p.salary,
            cents = p.name == "mara" and COMPANY_CENTS or SAVINGS },
         causes = { 1 },
      }
   end
   add_physics(u)
   for i = 1, #CAST do
      local p = CAST[i]
      u:add_faction(p.name, p.name, DECIDERS[p.role](p))
   end
   return u
end
