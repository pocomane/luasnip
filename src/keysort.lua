--[===[DOC

= keysort

[source,lua]
----
function keysort( inTab ) --> outArr
----

This function return the list of all the keys of the input `inTab`
table. The keys are alphabetically sorted. String keys came before any
other key. Other key are sorted with respect to their string
representation, i.e. `tostring` is internally used.

== Example

[source,lua,example]
----
local keysort = require 'keysort'

local sorted = keysort{[1]=400,[2]=300,['1']=200,['2']=100}
assert( sorted[1] == '1' )
assert( sorted[2] == '2' )
assert( sorted[3] == 1 )
assert( sorted[4] == 2 )
assert( #sorted == 4 )

----

]===]

local sort, tostring, type, ipairs, pairs =
  table.sort, tostring, type, ipairs, pairs

local function keysort( inTab ) --> outArr
  local outArr = {}
  local nonstring = {}
  for k in pairs(inTab) do
    if type(k) == 'string' then
      outArr[1+#outArr] = k
    else
      local auxkey = tostring(k)
      nonstring[1+#nonstring] = auxkey
      nonstring[auxkey] = k
    end
  end
  sort(outArr)
  sort(nonstring)
  for _,v in ipairs(nonstring) do
    outArr[#outArr+1] = nonstring[v]
  end
  return outArr
end

return keysort
