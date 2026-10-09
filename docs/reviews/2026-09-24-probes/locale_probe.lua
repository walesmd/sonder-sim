package.path = "src/?.lua;" .. package.path
local byteform = require "sonder.byteform"
local fnv = require "sonder.fnv"
local function hexs(s) return (s:gsub(".", function(c) local b = c:byte(); if b < 32 or b > 126 then return ("<%02x>"):format(b) end return c end)) end
local function classes()
  local n, list = 0, {}
  for b = 0, 255 do if string.char(b):match("%c") then n = n + 1; if b > 127 then list[#list+1] = ("%02x"):format(b) end end end
  return n, table.concat(list, ",")
end
local sample = "a\"b\\c\n\127\133" .. "é" .. "Ä" -- é = c3 a9, Ä = c3 84
for _, loc in ipairs{ "C", "en_US.UTF-8", "de_DE.ISO8859-1", "C.UTF-8" } do
  local set = os.setlocale(loc, "ctype")
  local n, high = classes()
  local out = byteform.json_string(sample)
  print(("locale %-16s set=%-16s %%c-bytes=%3d high=[%s]  json=%s  fnv=%016x"):format(loc, tostring(set), n, high, hexs(out), fnv.string(fnv.offset, out)))
end
