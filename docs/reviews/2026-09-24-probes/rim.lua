package.path = "src/?.lua;" .. package.path
local seed, ticks = math.tointeger(tonumber(arg[1])), math.tointeger(tonumber(arg[2]))
local u = require("worlds.continent")(seed)
u:run(ticks)
local a = u.annals
local homes = { selm = "selm-water", tethri = "tethri-steppe", ashfold = "ash-gate", valebright = "vale-bright", korrag = "korrag-height" }
local intentkinds = { ["continent.tally"]=true, ["continent.hunger"]=true, ["continent.accept"]=true, ["continent.offer"]=true, ["cargo.shipped"]=true, ["payment.shipped"]=true, ["war.declared"]=true, ["war.peace"]=true, ["war.march"]=true }
local wars = 0
for id = 1, a:len() do if a:get(id).kind == "war.declared" then wars = wars + 1 end end
print(("continent seed=%d ticks=%d annals=%d wars=%d"):format(seed, ticks, a:len(), wars))
for _, name in ipairs({ "selm", "tethri" }) do
  local home = homes[name]
  local last, kinds, lastany, anyk = {}, {}, 0, {}
  for id = 1, a:len() do
    local e = a:get(id)
    if e.location == home and e.kind ~= "continent.tally" then
      lastany = e.tick
      anyk[e.kind] = (anyk[e.kind] or 0) + 1
      if intentkinds[e.kind] then
        kinds[e.kind] = (kinds[e.kind] or 0) + 1
        last[e.kind] = e.tick
      end
    end
  end
  local out = {}
  local ks = {} for k in pairs(anyk) do ks[#ks+1] = k end table.sort(ks)
  for _, k in ipairs(ks) do out[#out+1] = k .. "=" .. anyk[k] .. (last[k] and ("(last t" .. last[k] .. ")") or "") end
  local lastdec = 0 for _, t in pairs(last) do if t > lastdec then lastdec = t end end
  print(("  %-7s non-tally events at home: %s"):format(name, table.concat(out, " ")))
  print(("          last non-tally intent tick=%d, last non-tally event of any kind at home tick=%d"):format(lastdec, lastany))
  local store = u:beliefs(name)
  local wk = {}
  for _, b in ipairs(store:chronology()) do
    if b.kind:match("^war%.") then wk[b.kind] = (wk[b.kind] or 0) + 1 end
  end
  local w = {} for k, v in pairs(wk) do w[#w+1] = k .. "=" .. v end table.sort(w)
  print(("          war.* beliefs held: {%s}; store len %d"):format(table.concat(w, ", "), store:len()))
end
