-- tests/support/vocabulary.lua — the spec world's vocabulary: the
-- least universe that can exercise the engine, and quietly the
-- fourth world (card 160's litmus working in the test suite). Two
-- kinds: universe.genesis, because every universe begins and the
-- engine itself emits it — that's the one universal contract every
-- vocabulary must satisfy — and one world kind for specs to emit.
-- The kind keeps the name grain.hunger from the era when the engine
-- shipped the toy's vocabulary as its default and the specs
-- borrowed it; the engine never knew what grain was then, either.

return {
   schema_version = 1,
   loudnesses = { "loud", "local", "quiet" },
   kinds = {
      ["universe.genesis"] = {
         doc = "a universe begins; the first row of every annals",
         payload = { { "seed", "integer" } },
      },
      ["grain.hunger"] = {
         doc = "the spec world's one event: something happened, "
            .. "somewhere, with a size",
         payload = { { "shortfall", "integer" } },
      },
   },
}
