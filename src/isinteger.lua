--[===[DOC

= isinteger

[source,lua]
----
function isinteger( i ) --> res
----

It returns `true` if the argument `i` is an integer or not. Otherwise `false`.

]===]

local function isinteger( i ) --> res
   if "number" ~= type( i ) then return false end
   local i, f = math.modf( i )
   return ( 0 == f )
end

return isinteger