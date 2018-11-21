--[===[DOC

= isreadable

[source,lua]
----
function isreadable( path ) --> res
----

Return `true` if the input `path` string points to a readable file. `false`
otherwise.

== Example

[source,lua,example]
----
local isreadable = require "isreadable"

io.open( "isreadable.txt", "wb" ):close()
assert( isreadable( "isreadable.txt" ) == true )

os.remove( "isreadable.txt" )
assert( isreadable( "isreadable.txt" ) == false )
----

]===]

local function isreadable( path ) --> res
   local f = io.open(path, "r" )
   if not f then return false end
   f:close()
   return true
end

return isreadable
