-- mathlib.lua 

module(..., package.seeall)

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
-- Functions Libraries 
-----------------------------------------------------------------------------------------

-- reduceToZero

reduceToZero = function (num,inc)

  r = num>0 and num-inc or num+inc
  local result = math.abs(r) <= inc and 0 or r -- short form if-then
  return result

end





