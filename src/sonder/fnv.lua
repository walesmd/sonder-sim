-- src/sonder/fnv.lua — FNV-1a, 64-bit, in exactly one place.
--
-- The project's workhorse hash: the RNG derives named streams with
-- it, the seal rolls state with it, main.lua fingerprints the feed
-- with it. Three consumers, one pair of magic numbers — the third
-- copy is where duplication stops being coincidence, so they all
-- fold through here now. Pure Lua 5.4 integer arithmetic; the
-- wrapping multiply is exactly what doctor.lua certifies.
--
-- tests/golden/reference.c stays a deliberately independent
-- implementation — it is the oracle this one is checked against,
-- and an oracle that shares code with its subject vouches for
-- nothing.

local fnv = {}

-- Where every fold starts (the FNV-1a offset basis).
fnv.offset = 0xcbf29ce484222325

local PRIME = 0x100000001b3

-- Fold one byte into a running hash; returns the new hash.
function fnv.byte(h, b)
   return (h ~ b) * PRIME
end

-- Fold every byte of a string.
function fnv.string(h, s)
   for i = 1, #s do
      h = (h ~ s:byte(i)) * PRIME
   end
   return h
end

return fnv
