-- independent war census: run from repo root
package.path = "src/?.lua;" .. package.path
local world, seed, ticks = arg[1], math.tointeger(tonumber(arg[2])), math.tointeger(tonumber(arg[3]))
local u = require("worlds." .. world)(seed)
u:run(ticks)
local a = u.annals
local N = a:len()
local open = {}          -- aggressor -> war
local wars = {}
local maxprice, minprice = nil, nil
local tallies = {}       -- "loc@tick" -> payload
local tallykind = world == "space" and "civ.tally" or "continent.tally"
for id = 1, N do
  local e = a:get(id)
  if e.kind == tallykind then tallies[e.location .. "@" .. e.tick] = e.payload end
  if e.kind == "market.price" then
    local p = e.payload.price
    if not maxprice or p > maxprice then maxprice = p end
    if not minprice or p < minprice then minprice = p end
  end
  if e.kind == "war.declared" then
    local p = e.payload
    assert(not open[p.aggressor], "overlapping war by " .. p.aggressor)
    local w = { id = id, tick = e.tick, loc = e.location, aggressor = p.aggressor, target = p.target, reason = p.reason, measure = p.measure, marches = 0 }
    open[p.aggressor] = w
    wars[#wars + 1] = w
  elseif e.kind == "war.march" then
    local w = open[e.payload.raider]; if w then w.marches = w.marches + 1 end
  elseif e.kind == "war.peace" then
    local w = open[e.payload.name]
    assert(w, "peace without war")
    w.peace = e.tick; w.peace_payload = e.payload; w.peace_loc = e.location
    open[e.payload.name] = nil
  end
end
local durs, reasons, pairs_, paths, marchset = {}, {}, {}, {}, {}
local ticks_list, gaps = {}, {}
local unfinished = 0
for i, w in ipairs(wars) do
  ticks_list[#ticks_list + 1] = w.tick
  if i > 1 then gaps[#gaps + 1] = w.tick - wars[i - 1].tick end
  reasons[w.reason] = (reasons[w.reason] or 0) + 1
  local pr = w.aggressor .. "->" .. w.target
  pairs_[pr] = (pairs_[pr] or 0) + 1
  if w.peace then
    local d = w.peace - w.tick
    durs[d] = (durs[d] or 0) + 1
    marchset[w.marches] = (marchset[w.marches] or 0) + 1
    -- which peace condition held at the peace tick?
    local t = tallies[w.peace_loc .. "@" .. w.peace]
    local conds = {}
    if world == "space" then
      local weary = d >= 10
      local relieved = w.reason == "price" and w.peace_payload.price <= 110
      local full = t and t.stock >= 100
      if weary then conds[#conds+1] = "weary" end
      if relieved then conds[#conds+1] = "relieved" end
      if full then conds[#conds+1] = "full" end
      w.stock = t and t.stock
    else
      local weary = d >= 8
      local fed = t and t.grain >= 50
      if weary then conds[#conds+1] = "weary" end
      if fed then conds[#conds+1] = "fed" end
      w.stock = t and t.grain
    end
    local k = table.concat(conds, "+"); paths[k] = (paths[k] or 0) + 1
  else
    unfinished = unfinished + 1
  end
end
local function fmt(t)
  local ks = {}
  for k in pairs(t) do ks[#ks + 1] = k end
  table.sort(ks, function(x, y) return tostring(x) < tostring(y) end)
  local out = {}
  for _, k in ipairs(ks) do out[#out + 1] = tostring(k) .. "x" .. t[k] end
  return "{" .. table.concat(out, ", ") .. "}"
end
local gapset = {}
for _, g in ipairs(gaps) do gapset[g] = (gapset[g] or 0) + 1 end
print(("%s seed=%d ticks=%d events=%d wars=%d unfinished=%d"):format(world, seed, ticks, N, #wars, unfinished))
print("  durations " .. fmt(durs))
print("  marches/war " .. fmt(marchset))
print("  reasons " .. fmt(reasons) .. "  pairs " .. fmt(pairs_))
print("  peace conditions true at peace tick " .. fmt(paths))
if maxprice then print(("  market.price min %d max %d (temperament 150)"):format(minprice, maxprice)) end
local tl = {}
for i = 1, math.min(12, #ticks_list) do tl[#tl + 1] = ticks_list[i] end
print("  first decl ticks " .. table.concat(tl, ","))
print("  gaps between declarations " .. fmt(gapset))
local per = {}
for _, w in ipairs(wars) do local b = w.tick // 100; per[b] = (per[b] or 0) + 1 end
local pl = {}
for b = 0, (ticks - 1) // 100 do pl[#pl + 1] = per[b] or 0 end
print("  wars per 100-tick bucket " .. table.concat(pl, " "))
local sp = {}
for i = 1, math.min(8, #wars) do sp[#sp+1] = tostring(wars[i].stock) end
print("  aggressor stock at peace (first 8) " .. table.concat(sp, ","))
