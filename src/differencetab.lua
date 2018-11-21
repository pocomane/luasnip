--[===[DOC

= differencetable

[source,lua]
----
function differencetab( firstTab, secondTab ) --> differenceTab
----

It returns a table that contain the keys present in the `firstTab` table but
not in the `secondTab` table.

No checks are performed on the associated values.

== Example

[source,lua,example]
----
local differencetab = require 'differencetab'

local diff = differencetab({a='a',b='b',c='c'},{a='A',d='d'})

assert( diff.b == 'b' )
assert( diff.c == 'c' )

local c = 0
for _ in pairs(diff) do c = c + 1 end
assert( c == 2 )

----

]===]

local function differencetab( firstTab, secondTab ) --> differenceTab
  local differenceTab = {}
  if not firstTab then return differenceTab end
  if not secondTab then
    for k, v in pairs(firstTab) do differenceTab[k] = v end
    return differenceTab
  end
  for k, v in pairs(firstTab) do
    if not secondTab[k] then
      differenceTab[k] = v
    end
  end
  return differenceTab
end

return differencetab
