-- src/sonder/vocabulary.lua — what can happen, declared.
--
-- The event vocabulary is a public API: the versioned list of every
-- kind of thing that can occur in a universe, and the exact shape of
-- what each kind carries. The annals validates against it, strictly —
-- a malformed event written today is corrupted history forever.
-- Nothing here says how an event should be *displayed*; that belongs
-- to viewers (see chronicle.lua). Kinds are append-mostly: pre-0.1 we
-- churn freely, after that additions are cheap and removals owe a
-- documented migration.

return {
   -- Bumped when the envelope or an existing kind's payload changes
   -- shape; merely adding a kind doesn't bump it. Card 115 writes
   -- this into every universe's provenance table.
   schema_version = 1,

   -- Who could, in principle, come to know of an event. Nothing
   -- consumes this until the belief store (card 117); emitters stamp
   -- it honestly anyway, because it can't be added to history later.
   visibilities = { "public", "regional", "secret" },

   -- Payload fields are declared as an ordered array of {name, type}
   -- pairs — an array, so nothing that walks a payload ever needs
   -- pairs(). Types are "integer" or "string" only: flat, float-free,
   -- and one bind away from a SQLite column when card 115 arrives.
   kinds = {
      ["universe.genesis"] = {
         doc = "a universe begins; the first row of every annals and "
            .. "the event all cause chains terminate in",
         payload = { { "seed", "integer" } },
      },
      ["market.drift"] = {
         doc = "placeholder: the market moves for no modeled reason "
            .. "yet (card 118 replaces this)",
         payload = { { "drift", "integer" } },
      },
      ["war.muster"] = {
         doc = "placeholder: the war office raises levies for no "
            .. "modeled war yet (card 118 replaces this)",
         payload = { { "muster", "integer" } },
      },
   },
}
