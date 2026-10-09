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
local Carriage = require "sonder.carriage"
local Books = require "sonder.books"
local VOCABULARY = require "worlds.office_vocabulary"

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

-- The fold once read count windows, and here they were sized to
-- the crowd, not the couple: ten people's events arrive at every
-- desk, and paydays emit nine payments in one burst. A window of 8
-- — generous for two civilizations — silently evicted sef's salary
-- from mara's fold every single week (113 phantom mismatches in 120
-- days, every one exactly 150¢). That lesson is why the fold now
-- reads back exactly to the anchor instead (card 169, fork 0).

-- The fold is the engine's since card 169 (sonder/books.lua); what
-- stays here is the office's own grammar — two columns, a tally
-- that speaks from a desk, and the two kinds only this world has.

-- The books' shape, stated once: both folds consume it (the belief
-- fold here, the truth-side ledger in add_physics). The audit's
-- legs declare their own copy — different shape, different consumer
-- (card 169's conscious duplication; see the notebook).
local COLUMNS = { "work", "cents" }
local COMMODITIES = { work = "work" }
local MONEY = "cents"

local BELIEVED = Books.check({
   columns = COLUMNS,
   commodities = COMMODITIES,
   money = MONEY,
   anchors = {
      { kind = "office.tally", by = "home" },
      -- a hiring records your salary terms, not your output — no
      -- work field to read, so work opens at zero (and if hiring
      -- ever grows one, Books.check refuses until this default goes)
      { kind = "office.hired", by = "name",
         defaults = { work = 0 } },
   },
   legs = {
      { kind = "office.delivered", apply = function(b, e, owner)
         if e.payload.seller == owner.name then
            b.work = b.work - e.payload.units
         end
      end },
      -- revenue lands on the founder's books alone: the company's
      -- one inbound door (money leaves through every tally's spent
      -- column), and mara is standing in it
      { kind = "office.revenue", apply = function(b, e, owner)
         if owner.name == "mara" then
            b.cents = b.cents + e.payload.amount
         end
      end },
   },
}, VOCABULARY)

local function believed_books(beliefs, name)
   local b, since = Books.believed(beliefs, BELIEVED,
      { name = name, home = name }) -- a person is a place
   return b.work, b.cents, since
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
   -- amity opens the day and, in v1, does little else — the rent
   -- actually leaves through mara's own weekly tally (extra_spend,
   -- above), not amity's. This comment used to claim otherwise
   -- (card 172): in a repo where comments are published prose,
   -- attributing mara's books to amity was a small lie with a long
   -- shelf life. The books amity keeps versus the books mara
   -- believes stays a chartered story for a later cut.
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
   local roads = Roads.new(u, {
      resolve = function(name) return name end, -- a person is a place
      payment_loudness = "quiet", -- a payslip lands without fanfare
   })
   local pitches = {} -- yesterday's, gathered in scan order

   -- Folded truth: the cursor and the framework road legs are the
   -- engine's since card 169 (sonder/books.lua); the office
   -- declares what its own kinds do to the books.
   local truth = Books.ledger(u, {
      columns = COLUMNS,
      commodities = COMMODITIES,
      money = MONEY,
      roads = roads,
      effects = {
         ["office.hired"] = function(led, e)
            -- a hiring says cents; work opens at zero (enroll's rule)
            led:enroll(e.payload.name, { cents = e.payload.cents })
         end,
         ["office.tally"] = function(led, e)
            local p = e.payload
            local b = led.books[e.location]
            b.work = b.work + p.made
            b.cents = b.cents - p.spent
         end,
         ["office.delivered"] = function(led, e)
            local p = e.payload
            led.books[p.seller].work = led.books[p.seller].work - p.units
         end,
         ["office.revenue"] = function(led, e)
            led.books["mara"].cents = led.books["mara"].cents
               + e.payload.amount
         end,
         ["office.pitch"] = function(_, e)
            pitches[#pitches + 1] = { id = e.id, tick = e.tick,
               seller = e.payload.seller }
         end,
      },
   })
   local ledger = truth.books -- name → { work, cents }, folded truth
   local function catch_up()
      truth:catch_up()
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
      -- Rung 1 of ADR 0005's ladder (card 150): the office still
      -- runs on the field — everything eventually reaches everyone
      -- at org-chart pace — declared now as a row instead of
      -- assumed. Rung 2 waits for this world's own migration card:
      -- an office's earshot (the room, the thread, the cc line) is
      -- a design conversation, not a default.
      mechanisms = { Carriage.field(1) },
      vocabulary = VOCABULARY,
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
