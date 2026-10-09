package.path = "src/?.lua;" .. package.path
local Universe = require "sonder.universe"
local Vocabulary = require "sonder.vocabulary"
local Audit = require "sonder.audit"
local kinds = Vocabulary.with_road_kinds({
  ["universe.genesis"] = { doc = "g", payload = { { "seed", "integer" } } },
  ["t.born"] = { doc = "actor", payload = { { "name", "string" }, { "grain", "integer" }, { "cents", "integer" } } },
})
local voc = { schema_version = 1, loudnesses = { "loud", "local", "quiet" }, kinds = kinds }
local dist = function(f, t) return f == t and 0 or 4 end
local u = Universe.new(3, { vocabulary = voc, distance = dist })
u:add_system("forger", function(uu, _, tick)
  if tick == 1 then
    for _, n in ipairs{ "a", "b", "c" } do
      uu:emit{ kind = "t.born", location = n .. "-home", magnitude = 1, loudness = "local", payload = { name = n, grain = 20, cents = 100 }, causes = { 1 } }
    end
  elseif tick == 3 then
    local s = uu:emit{ kind = "cargo.shipped", location = "a-home", magnitude = 7, loudness = "local", payload = { commodity = "grain", units = 7, sender = "a", recipient = "b" }, causes = { 2 } }
    uu:emit{ kind = "cargo.delivered", location = "c-home", magnitude = 7, loudness = "local", payload = { commodity = "grain", units = 7, sender = "b", recipient = "c" }, causes = { s } }
    local p = uu:emit{ kind = "payment.shipped", location = "b-home", magnitude = 40, loudness = "local", payload = { amount = 40, payer = "b", payee = "a" }, causes = { 3 } }
    uu:emit{ kind = "payment.delivered", location = "c-home", magnitude = 40, loudness = "local", payload = { amount = 40, payer = "a", payee = "c" }, causes = { p } }
  end
end)
u:run(8)
for id = 1, u.annals:len() do local e = u.annals:get(id); print(id, e.tick, e.kind, e.location, e.causes[1]) end
local legs = { columns = { { key = "grain", negative = "%s neg grain %d" }, { key = "cents", negative = "%s neg cents %d" } },
  commodities = { grain = "grain" }, money = "cents",
  effects = { ["universe.genesis"] = false, ["t.born"] = function(s, e, lib) lib.enroll(s, e.payload.name, e.location, { grain = e.payload.grain, cents = e.payload.cents }) end },
  identities = function() end }
local r = Audit.of(u.annals, legs, { days = function(f, t, k) return u:days(f, t, k) end })
print(("violations=%d mismatches=%d unexplained=%d | grain a=%d b=%d c=%d | cents a=%d b=%d c=%d | on_road grain=%d cents=%d"):format(
  #r.violations, #r.mismatches, #r.unexplained, r.books.a.grain, r.books.b.grain, r.books.c.grain, r.books.a.cents, r.books.b.cents, r.books.c.cents, r.on_road.grain, r.on_road.cents))
print("road days a-home->b-home at tick 3 =", u:days("a-home", "b-home", 3))
