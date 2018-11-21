--[===[DOC

= combinetab

[source,lua]
----
function combinetab( firstTab, secondTab[, ...], combFunc )
----

The `combFunc` function will be called for each combination of the input table
list `firstTab, secondTab, ...`.

A single combination is generated selecting for each key of any input table,
the value from one of the tables. All the combinations will be considered
exactly one time. An absent key will be considered as another possible
value: 'nil'.


== Example

[source,lua,example]
----

local combinetab = require 'combinetab'

local r, n = {}, 0
local function tcol(x)
  local t = {}
  for k,v in pairs(x) do t[k] = v end
  n = n + 1
  r[n] = t
end

combinetab( {k='a',x='a'}, {k='b'}, tcol )

assert( #r == 4 )
assert( r[1].k == 'a' )
assert( r[1].x == 'a' )
assert( r[2].k == 'b' )
assert( r[2].x == 'a' )
assert( r[3].k == 'a' )
assert( r[4].k == 'b' )

----

]===]

local function combinetab(...)
  local n = select('#',...)
  local f = select(n,...)
  n = n -1
  c = {}
  cc = 0
  for i=1,n do
    for k in pairs((select(i,...))) do
      if not c[k] then
        c[1+#c] = k
        cc = cc + 1
        c[k] = true
      end
    end
  end
  table.sort( c )
  local s = {}
  for i = 1,cc do s[i] = 1 end
  while s[cc] <= n do
    local a = {}
    for i = 1,cc do
      local k = c[i]
      a[k] = select(s[i],...)[k]
    end
    f(a)
    s[1] = s[1] + 1
    for i = 2,cc do -- carry
      if s[i-1] <= n then
        break
      else
        s[i-1] = 1
        s[i] = s[i] + 1
      end
    end
  end
end

return combinetab
