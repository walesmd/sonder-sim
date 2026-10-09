-- C1 verifier probe: zero-day freight, independent of books.lua (uncommitted).
-- Own catch_up over the annals (mirrors HEAD worlds' pattern), own ledger.
package.path = "src/?.lua;" .. package.path
local Universe = require "sonder.universe"
local Roads = require "sonder.roads"
local Audit = require "sonder.audit"
local Vocabulary = require "sonder.vocabulary"

local kinds = Vocabulary.with_road_kinds({
  ["universe.genesis"] = { doc = "g", payload = { { "seed", "integer" } } },
  ["v.founded"] = { doc = "f", payload = { { "name", "string" }, { "cents", "integer" }, { "grain", "integer" } } },
})
local V = { schema_version = 1, loudnesses = { "loud", "local", "quiet" }, kinds = kinds }

local function scenario(label, roads_first, distance)
  local u = Universe.new(3, { vocabulary = V, distance = distance })
  local seat = { a = "town", b = "town" }
  local roads = Roads.new(u, { resolve = function(n) return seat[n] end })
  local rows, cursor = {}, 0
  local function catch_up()
    while cursor < u.annals:len() do
      cursor = cursor + 1
      local e = u.annals:get(cursor)
      local p = e.payload
      if e.kind == "v.founded" then rows[p.name] = { cents = p.cents, grain = p.grain }
      elseif e.kind == "cargo.shipped" then rows[p.sender].grain = rows[p.sender].grain - p.units; roads:schedule(e)
      elseif e.kind == "cargo.delivered" then rows[p.recipient].grain = rows[p.recipient].grain + p.units
      elseif e.kind == "payment.shipped" then rows[p.payer].cents = rows[p.payer].cents - p.amount; roads:schedule(e)
      elseif e.kind == "payment.delivered" then rows[p.payee].cents = rows[p.payee].cents + p.amount end
    end
  end
  local function shipper(uu, _, tick)
    if tick == 1 then
      for _, n in ipairs{ "a", "b" } do
        uu:emit{ kind = "v.founded", location = seat[n], magnitude = 0, loudness = "local",
          payload = { name = n, cents = 100, grain = 10 }, causes = { 1 } }
        catch_up()
      end
    elseif tick == 3 then -- system-originated shipment, catch_up right after emit (the worlds' pattern)
      uu:emit{ kind = "cargo.shipped", location = seat.a, magnitude = 4, loudness = "local",
        payload = { commodity = "grain", units = 4, sender = "a", recipient = "b" }, causes = { 1 } }
      catch_up()
    end
  end
  if roads_first then
    u:add_system("roads", roads:system(catch_up)); u:add_system("shipper", shipper)
  else
    u:add_system("shipper", shipper); u:add_system("roads", roads:system(catch_up))
  end
  u:add_faction("a", "town", function(_, _, tick)
    if tick == 2 then -- faction-originated shipment (intent), emitted after systems, no catch_up
      return { { kind = "payment.shipped", location = "town", magnitude = 10, loudness = "local",
        payload = { amount = 10, payer = "a", payee = "b" }, causes = { 1 } } }
    end
    return {}
  end)
  u:add_faction("b", "town", function() return {} end)
  u:run(30)
  catch_up()
  local counts = {}
  for id = 1, u.annals:len() do local k = u.annals:get(id).kind; counts[k] = (counts[k] or 0) + 1 end
  local stale = {}
  for t, b in pairs(roads.freight.calendar) do if t <= u.tick then stale[#stale+1] = ("page %d holds %d"):format(t, #b) end end
  table.sort(stale)
  -- audit with world-style identities: held + on_road == founded
  local legs = {
    columns = { { key = "grain", negative = "%s grain %d" }, { key = "cents", negative = "%s cents %d" } },
    commodities = { grain = "grain" }, money = "cents",
    effects = { ["universe.genesis"] = false,
      ["v.founded"] = function(s, e, lib)
        lib.enroll(s, e.payload.name, e.location, { grain = e.payload.grain, cents = e.payload.cents })
        s.world.f = s.world.f or { grain = 0, cents = 0 }
        s.world.f.grain = s.world.f.grain + e.payload.grain; s.world.f.cents = s.world.f.cents + e.payload.cents
      end },
    identities = function(s, lib, last)
      local f = s.world.f
      if s.held.cents + s.on_road.cents ~= f.cents then lib.flag(s, last, "money not conserved") end
      if s.held.grain + s.on_road.grain ~= f.grain then lib.flag(s, last, "grain not conserved") end
    end,
  }
  local r = Audit.of(u.annals, legs, { days = function(f, t, k) return u:days(f, t, k) end })
  print(("[%s] tick=%d shipped: cargo %d payment %d | delivered: cargo %d payment %d | ledger a=%d¢/%dg b=%d¢/%dg | stale pages: %s")
    :format(label, u.tick, counts["cargo.shipped"] or 0, counts["payment.shipped"] or 0,
      counts["cargo.delivered"] or 0, counts["payment.delivered"] or 0,
      rows.a.cents, rows.a.grain, rows.b.cents, rows.b.grain, table.concat(stale, ", ")))
  print(("   audit: violations=%d mismatches=%d unexplained=%d held cents=%d on_road cents=%d held grain=%d on_road grain=%d")
    :format(#r.violations, #r.mismatches, #r.unexplained, r.held.cents, r.on_road.cents, r.held.grain, r.on_road.grain))
  for i = 1, #r.violations do print("   violation:", r.violations[i]) end
end

scenario("nil distance, roads first", true, nil)
scenario("nil distance, roads AFTER shipper", false, nil)
scenario("distance(a,a)=0 map, roads first", true, function(f, t) return f == t and 0 or 3 end)
scenario("distance always >=1, roads first", true, function(f, t) return f == t and 1 or 3 end)
