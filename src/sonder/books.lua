-- src/sonder/books.lua — the believed-books fold and the truth-side
-- ledger cursor: one home for what the road grammar does to a set
-- of books (card 169; a card-166 finding, rule of three cashed
-- twice over).
--
-- Two sides of one piece of knowledge. The belief side answers
-- "what do I hold this morning?" for a mind that may only read its
-- belief store (law 3): anchor on the last self-report — the daily
-- tally, or the founding before any — then absorb every book-moving
-- event learned since. The truth side answers the same question for
-- physics, entitled to the annals: an incremental cursor, a cache
-- of the log and never a second authority (law 2 — a balance is not
-- state anywhere; it is recomputed from events).
--
-- The engine owns the fold's discipline and the framework road
-- grammar — the four cargo/payment kinds vocabulary.lua declares
-- (roads.lua emits the arrivals; worlds emit the departures the
-- roads price) and the audit's framework legs book. Which column a
-- commodity moves is the world's commodities map's answer — the
-- audit's rule, applied here through a map the world declares
-- again (a copy, not a share; the audit's legs keep their own —
-- notebook 169 records the duplication as a conscious choice). A
-- world declares
-- its columns and supplies meaning for its own kinds; which column
-- a commodity moves, whose books a war leg touches, what a tally
-- says — all world knowledge, all declared or closed over, never
-- guessed at here.
--
-- Anchors carry two escape hatches, both plain data (card 169's
-- option A). A `fields` map covers a column whose payload spelling
-- differs from its name: space's daily tally says `stock` where its
-- founding says `grain` — same sacks, two spellings, and one
-- declared line here spared a breaking vocabulary rename (that
-- rename, if ever wanted, rides card 163's scheduled seal re-cut).
-- A `defaults` table covers a column an anchor doesn't carry at
-- all: a hiring records your salary terms, not your output — the
-- office's work opens at zero.
--
-- Watermarks are judged by the courier's `learned` stamp, never by
-- event id: news that crossed distance carries an old id, and an id
-- watermark would drop it forever the moment it finally arrived
-- (card 122's adversarial review caught exactly that). The tally
-- written on day T absorbed everything learned by day T, by
-- induction: each believed leg integrates into exactly the first
-- tally decided after it lands.
--
-- And the fold reads back exactly to that stamp, never a count of
-- recent events. The first draft used recent() windows sized to the
-- crowd, and the count was a guess that had already failed twice
-- (the office's 113 phantom mismatches, the continent's double
-- shipment); overflow a window and the books silently under-count,
-- or re-anchor on a founding and cite the wrong cause. Belief:since
-- and Belief:newest_where read exactly as far back as the anchor
-- is (card 169, fork 0).
--
-- A declaration is checked once, at the world file's scope, against
-- the world's vocabulary (Books.check — card 171's rule, one
-- contract checked once). Everything the fold would otherwise
-- discover mid-tick — a column no anchor carries, a road kind a
-- world tries to re-book — is refused before the first tick.

local Books = {}

-- Declarations that passed Books.check. Keyed weakly so a checked
-- table never outlives its world; believed() asks here instead of
-- re-validating on the hot path (every mind, every morning).
local checked = setmetatable({}, { __mode = "k" })

-- Does this event anchor this owner's books? Two shapes cover every
-- anchor in three worlds: a tally speaks from the owner's home, a
-- founding names its subject. (In the office a person is a place,
-- so both shapes collapse onto the name — that is the world's
-- geometry, not a third shape.)
local function matches(anchor, e, owner)
   if anchor.by == "home" then
      return e.location == owner.home
   end
   return e.payload.name == owner.name
end

-- Open the books from an anchor event: one value per declared
-- column, read through the anchor's field map (identity unless
-- declared) or its defaults (for columns the anchor doesn't carry —
-- Books.check proved each column has exactly one source).
local function open(anchor, e, columns)
   local b = {}
   for i = 1, #columns do
      local col = columns[i]
      local field = anchor.fields and anchor.fields[col] or col
      local v = e.payload[field]
      if v == nil then
         v = anchor.defaults[col]
      end
      b[col] = v
   end
   return b
end

-- Which column does a shipment move? The world's commodities map
-- answers, exactly as it answers the audit. A commodity the map
-- cannot book is a bug in the world that emitted it, so this raises
-- rather than guessing.
local function column_of(decl, commodity)
   return assert(decl.commodities[commodity],
      ("books: cargo in a commodity the books cannot place (%s)")
         :format(tostring(commodity)))
end

-- The road grammar's four kinds, as books see them: the engine
-- books these, so a world may not (the framework table below is
-- the one list).
local framework

