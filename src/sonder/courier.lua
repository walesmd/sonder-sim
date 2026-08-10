-- src/sonder/courier.lua — the courier, extracted: news becomes
-- belief, at the pace of whatever carries it.
--
-- Card 168 (a card-166 finding). The courier had lived inline in
-- the tick loop since card 122 — reasonable while it was four lines
-- of arithmetic, load-bearing debt once it grew a carriage query
-- (card 150) and encounter dice (card 151), because every future
-- change to *how news wears* — degradation's second half, card
-- 152's interpretation — would have had to cut through the
-- heartbeat. Now they get a file. The extraction moves code and
-- not behavior: same draws in the same order, same deliveries at
-- the same ticks, three golden seals bit-identical.
--
-- What the courier owns, per recipient: a cursor (its bookmark
-- into the annals), a pending calendar (news in flight), and the
-- store it delivers into. What it owns once: the losses calendar
-- (letters the roads have taken, awaiting their true day) and the
-- dice — the one *shared* stream in the engine, reserved under the
-- name "courier". Shared is deliberate and carries a warning:
-- stream derivation is order-independent (law 1's usual promise),
-- but stream *consumption* here is sequenced by recipient
-- registration order and event order, so adding or reordering
-- factions shifts every later courier draw. That is correct — the
-- dice belong to the roads, not to any actor — but cards that add
-- factions mid-history (158, 163) should expect their seals to
-- say so.

local Travel = require "sonder.travel"

local Courier = {}
Courier.__index = Courier

-- annals: the log to follow. carriage: the world's declared rows
-- (sonder/carriage.lua). dice: the courier's own named stream.
function Courier.new(annals, carriage, dice)
   assert(type(annals) == "table" and annals.get and annals.len,
      "courier: first argument must be an annals")
   assert(type(carriage) == "table" and carriage.arrival,
      "courier: second argument must be a carriage")
   assert(type(dice) == "table" and dice.int,
      "courier: third argument must be an rng stream")
   return setmetatable({
      annals = annals,
      carriage = carriage,
      dice = dice,
      recipients = {}, -- array of {name, home, store, cursor, pending}
      losses = Travel.new(), -- fates sealed, awaiting their day
   }, Courier)
end

-- A faction starts receiving news. Registration order is delivery
-- order within a tick, which makes it part of the physics.
function Courier:enroll(name, home, store)
   self.recipients[#self.recipients + 1] = {
      name = name,
      home = home,
      store = store,
      cursor = 0,
      pending = Travel.new(),
   }
end

-- Dawn: losses whose day has come become event specs (card 151),
-- returned for the universe to emit — emission is the universe's
-- door, and the courier doesn't get a key. The fate was sealed at
-- departure; the annals stamps the day the rider actually dies —
-- quiet, on the road, reason-free (the universe does not fake
-- knowledge it lacks; card 165 will generate causes as facts).
-- Located wherever the row said, a place worlds map far from every
-- home: witnessed by no one.
function Courier:dawn(tick)
   local due = self.losses:due(tick)
   local specs = {}
   for i = 1, #due do
      local l = due[i]
      specs[i] = {
         kind = l.kind,
         location = l.where,
         magnitude = 1,
         loudness = "quiet",
         payload = { from = l.from, to = l.to },
         causes = { l.cause },
      }
   end
   return specs
end

-- Deliver to the i-th recipient, at its turn in the tick (card
-- 122; calendar extracted card 153; carriage card 150; dice card
-- 151). What is due today goes first — in-flight events are older
-- than anything the bookmark hasn't seen, so ids stay ordered
-- within the tick — then the bookmark advances over everything
-- new. Which mechanism carries each event, and when it lands, is
-- the carriage's answer: earliest reaching row wins, and nil is
-- the witness rule (ADR 0005) — nothing carried it, so for this
-- faction it never happened. Rows with an encounter profile roll
-- the dice at departure, one chance per day of exposure: the fate
-- is sealed when the rider sets out, exactly as the delay always
-- was, but the loss *lands* on the day it happens (never before
-- the next dawn — a fate sealed mid-scan still needs a dawn to be
-- discovered by). Each believed copy is stamped with the tick this
-- recipient learned it: the store keeps a private chronology — the
-- order news reached it, not the order things happened. That gap
-- is the whole subject.
function Courier:deliver(i, tick)
   local r = self.recipients[i]
   local due = r.pending:due(tick)
   for j = 1, #due do
      r.store:receive(due[j], tick)
   end
   while r.cursor < self.annals:len() do
      r.cursor = r.cursor + 1
      local e = self.annals:get(r.cursor)
      local arrives, row = self.carriage:arrival(e, r.name, r.home)
      if arrives ~= nil and row.encounters ~= nil then
         local enc = row.encounters
         for day = 1, arrives - e.tick do
            if self.dice:int(1, enc.per_day) == 1 then
               self.losses:schedule(
                  math.max(e.tick + day, tick + 1),
                  { kind = enc.lost, where = enc.where,
                     from = e.location, to = r.home,
                     cause = e.id })
               arrives = nil
               break
            end
         end
      end
      if arrives == nil then
         -- unwitnessed, uncarried, or lost: never delivered
      elseif arrives <= tick then
         r.store:receive(e, tick)
      else
         r.pending:schedule(arrives, e)
      end
   end
end

return Courier
