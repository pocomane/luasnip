--[===[DOC

= intersecationtab

[source,lua]
----
function intersecationtab( firstTab, secondTab, selectFunc ) --> intersecationTab
----

Creates the `intersecationTab` table that contain the keys shared by the
`firstTab` and `secondTab` tables. By default, the value of the first table
will be used as value in the result.

The `selectFunc` function may be optionally passed to select which value to
associate to the key.  It will be called with the two value associated to the
same key in the two argument table.  Its result will be used in the
intersecation table.

== Example

[source,lua,example]
----
local intersecationtab = require 'intersecationtab'

local int = intersecationtab({a='a',b='b',c='c',x='x1'},{a='A',d='d',x='x2'})

assert( int.a == 'a' )
assert( int.x == 'x1' )

local count = 0
for _ in pairs(int) do count = count + 1 end
assert( count == 2 )

local int = intersecationtab({a='a1'},{a='a2'},function(x,y) return y end)

assert( int.a == 'a2' )

----


]===]

local function intersecationtab( firstTab, secondTab, selectFunc ) --> intersecationTab
  local intersecationTab = {}
  if not firstTab or not secondTab then return intersecationTab end
  for k, v in pairs(firstTab) do
    local o = secondTab[k]
    if o then
      if not selectFunc then
        intersecationTab[k] = v
      else
        intersecationTab[k] = selectFunc(v, o)
      end
    end
  end
  return intersecationTab
end

return intersecationtab
