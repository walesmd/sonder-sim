-- tests/support/space.lua — the shared spec fixture is the real space
-- world now (card 118). One world, one definition: main.lua runs it,
-- the golden master seals it, and specs that need a populated
-- universe borrow it from here so nothing can drift.

return require "worlds.space"
