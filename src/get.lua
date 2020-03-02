--[===[DOC

= get

[source,lua]
----
function get( parent [, ...] ) --> content
----

Get content trashing any access error. In case of access error, nil plus
an error messate are returned. The `parent` lua value is recursively
searched for the field passed as subsequent arguments.

Note: the __index metamethod is used when found.

== Example

[source,lua,example]
----
local get = require 'get'

local data = {a={b={c='d'}}}
assert( 'd' == get(data,'a','b','c'))
assert( nil == get(data,'a','x','c'))

----

]===]

local select = select
local pcall = pcall

local function get_rec(count, parent, child, ...)
  return count < 2 and parent or get_rec(count-1, parent[child], ...)
end

return function(...) -- get
  local ok, data = pcall(function(...)
    return get_rec(select('#', ...), ...)
  end, ...)
  local result = ok and data or nil
  return result, not ok and data or nil
end
