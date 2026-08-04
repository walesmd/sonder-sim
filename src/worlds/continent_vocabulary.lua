-- src/worlds/continent_vocabulary.lua — what can happen on Harrow,
-- declared. The third world's grammar, and the first with a
-- multi-commodity economy: grain, iron, and salt move on the same
-- cargo kinds with the commodity named in the payload — new goods
-- are content, new behavior is API, exactly as the taxonomy ruled.
--
-- There is no exchange on Harrow. Trade is bilateral: an offer
-- rides to a neighbor, an acceptance rides back, and only then do
-- the goods and the payment take to the roads — four events, four
-- journeys, each priced by the map. The framework cargo/payment and
-- the war kinds are copy-declared from the shared grammar (the
-- composition helper's case grows with every world; it can plead at
-- the docs sweep).

return {
   -- v1: Harrow founded (card 160). Four book columns: grain, iron,
   -- salt, cents.
   schema_version = 1,

   loudnesses = { "loud", "local", "quiet" },

   kinds = {
      ["universe.genesis"] = {
         doc = "a universe begins; the engine's one demand of every "
            .. "vocabulary",
         payload = { { "seed", "integer" } },
      },
      ["continent.founded"] = {
         doc = "a civilization enters history with its endowments on "
            .. "the record — four columns' worth: the anchor every "
            .. "identity reconciles against",
         payload = { { "name", "string" }, { "grain", "integer" },
            { "iron", "integer" }, { "salt", "integer" },
            { "cents", "integer" } },
      },
      ["continent.tally"] = {
         doc = "a civilization's daily books: what the fields grew, "
            .. "the mines gave, the pans gathered, and the bellies "
            .. "took — the physical record and the doors — plus four "
            .. "claimed holdings, and claims get checked",
         payload = { { "grew", "integer" }, { "mined", "integer" },
            { "gathered", "integer" }, { "eaten", "integer" },
            { "grain", "integer" }, { "iron", "integer" },
            { "salt", "integer" }, { "cents", "integer" } },
      },
      ["continent.hunger"] = {
         doc = "the granary came up short of the day's appetite",
         payload = { { "shortfall", "integer" } },
      },
      ["continent.offer"] = {
         doc = "a bilateral proposal rides to a neighbor: so many "
            .. "units of a commodity at a price — no exchange "
            .. "anywhere on this continent, only letters between "
            .. "capitals",
         payload = { { "seller", "string" }, { "buyer", "string" },
            { "commodity", "string" }, { "units", "integer" },
            { "price", "integer" }, { "total", "integer" } },
      },
      ["continent.accept"] = {
         doc = "the buyer says yes, citing the offer; the payment "
            .. "leaves when the buyer learns of their own acceptance, "
            .. "the goods when the seller does — settlement is two "
            .. "more journeys",
         payload = { { "buyer", "string" }, { "seller", "string" },
            { "commodity", "string" }, { "units", "integer" },
            { "total", "integer" } },
      },

      -- The war grammar, copy-declared (see header).
      ["war.declared"] = {
         doc = "a culture's patience runs out — on Harrow, always "
            .. "hunger's doing",
         payload = { { "aggressor", "string" }, { "target", "string" },
            { "reason", "string" }, { "measure", "integer" } },
      },
      ["war.march"] = {
         doc = "a war party rides out from home against a target; "
            .. "the battle system delivers the raid when the road "
            .. "runs out, and there is no recall",
         payload = { { "raider", "string" }, { "target", "string" },
            { "force", "integer" } },
      },
      ["war.raid"] = {
         doc = "a war party falls on a granary: the arrival end of a "
            .. "march, emitted by the battle system",
         payload = { { "raider", "string" }, { "target", "string" },
            { "force", "integer" } },
      },
      ["war.spoils"] = {
         doc = "the battle system's verdict: sacks and cents carried "
            .. "off, sacks burned where they stood; also the seized "
            .. "goods' departure leg — they ride home with the party",
         payload = { { "raider", "string" }, { "target", "string" },
            { "seized", "integer" }, { "plunder", "integer" },
            { "burned", "integer" } },
      },
      ["war.returned"] = {
         doc = "a war party arrives home with what it carried; cites "
            .. "its war.spoils",
         payload = { { "raider", "string" }, { "target", "string" },
            { "seized", "integer" }, { "plunder", "integer" } },
      },
      ["war.peace"] = {
         doc = "the aggressor sheathes: the granaries are full "
            .. "enough, or the horde is weary enough, that blood "
            .. "stopped paying",
         payload = { { "name", "string" }, { "measure", "integer" } },
      },

      -- The framework grammar, copy-declared (see header).
      ["cargo.shipped"] = {
         doc = "matter departs one holder for another (framework "
            .. "grammar; on Harrow the commodity is grain, iron, or "
            .. "salt)",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["cargo.delivered"] = {
         doc = "matter arrives; cites its cargo.shipped (framework "
            .. "grammar)",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["payment.shipped"] = {
         doc = "money departs payer for payee (framework grammar; on "
            .. "Harrow, always the buyer's half of a bilateral deal "
            .. "or a raider's plunder riding home)",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
      },
      ["payment.delivered"] = {
         doc = "money arrives; cites its payment.shipped (framework "
            .. "grammar)",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
      },
   },
}
