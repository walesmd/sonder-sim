package.path = "src/?.lua;" .. package.path
local Universe = require "sonder.universe"
local Vocabulary = require "sonder.vocabulary"
local V = { schema_version = 1, loudnesses = { "loud", "local", "quiet" }, kinds = {
  ["universe.genesis"] = { doc = "g", payload = { { "seed", "integer" } } },
  ["x.act"] = { doc = "a", payload = { { "who", "string" } } } } }
local function run(order, dist, label)
  local u = Universe.new(5, { vocabulary = V, distance = dist })
  local home = { a = "town", b = "town", c = "farm" }
  for _, n in ipairs(order) do
    u:add_faction(n, home[n], function(_, _, tick)
      if tick == 3 then return { { kind = "x.act", location = home[n], magnitude = 0, loudness = "quiet",
        payload = { who = n }, causes = { 1 } } } end
      return {}
    end)
  end
  u:run(8)
  local out = {}
  for _, n in ipairs(order) do
    for _, e in ipairs(u:beliefs(n):recall("x.act")) do
      out[#out+1] = ("%s<-%s(t%d)@%d"):format(n, e.payload.who, e.tick, e.learned)
    end
  end
  print(label, table.concat(out, "  "))
end
local map = function(f, t) if f == t then return 0 end return 2 end
run({ "a", "b" }, map, "order a,b (co-located, dist 0):")
run({ "b", "a" }, map, "order b,a (co-located, dist 0):")
run({ "a", "c" }, map, "order a,c (dist 2):          ")
run({ "c", "a" }, map, "order c,a (dist 2):          ")
run({ "a", "c" }, nil, "order a,c (nil distance):    ")
