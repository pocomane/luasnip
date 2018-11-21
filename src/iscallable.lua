--[===[DOC

= iscallable

[source,lua]
----
function iscallable( var ) --> res
----

This function will return `true` if `var` is callable through the standard function call
syntax. Otherwise it will return `false`.

== Example

[source,lua,example]
----
local iscallable = require "iscallable"

assert( false == iscallable( 'hi' ) )
assert( false == iscallable( {} ) )
assert( true == iscallable( function()end ))
assert( true == iscallable( setmetatable({},{__call=function()end }) ))

----

]===]

local function iscallable_rec( mask, i )

   if "function" == type( i ) then return true end

   local mt = getmetatable( i )
   if not mt then return false end
   local callee = mt.__call
   if not callee then return false end

   if mask[ i ] then return false end
   mask[ i ] = true

   return iscallable_rec( mask, callee )
end

local function iscallable( var ) --> res
   return iscallable_rec( {},  var )
end

return iscallable
