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
         doc = "the agreement: sacks promised for cents at the "
            .. "exchange. Since card 153 this moves no books — the "
            .. "goods and the payment ride the roads as cargo and "
            .. "payment events, and the ledgers move on delivery",
         payload = { { "buyer", "string" }, { "seller", "string" },
            { "units", "integer" }, { "price", "integer" },
            { "total", "integer" } },
      },
      ["cargo.shipped"] = {
         doc = "matter departs one holder for another: commodity "
            .. "and units leave the sender's stores and take to the "
            .. "road (card 153). The arrival is physics' verdict, "
            .. "never this event's promise — a lot can happen in "
            .. "seven days",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["cargo.delivered"] = {
         doc = "matter arrives: the recipient's stores grow by what "
            .. "actually made it. Cites its cargo.shipped — the "
            .. "pairing the road ledger balances on",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["payment.shipped"] = {
         doc = "money departs payer for payee and takes to the road "
            .. "(card 153). How long it rides is the mechanism's "
            .. "business — a hull takes days, a wire takes seconds; "
            .. "the story reads the same either way",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
      },
      ["payment.delivered"] = {
         doc = "money arrives in the payee's treasury. Cites its "
            .. "payment.shipped",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
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
      ["war.march"] = {
         doc = "a war party rides out from home against a target — "
            .. "departure and arrival are different events, with "
            .. "space and time between them; the battle system "
            .. "delivers the raid when the road runs out, and there "
            .. "is no recall (card 158 will teach parties to hear)",
         payload = { { "raider", "string" }, { "target", "string" },
            { "force", "integer" } },
      },
      ["war.raid"] = {
         doc = "a war party falls on a granary: the arrival end of a "
            .. "march, emitted by the battle system when the party "
            .. "reaches the grain; what it seizes is the battle "
            .. "system's verdict, not the raider's plan",
         payload = { { "raider", "string" }, { "target", "string" },
            { "force", "integer" } },
      },
      ["war.spoils"] = {
         doc = "the battle system's verdict on a raid: the sacks and "
            .. "cents carried off, and the sacks burned where they "
            .. "stood. Burning is the one lawful way matter leaves "
            .. "the world (law 1 permits it because this event "
            .. "records it). Since card 153 this is also a departure "
            .. "leg: the seized goods leave the target here and ride "
            .. "home with the party, arriving at war.returned",
         payload = { { "raider", "string" }, { "target", "string" },
            { "seized", "integer" }, { "plunder", "integer" },
            { "burned", "integer" } },
      },
      ["war.returned"] = {
         doc = "a war party arrives home with what it carried: the "
            .. "seized sacks and plunder enter the raider's books "
            .. "only now (card 153). Cites its war.spoils — an agent "
            .. "coming home isn't freight, even when carrying some",
         payload = { { "raider", "string" }, { "target", "string" },
            { "seized", "integer" }, { "plunder", "integer" } },
      },
      ["war.peace"] = {
         doc = "the aggressor sheathes: grain is cheap enough, or the "
            .. "granaries are full enough, that blood stopped paying",
         payload = { { "name", "string" }, { "price", "integer" } },
      },
   },
}