-- Hold a belief-side declaration to its contract, against the
-- world's vocabulary. Raises with one voice on the first violation;
-- returns decl untouched otherwise. decl: `columns` (ordered keys),
-- `commodities` (commodity → column), `money` (a column), `anchors`
-- (ordered; first match wins; each { kind, by, fields?, defaults? }),
-- and `legs` — the world's own book-moving kinds as an ordered array
-- of { kind, apply }.
function Books.check(decl, vocabulary)
   assert(type(decl) == "table", "books: a declaration must be a table")
   assert(type(vocabulary) == "table" and type(vocabulary.kinds) == "table",
      "books: check a declaration against the world's vocabulary")
   local kinds = vocabulary.kinds

   assert(type(decl.columns) == "table" and #decl.columns > 0,
      "books: declare a non-empty ordered column list")
   local is_column = {}
   for i = 1, #decl.columns do
      local col = decl.columns[i]
      assert(type(col) == "string" and #col > 0,
         "books: column names must be non-empty strings")
      assert(not is_column[col],
         ("books: column %s declared twice"):format(col))
      is_column[col] = true
   end
   assert(is_column[decl.money],
      ("books: money (%s) must be a declared column")
         :format(tostring(decl.money)))
   assert(type(decl.commodities) == "table",
      "books: declare a commodities map")
   for commodity, col in pairs(decl.commodities) do
      -- pairs() is legal here, narrowly: validation only accepts or
      -- raises — no outcome depends on visit order.
      assert(is_column[col],
         ("books: commodity %s books into %s, which is not a column")
            :format(tostring(commodity), tostring(col)))
   end

   local function declared(kind, role)
      local entry = kinds[kind]
      assert(entry,
         ("books: %s kind %s is not in the world's vocabulary")
            :format(role, tostring(kind)))
      local fields = {}
      for i = 1, #entry.payload do
         fields[entry.payload[i][1]] = true
      end
      return fields
   end

   assert(type(decl.anchors) == "table" and #decl.anchors > 0,
      "books: declare at least one anchor")
   for i = 1, #decl.anchors do
      local a = decl.anchors[i]
      local payload = declared(a.kind, "anchor")
      local where = ("books: anchor %s"):format(a.kind)
      assert(a.by == "home" or a.by == "name",
         ("%s matches by %s — home and name are the only shapes")
            :format(where, tostring(a.by)))
      assert(a.by ~= "name" or payload.name,
         where .. " matches by name but its payload has no name field")
      for col in pairs(a.fields or {}) do
         assert(is_column[col],
            ("%s maps %s, which is not a column"):format(where, col))
      end
      for col in pairs(a.defaults or {}) do
         assert(is_column[col],
            ("%s defaults %s, which is not a column"):format(where, col))
      end
      -- Every column opens from the payload or from a default — never
      -- both. A default is a promise the anchor doesn't carry the
      -- column; if the vocabulary later grows the field, the opening
      -- books would silently change, so the check refuses instead.
      for j = 1, #decl.columns do
         local col = decl.columns[j]
         local field = a.fields and a.fields[col] or col
         local default = a.defaults and a.defaults[col]
         if payload[field] then
            assert(default == nil,
               ("%s defaults %s, but its payload now carries %s — "
                  .. "drop the default or the field"):format(where, col,
                  field))
         else
            assert(math.type(default) == "integer",
               ("%s carries no %s (payload field %s) and declares no "
                  .. "integer default"):format(where, col, field))
         end
      end
   end

   for i = 1, #(decl.legs or {}) do
      local leg = decl.legs[i]
      declared(leg.kind, "leg")
      assert(not framework[leg.kind],
         ("books: %s is road grammar — the engine books it; a world "
            .. "leg would count it twice"):format(leg.kind))
      assert(type(leg.apply) == "function",
         ("books: leg %s needs an apply function"):format(leg.kind))
   end

   checked[decl] = true
   return decl
end

