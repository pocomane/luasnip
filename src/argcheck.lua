--[===[DOC

= argcheck

[source,lua]
----
function argcheck( specTab , ... ) --> wrapFunc
----

This function return error if the argument specification in the table `specTab`
does not match with the rest of the arguments.

`specTab` must be an array of strings. Each one is the expected lua type of a
following argument (as returned from the standard `type` function). The number
of the following arguments must be equal to the length of the array.

The main use case is as the first line of a user defined function. In that
case an error corresponds to wrong arguments passed by the caller of the
caller of `argcheck`. So its stack position is reported as the source of the
error i.e. two stack level above `argcheck`.

== Example

[source,lua,example]
----
local argcheck = require 'argcheck'

local _, err = pcall(function()
  argcheck({'number','string','boolean'}, 1, false, false)
end)

assert( err:match 'Invalid argument #2 type%. Must be string not boolean%.$' )

----

]===]

local function argcheck( specTab, ... ) --> wrapFunc
  local arg = table.pack(...)
  local argn = arg.n
  if #specTab ~= argn then error('Invalid number of arguments. Must be '.. #specTab..' not '.. argn ..'.', 3) end
  for a = 1, argn do
    local argtype, exptype = type(arg[a]), specTab[a] 
    if argtype ~= exptype then
      error('Invalid argument #'..a..' type. Must be '..exptype..' not '..argtype..'.', 2)
    end
  end
end

return argcheck
