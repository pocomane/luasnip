--[===[DOC

= trimstring

[source,lua]
----
function trimstring( inStr ) --> trimStr
----

Remove starting or tailing white character from the `inStr` input string.

== Example

[source,lua,example]
----
local trimstring = require 'trimstring'

assert( trimstring(' \nstr\r\t ') == 'str' )
----

]===]

local function trimstring( inStr ) --> trimStr
  return inStr:match('^[ %c]*(.-)[ %c]*$')
end

return trimstring