-- The belief-side fold, over a declaration Books.check has passed.
-- owner is { name, home }. Returns the books table and the anchor's
-- event id (the day's bookkeeping cause).
function Books.believed(beliefs, decl, owner)
   assert(checked[decl],
      "books: run Books.check on a declaration before folding it")
   local basis, anchor
   for i = 1, #decl.anchors do
      local a = decl.anchors[i]
      basis = beliefs:newest_where(a.kind,
         function(e) return matches(a, e, owner) end)
      if basis then
         anchor = a
         break
      end
   end
   if not basis then
      -- the voice stays world-blind: name the kinds the world
      -- declared, never guess at what they mean
      local kinds = {}
      for i = 1, #decl.anchors do
         kinds[i] = decl.anchors[i].kind
      end
      error(("books: no anchor has reached %s — nothing believed "
         .. "under %s")
         :format(owner.name, table.concat(kinds, ", ")))
   end
   local b = open(anchor, basis, decl.columns)
   local since, absorbed = basis.id, basis.tick

   -- The framework road grammar: matter and money between places,
   -- the same four legs the audit books on the truth side.
   for _, e in ipairs(beliefs:since("cargo.shipped", absorbed)) do
      if e.payload.sender == owner.name then
         local col = column_of(decl, e.payload.commodity)
         b[col] = b[col] - e.payload.units
      end
   end
   for _, e in ipairs(beliefs:since("cargo.delivered", absorbed)) do
      if e.payload.recipient == owner.name then
         local col = column_of(decl, e.payload.commodity)
         b[col] = b[col] + e.payload.units
      end
   end
   for _, e in ipairs(beliefs:since("payment.shipped", absorbed)) do
      if e.payload.payer == owner.name then
         b[decl.money] = b[decl.money] - e.payload.amount
      end
   end
   for _, e in ipairs(beliefs:since("payment.delivered", absorbed)) do
      if e.payload.payee == owner.name then
         b[decl.money] = b[decl.money] + e.payload.amount
      end
   end

   -- The world's own legs, in declared order. The engine keeps the
   -- watermark; the world keeps the meaning — whose books a kind
   -- touches is inside apply, where the world's words live.
   local legs = decl.legs or {}
   for i = 1, #legs do
      local leg = legs[i]
      for _, e in ipairs(beliefs:since(leg.kind, absorbed)) do
         leg.apply(b, e, owner)
      end
   end
   return b, since
end

-- ---------------------------------------------------------------
-- The truth side: the ledger cursor. A cache of the annals, never a
-- second authority — call catch_up() after every emit and nothing
-- in a tick can act on books that don't include its own
-- consequences (that is how a raid can never seize grain a same-day
-- trade already moved).
-- ---------------------------------------------------------------

local Ledger = {}
Ledger.__index = Ledger

-- The framework legs, truth side: net zero per shipment, and the
-- departure goes on the world's road calendar (the mail arrives at
-- dawn because the world registered its roads system first).
framework = {
   ["cargo.shipped"] = function(led, e)
      local p = e.payload
      local col = column_of(led, p.commodity)
      local sender = led.books[p.sender]
      sender[col] = sender[col] - p.units
      led.roads:schedule(e)
   end,
   ["cargo.delivered"] = function(led, e)
      local p = e.payload
      local col = column_of(led, p.commodity)
      local recipient = led.books[p.recipient]
      recipient[col] = recipient[col] + p.units
   end,
   ["payment.shipped"] = function(led, e)
      local p = e.payload
      local payer = led.books[p.payer]
      payer[led.money] = payer[led.money] - p.amount
      led.roads:schedule(e)
   end,
   ["payment.delivered"] = function(led, e)
      local p = e.payload
      local payee = led.books[p.payee]
      payee[led.money] = payee[led.money] + p.amount
   end,
}

-- decl: `columns` (ordered keys), `commodities`, `money`, `roads`
-- (the world's Roads, for scheduling departures), and `effects` —
-- kind → function(led, e) for the world's own kinds. The road
-- grammar is the engine's to book; a world effect for one of its
-- kinds is refused here rather than silently shadowed (card 169,
-- fork 1). A kind neither side claims is skipped, as every world's
-- elseif chain already skipped it (this is physics' cache, not the
-- audit — nothing here flags).
function Books.ledger(u, decl)
   assert(type(decl) == "table" and type(decl.columns) == "table"
         and type(decl.commodities) == "table"
         and type(decl.money) == "string"
         and type(decl.effects) == "table" and decl.roads ~= nil,
      "books: a ledger needs columns, commodities, money, roads, "
         .. "and effects")
   for kind in pairs(decl.effects) do
      -- pairs() is legal here, narrowly: validation only.
      assert(not framework[kind],
         ("books: %s is road grammar — the engine books it; a world "
            .. "effect would be shadowed"):format(kind))
   end
   return setmetatable({
      u = u,
      columns = decl.columns,
      commodities = decl.commodities,
      money = decl.money,
      roads = decl.roads,
      effects = decl.effects,
      books = {}, -- name → { column = balance }, folded truth
      cursor = 0,
   }, Ledger)
end

-- An actor enters the books: one value per declared column, opening
-- balances where the world says so, zero elsewhere — the audit's
-- enroll rule, which is why a hiring that says only cents opens
-- work at zero.
function Ledger:enroll(name, opening)
   local b = {}
   for i = 1, #self.columns do
      local col = self.columns[i]
      b[col] = opening[col] or 0
   end
   self.books[name] = b
   return b
end

function Ledger:catch_up()
   local annals = self.u.annals
   while self.cursor < annals:len() do
      self.cursor = self.cursor + 1
      local e = annals:get(self.cursor)
      local effect = framework[e.kind] or self.effects[e.kind]
      if effect then
         effect(self, e)
      end
   end
end

return Books
