--[===[DOC

= uniontab

[source,lua]
----
function uniontab( firstTab, secondTab[, selectFunc] ) --> unionTab
----

Creates the `unionTabl` table that contain all the keys of the `firstTab` and
`secondTab` tables.

When both the table have the same key the value of the first table will be
used. This can be changed passing the optional `selectFunc` function. It will
be called with both the values as arguments, and its result will be used in the
union table.

== Example

[source,lua,example]
----
local uniontab = require 'uniontab'

local union = uniontab({a='a',c='c'},{b='b',c='C'})
assert( union.a == 'a')
assert( union.b == 'b')
assert( union.c == 'c')

local union = uniontab({a='a',c='c'},{b='b',c='C'}, function(x,y)return y end)
assert( union.a == 'a')
assert( union.b == 'b')
assert( union.c == 'C')
----

]===]

local function uniontab( firstTab, secondTab, selectFunc ) --> unionTab
  local unionTab = {}
  if secondTab then
    for k, v in pairs(secondTab) do unionTab[k] = v end
  end
  if not firstTab then return unionTab end
  for k, v in pairs(firstTab) do
    local o = unionTab[k]
    if not o then
      unionTab[k] = v
    else
      if not selectFunc then
        unionTab[k] = v
      else
        unionTab[k] = selectFunc(v, o)
      end
    end
  end
  return unionTab
end

return uniontab
