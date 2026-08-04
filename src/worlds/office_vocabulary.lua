-- src/worlds/office_vocabulary.lua — what can happen at Bellwether
-- & Co., declared. The first vocabulary written against the world
-- interface (ADR 0004) instead of grandfathered through it: the
-- engine demands universe.genesis and nothing else; everything else
-- is this universe's own grammar.
--
-- Two families are copy-declared from the framework grammar —
-- cargo.* and payment.* — because internal movement rides the
-- engine's road kinds in every world, and vocabularies are
-- self-contained tables. (A composition helper that lets worlds
-- import the framework kinds instead of restating them is a noted
-- refinement; it earns its keep at the third world, per the rule
-- of three.) The doors are the office's own: work is made and
-- delivered, money enters as revenue and leaves as spending — an
-- OPEN system, the first one, with its identities declared to
-- match.

return {
   -- v1: Bellwether & Co. founded (card 160). The office's books
   -- run on two columns: cents, and units of work.
   schema_version = 1,

   loudnesses = { "loud", "local", "quiet" },

   kinds = {
      ["universe.genesis"] = {
         doc = "a universe begins; the engine's one demand of every "
            .. "vocabulary",
         payload = { { "seed", "integer" } },
      },
      ["office.hired"] = {
         doc = "a person joins the company with their role, salary, "
            .. "and starting savings on the record — the books "
            .. "anchor, like a founding (v1: everyone is hired at "
            .. "genesis; joining mid-history is the card this world "
            .. "sent back before it was built)",
         payload = { { "name", "string" }, { "role", "string" },
            { "salary", "integer" }, { "cents", "integer" } },
      },
      ["office.tally"] = {
         doc = "a person's daily books: what they made, what they "
            .. "spent, and what they claim to hold in work and "
            .. "cents. Made and spent are the day's physical record "
            .. "and the work and cents columns' quiet doors (made "
            .. "grows work the way harvests grow grain; spent is "
            .. "each person's daily living and the company's rent, "
            .. "leaving the system the way the eaten column always "
            .. "did) — work and cents are claims, and claims get "
            .. "checked",
         payload = { { "made", "integer" }, { "spent", "integer" },
            { "work", "integer" }, { "cents", "integer" } },
      },
      ["office.pitch"] = {
         doc = "a seller works their client list for the day — the "
            .. "observable half of morale, and the behavior the "
            .. "rumor cascade switches off",
         payload = { { "seller", "string" } },
      },
      ["office.deal"] = {
         doc = "a client says yes: so many units at a price — the "
            .. "agreement; the work leaves and the money arrives as "
            .. "its own recorded doors",
         payload = { { "seller", "string" }, { "units", "integer" },
            { "price", "integer" }, { "total", "integer" } },
      },
      ["office.deal_lost"] = {
         doc = "a client says no, quietly — the seed of every rumor "
            .. "cascade this world is chartered to produce",
         payload = { { "seller", "string" } },
      },
      ["office.delivered"] = {
         doc = "finished work leaves the company for a client: the "
            .. "work column's outbound door (lawful because this "
            .. "event records it)",
         payload = { { "seller", "string" }, { "units", "integer" } },
      },
      ["office.revenue"] = {
         doc = "a client's money arrives in the company treasury: "
            .. "the cents column's inbound door — the office is an "
            .. "open system, and this is one of its two mouths",
         payload = { { "seller", "string" }, { "amount", "integer" } },
      },
      -- The framework grammar, restated (see header): internal
      -- movement of work and salaries rides the roads.
      ["cargo.shipped"] = {
         doc = "matter departs one holder for another (framework "
            .. "grammar; here the commodity is work)",
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
         doc = "money departs payer for payee (framework grammar; "
            .. "here: salaries, riding the org chart)",
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
