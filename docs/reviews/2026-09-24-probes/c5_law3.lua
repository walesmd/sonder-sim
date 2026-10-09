package.path = "src/?.lua;" .. package.path
local Universe = require "sonder.universe"
local V = { schema_version = 1, loudnesses = { "loud", "local", "quiet" }, kinds = {
  ["universe.genesis"] = { doc = "g", payload = { { "seed", "integer" } } },
  ["x.secret"] = { doc = "s", payload = { { "n", "integer" } } } } }
-- witness rule: an addressed row keyed on a kind nobody emits, so nothing is ever delivered
local u = Universe.new(9, { vocabulary = V, distance = function(f, t) return f == t and 0 or 4 end,
  mechanisms = { { name = "letters", shape = "addressed", speed = 1, to = { ["x.letter"] = "to" } } } })
u:add_system("secrets", function(uu, _, tick)
  if tick == 1 then uu:emit{ kind = "x.secret", location = "vault", magnitude = 0, loudness = "quiet", payload = { n = 42 }, causes = { 1 } } end
end)
u:add_faction("spy", "den", function(beliefs, stream, tick)
  if tick == 2 then
    print("tick 2: store len via proper door =", beliefs:len(), "latest(x.secret) =", beliefs:latest("x.secret"))
    -- door 1: debug.getlocal walks to Universe:step's self
    local lvl = 2
    while true do
      local info = debug.getinfo(lvl, "S"); if not info then break end
      local i = 1
      while true do
        local name, val = debug.getlocal(lvl, i); if not name then break end
        if name == "self" and type(val) == "table" and val.annals then
          local e = val.annals:get(2)
          print(("tick 2: debug.getlocal(%d,%d) '%s' -> universe; annals[2] = %s n=%d (never delivered)"):format(lvl, i, name, e.kind, e.payload.n))
        end
        i = i + 1
      end
      lvl = lvl + 1
    end
    -- door 2: plant a belief through the live store's receive()
    beliefs:receive({ id = 999, tick = 2, kind = "x.secret", location = "den", magnitude = 0, loudness = "quiet", payload = { n = 7 }, causes = {} }, 2)
    print("tick 2: planted; latest(x.secret).n =", beliefs:latest("x.secret").n or beliefs:latest("x.secret").payload.n)
  elseif tick == 3 then
    -- door 3: mutate the store's internals in place
    beliefs.by_kind["x.secret"][1].payload.n = 1000
    print("tick 3: mutated by_kind in place; latest(x.secret).payload.n =", beliefs:latest("x.secret").payload.n,
      "journal[1].payload.n =", beliefs.journal[1].payload.n)
  end
  return {}
end)
u:run(3)
