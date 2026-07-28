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
   -- shape; merely adding a kind doesn't bump it. The archive writes
   -- this into every universe's provenance table (card 115).
   -- v2: the toy world (card 118) — the placeholder drift and muster
   -- churned away, the Vessari and the Khedrun arrived. Universe
   -- files written under v1 replay only under v1 code; crossing that
   -- line is lineage, card 124's problem.
   -- v3: loudness (card 122) — the envelope field "visibility"
   -- renamed, its values public/regional/secret now loud/local/quiet.
   -- The old name claimed to say who may come to know, which is
   -- never event state: it's the behavior of whoever holds the
   -- information.
   schema_version = 3,

   -- How loudly the act was performed — the signal an event emitted
   -- at its origin, chosen by the emitter as part of acting and a
   -- fact of the occurrence ever after. It is an *input*, never the
   -- answer to who observes: observability is computed by the
   -- environment (mechanisms, distance — cards 150–152) or emerges
   -- through consequences, and ongoing secrecy is holders declining
   -- to retell. Nothing consumes the stamp yet; emitters stamp it
   -- honestly anyway, because it can't be added to history later.
   loudnesses = { "loud", "local", "quiet" },

   -- Payload fields are declared as an ordered array of {name, type}
   -- pairs — an array, so nothing that walks a payload ever needs
   -- pairs(). Types are "integer" or "string" only: flat, float-free,
   -- and one bind away from a SQLite column (the archive holds them
   -- to it, card 115). Money is integer cents; grain is integer
   -- sacks; law 1 tolerates no floats near an outcome.
   kinds = {
      ["universe.genesis"] = {
         doc = "a universe begins; the first row of every annals and "
            .. "the event all cause chains terminate in",
         payload = { { "seed", "integer" } },
      },
      ["civ.founded"] = {
         doc = "a civilization enters history with its endowments on "
            .. "the record — the anchor the double-entry audit (card "
            .. "120) will reconcile against",
         payload = { { "name", "string" }, { "grain", "integer" },
            { "cents", "integer" } },
      },
      ["civ.tally"] = {
         doc = "a civilization's daily books: what the fields gave, "
            .. "what was eaten, what the granary and treasury hold",
         payload = { { "harvested", "integer" }, { "eaten", "integer" },
            { "stock", "integer" }, { "cents", "integer" } },
      },
      ["grain.hunger"] = {
         doc = "the granary came up short of the day's appetite",
         payload = { { "shortfall", "integer" } },
      },
      ["market.order"] = {
         doc = "a standing offer at the exchange: buy or sell so many "
            .. "sacks, at up to (or down to) a limit in cents",
         payload = { { "side", "string" }, { "units", "integer" },
            { "limit", "integer" } },
      },
      ["market.trade"] = {
         doc = "sacks change hands for cents; the only way money or "
            .. "grain legitimately moves between civilizations",
         payload = { { "buyer", "string" }, { "seller", "string" },
            { "units", "integer" }, { "price", "integer" },
            { "total", "integer" } },
      },
      ["market.price"] = {
         doc = "the exchange reposts grain: naive price adjustment "
            .. "driven by yesterday's unfilled imbalance",
         payload = { { "price", "integer" }, { "delta", "integer" } },
      },
      ["war.declared"] = {
         doc = "a culture's patience, priced past its temperament — "
            .. "by grain too dear (reason: price, measure: cents) or "
            .. "bellies too empty (reason: hunger, measure: days)",
         payload = { { "aggressor", "string" }, { "target", "string" },
            { "reason", "string" }, { "measure", "integer" } },
      },
      ["war.raid"] = {
         doc = "a war party rides against a granary with so much "
            .. "force; what it will actually seize is the battle "
            .. "system's verdict, not the raider's plan",
         payload = { { "raider", "string" }, { "target", "string" },
            { "force", "integer" } },
      },
      ["war.spoils"] = {
         doc = "the battle system's verdict on a raid: the sacks and "
            .. "cents carried off, and the sacks burned where they "
            .. "stood — raiding is how money flows back the other "
            .. "way, and burning is the one lawful way matter leaves "
            .. "the world (law 1 permits it because this event "
            .. "records it)",
         payload = { { "raider", "string" }, { "target", "string" },
            { "seized", "integer" }, { "plunder", "integer" },
            { "burned", "integer" } },
      },
      ["war.peace"] = {
         doc = "the aggressor sheathes: grain is cheap enough, or the "
            .. "granaries are full enough, that blood stopped paying",
         payload = { { "name", "string" }, { "price", "integer" } },
      },
   },
}
