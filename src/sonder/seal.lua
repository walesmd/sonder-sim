-- src/sonder/seal.lua — the rolling state hash.
--
-- A seal is a projection, like the chronicle and the archive before
-- it: a pure function from a prefix of the annals to eight bytes.
-- Law 2 says all state is a projection of the event log, so hashing
-- the log *is* hashing the state — two universes with the same seal
-- lived the same history, and the first divergence that matters is
-- by definition an event divergence. The core ships this card
-- unchanged; anyone holding a log (the golden test, the archive, a
-- stranger with your universe file) recomputes the seal and must get
-- the same answer on any machine.
--
-- The function is FNV-1a, 64-bit (fnv.lua), folded over each event's
-- canonical bytes (byteform.lua) — pure integer arithmetic whose wrapping
-- overflow is exactly what doctor.lua certifies. It is deliberately
-- not cryptographic: the seal defends against divergence and
-- accident, not adversaries. Tamper-*evidence*, not tamper-proofing;
-- nobody is mining collisions against their own save file.

local byteform = require "sonder.byteform"
local fnv = require "sonder.fnv"
local default_vocabulary = require "sonder.vocabulary"

local Seal = {}
Seal.__index = Seal

function Seal.new(vocabulary)
   return setmetatable({
      hash = fnv.offset,
      vocabulary = vocabulary or default_vocabulary,
   }, Seal)
end

-- Fold one event into the running hash. Events must arrive in log
-- order — the fold is order-sensitive on purpose (a history is a
-- sequence, not a set).
function Seal:fold(e)
   self.hash = fnv.string(self.hash, byteform.event(self.vocabulary, e))
   return self
end

-- The seal as sixteen hex digits — what specs pin, checkpoints
-- store, and two strangers compare.
function Seal:hex()
   return ("%016x"):format(self.hash)
end

-- The seal of an entire annals, from genesis to now. Incremental
-- folding and this must always agree; a spec holds them to it.
function Seal.of(annals)
   local seal = Seal.new(annals.vocabulary)
   for id = 1, annals:len() do
      seal:fold(annals:get(id))
   end
   return seal
end

return Seal
