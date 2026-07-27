-- src/sonder/belief.lua — what a faction knows, which is not the truth.
--
-- Law 3: agents act on beliefs, never truth — structurally, not
-- politely. The structure is capability-shaped, and it has two sides.
-- Decision code is handed this store and nothing else, so there is no
-- expression that reaches world state from inside a decision — not
-- "please don't," but "there is no door." And the store itself can't
-- reach truth either: it holds no annals, no cursor, no universe — it
-- is push-based, knowing only what a courier chose to `receive` into
-- it. Today's courier (universe.lua) is a pass-through and every
-- faction is briefly omniscient; when news learns to travel at ship
-- speed, degrade in transit, and be culturally interpreted (card 122),
-- the courier changes and this store, its queries, and every decision
-- function's signature stay exactly as they are. That is the seam,
-- and it ships early because it cannot be retrofitted onto decision
-- code written against world state.
--
-- Ignorance is free, by structure: kinds index lazily, so a faction
-- that has received no events about something simply has no rows
-- about it — no placeholder, no "unknown", nothing to allocate.

local Belief = {}
Belief.__index = Belief

function Belief.new(owner)
   assert(type(owner) == "string" and #owner > 0,
      "belief: owner must be a non-empty string")
   return setmetatable({
      owner = owner,
      received = 0, -- how many events have ever arrived
      by_kind = {}, -- kind → array of believed events, received order
   }, Belief)
end

-- A belief is a copy of an event, twice over: copied on the way in
-- (the courier's table is not ours to keep) and on the way out (a
-- faction scribbling on a query result must not corrupt its own
-- memory). Photographs, not negatives — same discipline as the
-- annals, for the same reason.
local function copy(e)
   -- pairs() is legal here, narrowly: the store has no vocabulary to
   -- walk declarations with (it must hold beliefs about kinds it has
   -- never heard of), and copying key-by-key into a fresh table
   -- produces the same table whatever order the keys come out in. No
   -- outcome can see the difference — anything that *walks* a payload
   -- downstream still uses declaration order.
   local payload = {}
   for k, v in pairs(e.payload) do
      payload[k] = v
   end
   return {
      id = e.id,
      tick = e.tick,
      kind = e.kind,
      location = e.location,
      magnitude = e.magnitude,
      visibility = e.visibility,
      payload = payload,
      causes = table.move(e.causes, 1, #e.causes, 1, {}),
   }
end

-- The courier's door: an event arrives and becomes belief. The store
-- doesn't validate against a vocabulary — it wasn't there, it can't
-- check, and a belief in a kind you've never heard of is still a
-- belief (a viewer-grade tolerance, for the same reason viewers have
-- it: this store will one day receive events from couriers younger
-- than it is).
function Belief:receive(e)
   assert(type(e) == "table" and type(e.kind) == "string",
      "belief: received something that is not an event")
   local held = copy(e)
   local kind = self.by_kind[e.kind]
   if not kind then
      kind = {}
      self.by_kind[e.kind] = kind
   end
   kind[#kind + 1] = held
   self.received = self.received + 1
end

-- The newest belief about a kind, or nil — and nil is a complete
-- answer: it means nothing about this has ever reached you.
function Belief:latest(kind)
   local held = self.by_kind[kind]
   if not held then
      return nil
   end
   return copy(held[#held])
end

-- Everything believed about a kind, in the order it arrived.
-- Arrival order is the store's own history — with a pass-through
-- courier it matches log order, but the day couriers get slow it
-- becomes the faction's private chronology, which is the point.
function Belief:recall(kind)
   local held = self.by_kind[kind]
   local out = {}
   for i = 1, #(held or out) do
      out[i] = copy(held[i])
   end
   return out
end

function Belief:len()
   return self.received
end

return Belief
