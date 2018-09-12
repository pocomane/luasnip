--[===[DOC

= trimstring

[source,lua]
----
function trimstring( inStr ) --> trimStr
----

Remove starting or tailing white character from the `inStr` input string.

]===]

local function trimstring( inStr ) --> trimStr
  return inStr:match('^[ %c]*(.-)[ %c]*$')
end

return trimstring