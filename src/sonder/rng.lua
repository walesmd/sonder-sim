-- src/sonder/rng.lua — named, deterministic random streams.
--
-- Every subsystem draws from its own stream, derived from
-- (universe seed, stream name) and nothing else. Streams are
-- xoshiro256** (Blackman & Vigna — the same algorithm inside Lua 5.4's
-- math.random, reimplemented here so the state is ours: instantiable
-- per stream, serializable for checkpoints, copyable for apocrypha
-- forks). Seeding expands the 64-bit derivation through splitmix64,
-- the expander the xoshiro authors specify. All arithmetic is Lua 5.4
-- integers, which wrap on overflow exactly like the reference C's
-- uint64_t. tests/golden/reference.c is the independent oracle.

local Stream = {}
Stream.__index = Stream

local function rotl(x, k)
   return (x << k) | (x >> (64 - k))
end

-- One splitmix64 step: returns the advanced state and the output.
local function splitmix64(s)
   s = s + 0x9e3779b97f4a7c15
   local z = s
   z = (z ~ (z >> 30)) * 0xbf58476d1ce4e5b9
   z = (z ~ (z >> 27)) * 0x94d049bb133111eb
   return s, z ~ (z >> 31)
end

-- FNV-1a 64 over the seed's 8 bytes (little-endian) then the name's
-- bytes. One running hash over both inputs, rather than two hashes
-- xored together, so seed and name can't cancel each other out.
local function stream_hash(seed, name)
   local h = 0xcbf29ce484222325
   for i = 0, 56, 8 do
      h = (h ~ ((seed >> i) & 0xff)) * 0x100000001b3
   end
   for i = 1, #name do
      h = (h ~ name:byte(i)) * 0x100000001b3
   end
   return h
end

function Stream.from_state(s0, s1, s2, s3)
   -- xoshiro256** is stuck on the all-zero state (it would emit zeros
   -- forever). No real derivation reaches it (probability 2^-256), but
   -- a law deserves a guard, not a probability.
   if s0 == 0 and s1 == 0 and s2 == 0 and s3 == 0 then
      s0 = 0x9e3779b97f4a7c15
   end
   return setmetatable({ s0, s1, s2, s3 }, Stream)
end

function Stream.derive(seed, name)
   local sm = stream_hash(seed, name)
   local s0, s1, s2, s3
   sm, s0 = splitmix64(sm)
   sm, s1 = splitmix64(sm)
   sm, s2 = splitmix64(sm)
   sm, s3 = splitmix64(sm)
   return Stream.from_state(s0, s1, s2, s3)
end

-- The raw draw: a uniform 64-bit integer. Full range, so about half
-- come out negative — Lua integers are the signed view of the bits.
function Stream:next()
   local s0, s1, s2, s3 = self[1], self[2], self[3], self[4]
   local result = rotl(s1 * 5, 7) * 9
   local t = s1 << 17
   s2 = s2 ~ s0
   s3 = s3 ~ s1
   s1 = s1 ~ s2
   s0 = s0 ~ s3
   s2 = s2 ~ t
   s3 = rotl(s3, 45)
   self[1], self[2], self[3], self[4] = s0, s1, s2, s3
   return result
end

-- Uniform integer in [lo, hi], inclusive, unbiased. Masks the draw
-- down to the smallest 2^k−1 covering the span, then redraws the few
-- masked values that overshoot. Never `draw % n`: that over-weights
-- small values whenever n doesn't divide 2^64 (modulo bias).
function Stream:int(lo, hi)
   assert(math.type(lo) == "integer" and math.type(hi) == "integer",
      "rng: bounds must be integers")
   assert(lo <= hi, "rng: empty range")
   local n = hi - lo -- may wrap; correct as the unsigned span
   if n & (n + 1) == 0 then -- span+1 is a power of two: the mask alone is exact
      return lo + (self:next() & n)
   end
   local lim = n
   lim = lim | (lim >> 1)
   lim = lim | (lim >> 2)
   lim = lim | (lim >> 4)
   lim = lim | (lim >> 8)
   lim = lim | (lim >> 16)
   lim = lim | (lim >> 32)
   local r = self:next() & lim
   while math.ult(n, r) do
      r = self:next() & lim
   end
   return lo + r
end

-- The state as four plain integers — for checkpoints, forks, tests.
function Stream:state()
   return self[1], self[2], self[3], self[4]
end

local Rng = {}
Rng.__index = Rng

local function new(seed)
   assert(math.type(seed) == "integer", "rng: seed must be an integer")
   return setmetatable({ seed = seed, streams = {} }, Rng)
end

-- Create-or-get the named stream. Because it derives from (seed, name)
-- alone, the order streams are created in — and which other streams
-- exist or how much they draw — can never change what this one yields.
-- That is "a new feature never shifts another subsystem's draws", by
-- construction. `streams` is only ever indexed by name, never iterated:
-- pairs() order must not exist anywhere an outcome could see it.
function Rng:stream(name)
   assert(type(name) == "string" and #name > 0,
      "rng: stream name must be a non-empty string")
   local s = self.streams[name]
   if not s then
      s = Stream.derive(self.seed, name)
      self.streams[name] = s
   end
   return s
end

return {
   new = new,
   -- Internals, exported for the spec to check against
   -- tests/golden/reference.c. Not sim API.
   _splitmix64 = splitmix64,
   _stream_hash = stream_hash,
   _stream_from_state = Stream.from_state,
   _stream_derive = Stream.derive,
}
