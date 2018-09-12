--[===[DOC

= isreadable

[source,lua]
----
function isreadable( path ) --> res
----

Return `true` if the input `path` string points to a readable file. `false`
otherwise.

]===]

local function isreadable( path ) --> res
   local f = io.open(path, "r" )
   if not f then return false end
   f:close()
   return true
end

return isreadable