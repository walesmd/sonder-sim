package.path = "src/?.lua;" .. package.path
local Universe = require "sonder.universe"
local Vocabulary = require "sonder.vocabulary"
local function vocab(louds, genesis_payload)
  return { schema_version = 1, loudnesses = louds, kinds = {
    ["universe.genesis"] = { doc = "g", payload = genesis_payload or { { "seed", "integer" } } },
    ["x.act"] = { doc = "a", payload = {} } } }
end
-- (1) typo'd option key
local rows = { { name = "earshot", shape = "radiated", speed = 1, range = { loud = 2, quiet = 0, ["local"] = 1 } } }
local okA, uA = pcall(Universe.new, 7, { vocabulary = vocab({ "loud", "quiet", "local" }),
  distance = function(f, t) return f == t and 0 or 5 end, mechanism = rows })
print("typo 'mechanism': ok=", okA, okA and ("rows: " .. #uA.carriage.rows .. " = " .. uA.carriage.rows[1].name) or uA)
local okB, uB = pcall(Universe.new, 7, { vocabulary = vocab({ "loud", "quiet", "local" }),
  distance = function(f, t) return f == t and 0 or 5 end, mechanisms = rows })
print("correct 'mechanisms': ok=", okB, okB and ("rows: " .. #uB.carriage.rows .. " = " .. uB.carriage.rows[1].name) or uB)
local okC, uC = pcall(Universe.new, 7, { vocabulary = vocab({ "loud" }), chanel_speed = 9 })
print("typo 'chanel_speed': ok=", okC, okC and ("channel_speed=" .. uC.channel_speed) or uC)
-- (2) loudness set without 'loud'
local v = vocab({ "shout", "murmur" })
print("Vocabulary.check {shout,murmur}:", pcall(Vocabulary.check, v))
print("Universe.new with {shout,murmur}:", pcall(Universe.new, 7, { vocabulary = v }))
-- (3) genesis payload differs
local v2 = vocab({ "loud" }, { { "origin", "string" } })
print("Vocabulary.check genesis{origin}:", pcall(Vocabulary.check, v2))
print("Universe.new genesis{origin}:", pcall(Universe.new, 7, { vocabulary = v2 }))
