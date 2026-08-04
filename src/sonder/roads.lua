-- src/sonder/roads.lua — the roads, extracted: freight reaching its
-- destination this morning becomes a delivery event.
--
-- The third world demanded it (card 160, rule of three): the space
-- world hand-rolled this system at card 153, the office copied it,
-- and the continent would have made three. The shape is framework —
-- drain the freight calendar at dawn, emit the arrival the road
-- grammar promises — while everything world-flavored stays outside:
-- the world's catch_up decides what gets scheduled, the world's map
-- prices the road, and the world names the loudness of an arrival
-- (a caravan reaching a granary is local news; a payslip landing in
-- a pocket may be quieter). Cargo-blind below the kinds, like the
-- travel calendar it wraps.

local Travel = require "sonder.travel"

local Roads = {}
Roads.__index = Roads

-- opts: resolve(name) → location (where a recipient's deliveries
-- land); cargo_loudness / payment_loudness — the world's stamps for
-- the two arrival kinds (default "local").
function Roads.new(u, opts)
   assert(type(opts) == "table" and type(opts.resolve) == "function",
      "roads: opts.resolve(name) -> location is required")
   return setmetatable({
      u = u,
      resolve = opts.resolve,
      cargo_loudness = opts.cargo_loudness or "local",
      payment_loudness = opts.payment_loudness or "local",
      freight = Travel.new(),
   }, Roads)
end

local function travel_days(self, from, to, tick)
   local d = self.u.distance(from, to, tick)
   local speed = self.u.channel_speed
   return (d + speed - 1) // speed
end

-- Put a departure on the calendar. Call from the world's catch_up
-- scan with the shipped event itself; the road prices the trip from
-- the event's own location to the recipient's.
function Roads:schedule(e)
   local p = e.payload
   if e.kind == "cargo.shipped" then
      self.freight:schedule(
         e.tick + travel_days(self, e.location, self.resolve(p.recipient), e.tick),
         { id = e.id, kind = "cargo", commodity = p.commodity,
            units = p.units, sender = p.sender,
            recipient = p.recipient })
   elseif e.kind == "payment.shipped" then
      self.freight:schedule(
         e.tick + travel_days(self, e.location, self.resolve(p.payee), e.tick),
         { id = e.id, kind = "payment", amount = p.amount,
            payer = p.payer, payee = p.payee })
   end
end

-- The system function to register (first each tick, by convention:
-- the mail arrives at dawn). catch_up is the world's own fold,
-- called around each emission so nothing acts on books that don't
-- include its own consequences.
function Roads:system(catch_up)
   return function(universe, _, tick)
      catch_up()
      local arriving = self.freight:due(tick)
      for i = 1, #arriving do
         local f = arriving[i]
         if f.kind == "cargo" then
            universe:emit{
               kind = "cargo.delivered",
               location = self.resolve(f.recipient),
               magnitude = f.units,
               loudness = self.cargo_loudness,
               payload = { commodity = f.commodity, units = f.units,
                  sender = f.sender, recipient = f.recipient },
               causes = { f.id },
            }
         else
            universe:emit{
               kind = "payment.delivered",
               location = self.resolve(f.payee),
               magnitude = f.amount,
               loudness = self.payment_loudness,
               payload = { amount = f.amount, payer = f.payer,
                  payee = f.payee },
               causes = { f.id },
            }
         end
         catch_up()
      end
   end
end

return Roads
