-- src/sonder/belief.lua — what a faction knows, which is not the truth.
--
-- Law 3: agents act on beliefs, never truth — structurally, not
-- politely. The structure is capability-shaped, and it has two sides.
-- Decision code is handed this store and nothing else, so there is no
-- expression that reaches world state from inside a decision — not
-- "please don't," but "there is no door." And the store itself can't
-- reach truth either: it holds no annals, no cursor, no universe — it
-- is push-based, knowing only what a courier chose to `receive` into
-- it. Card 122 kept the seam's promise: the courier learned distance
-- and delay, and this store, its queries, and every decision
-- function's signature stayed exactly as they were — the one thing
-- the store gained is the `learned` stamp on each believed copy, the
-- tick the news actually reached its owner. Degradation in transit
-- and cultural interpretation (cards 151, 152) will arrive through
-- the same door.
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
      journal = {}, -- every believed event, across kinds, received order
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
      loudness = e.loudness,
      payload = payload,
      causes = table.move(e.causes, 1, #e.causes, 1, {}),
      -- Not an envelope field: the tick this owner learned of the
      -- event, stamped by the courier on the way in. The event is a
      -- photograph; this is the date written on the back of it. nil
      -- on the way in (the incoming event never carries one), set by
      -- receive(); carried faithfully on the way out.
      learned = e.learned,
   }
end

-- The courier's door: an event arrives and becomes belief. The store
-- doesn't validate against a vocabulary — it wasn't there, it can't
-- check, and a belief in a kind you've never heard of is still a
-- belief (a viewer-grade tolerance, for the same reason viewers have
-- it: this store will one day receive events from couriers younger
-- than it is).
function Belief:receive(e, learned)
   assert(type(e) == "table" and type(e.kind) == "string",
      "belief: received something that is not an event")
   assert(math.type(learned) == "integer" and learned >= e.tick,
      "belief: learned must be an integer tick no earlier than the event")
   local held = copy(e)
   held.learned = learned
   local kind = self.by_kind[e.kind]
   if not kind then
      kind = {}
      self.by_kind[e.kind] = kind
   end
   kind[#kind + 1] = held
   self.journal[#self.journal + 1] = held
   self.received = self.received + 1
end

-- The private chronology: everything ever believed, across every
-- kind, in arrival order — the diary the courier wrote into this
-- store. as_of (optional) cuts it at a tick: what this mind knew
-- *when* — beliefs are a pure projection of deliveries, so every
-- past state of the store is still inside it, one filter away
-- (card 122, Q7: observe any actor at any tick). Copies, as always.
function Belief:chronology(as_of)
   assert(as_of == nil or math.type(as_of) == "integer",
      "belief: as_of must be an integer tick")
   local out = {}
   for i = 1, #self.journal do
      local held = self.journal[i]
      if as_of == nil or held.learned <= as_of then
         out[#out + 1] = copy(held)
      end
   end
   return out
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
-- Arrival order is the store's own history — and with the card-122
-- courier that is the faction's private chronology: the order news
-- reached it, not the order things happened. That gap is the point.
function Belief:recall(kind)
   local held = self.by_kind[kind]
   local out = {}
   for i = 1, #(held or out) do
      out[i] = copy(held[i])
   end
   return out
end

-- The last n beliefs about a kind, arrival order, oldest first —
-- possibly fewer, possibly none. Minds mostly run on recent memory
-- (a patience fuse, the last few prices), and recalling all of
-- history to look at the end of it would price statelessness out of
-- reach.
function Belief:recent(kind, n)
   local held = self.by_kind[kind]
   local out = {}
   if not held then
      return out
   end
   local first = math.max(1, #held - n + 1)
   for i = first, #held do
      out[#out + 1] = copy(held[i])
   end
   return out
end

function Belief:len()
   return self.received
end

return Belief
