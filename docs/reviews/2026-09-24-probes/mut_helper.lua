-- verifier's own courier mutant. env (all required): MUT_MODE=drop|late (anything but drop means late),
-- MUT_KIND=<exact kind>, MUT_OUT=<file for a periodic touch count>
local Carriage = require "sonder.carriage"
local mode, kind, out = os.getenv("MUT_MODE"), os.getenv("MUT_KIND"), os.getenv("MUT_OUT")
local orig = Carriage.arrival
local touched = 0
Carriage.arrival = function(self, e, name, home)
   local t, row = orig(self, e, name, home)
   if t ~= nil and e.kind == kind then
      touched = touched + 1
      if touched % 25 == 1 then
         local f = io.open(out, "w"); f:write(touched, "\n"); f:close()
      end
      if mode == "drop" then return nil end
      return t + 1, row
   end
   return t, row
end
