--[===[DOC

= factory

[source,lua]
----
function factory( initFunc ) --> buildFunc, checkFunc
----

This module create the `buildFunc` construction function, and the `checkFunc`
checker function. These functions can be used in a class/mixin pattern: calling
`buildFunc` just means to construct an object of a given class/mixin.

The `buildFunc`:

[source,lua]
----
function buildFunc( initTab ) --> objectTab[, error]
----

calls the `initFunc` on the `initTab` (or a new one if `nil` is passed).
`buildFunc` return the first two results of `initFunc`, if one of them is not
nil. If both are nil, `buildFunc` returns `initTab` as `objectTab` and nil as
`error`.

The `checkFunc`:

[source,lua]
----
function checkFunc( aTab ) --> truthnessBool 
----

takes any `aTab` table as input and checks if it was constructed with the
associated `buildFunc`.

To inherit method you can simply call the `buildFunc` of the base object from
the initializer of the derived one. However this allows a subsequent removal of
a inherited method. If this is not the wanted beavior, the initilizer function
can make and return an empty object, setting its __index metamethod to the
`initTab` instance. So any field access to the derived `buildFunc` will be
dispatched to `initTab`, but not the write ones.

== Example

[source,lua,example]
----
local factory = require 'factory'

local make2DPoint, is2DPoint = factory(function(ins)
  local x, y = ins[1], ins[2]
  ins.scale = ins.scale or 1

  function ins:getX() return self.scale * x end
  function ins:getY() return self.scale * y end

  function ins:getR2() return self.scale * ( x*x + y+y ) end
end)

local make3DPoint, is3DPoint = factory(function(ins)
  make2DPoint(ins)
  ins.get2DR2 = ins.getR2
  local z = ins[3]

  function ins:getZ() return self.scale * z end

  function ins:getR2() return ins:get2DR2() + self.scale * z*z end
end)

local p2d = make2DPoint { 1, 2 }

assert( is2DPoint( p2d ) == true )
assert( is3DPoint( p2d ) == false )
assert( p2d:getR2() == 5 )

p2d.scale = 2

assert( p2d:getR2() == 10 )

local p3d = make3DPoint { 1, 2, 3 }

assert( is2DPoint( p3d ) == true )
assert( is3DPoint( p3d ) == true )

assert( p3d:getR2() == 14 )

p3d.scale = 2

assert( p3d:getR2() == 28 )
----

]===]

--[[

-- TODO : super accessor IDEA :
local function method_accessor( obj )
  local result = {}
  for k, v in pairs( obj ) do
    if 'function' == type( v ) then
      result[ k ] = v
    end
  end
  return setmetatable( result, { __index = obj, __newindex = obj, })
end

-- TODO : super accessor IDEA USAGE :
local make3DPoint, is3DPoint = factory(function(ins)
  make2DPoint(ins)
  local super = method_accessor(ins)
  local z = ins[3]
  function ins:getZ() return self.scale * z end
  function ins:getR2() return super:getR2() + self.scale * z*z end
end)

--]]

local type, select, setmetatable = type, select, setmetatable

local function factory( initializer )

  local made_here = setmetatable({},{__mode='kv'})
  local function checker(i) return made_here[i] or false end

  local function constructor( instance )
    instance = instance or {}
    made_here[instance] = true

    local replace, err = initializer( instance )
    if nil ~= err then
      return replace, err
    elseif nil ~= replace then
      instance = replace
      made_here[instance] = true
    end

    return instance, err
  end
  return constructor, checker
end

return factory
