--[===[DOC

= factory

[source,lua]
----
function factory( initFunc ) --> constructorFunc, checkFunc
----

This module create the `constructorFunc` construction function, and the `checkFunc` checker function.

The `constructorFunc`:

[source,lua]
----
function constructorFunc( initTab ) --> objectTab, ...
----

calls the `initFunc` on the `initTab` (or a new one if `nil` is passed). It
returns the `initTab`. Any return value of `initFunc` will be appended to the
results.

The `checkFunc`:

[source,lua]
----
function checkFunc( aTab ) --> truthnessBool 
----

takes any `aTab` table as input and checks if it was constructed with the
associated `constructorFunc`.

These functions can be used in a class/mixin pattern: calling `constructorFunc`
just means to construct an object of a given class/mixin. However a method
assigned to the instance by the `initFunc` can be lately removed from a single
instance. To grant that a method of a base class is always present,
`object.inherit` can be used inside `initFunc`.

]===]

local setmetatable = setmetatable

local function factory(initializer)
  local made_here = setmetatable({},{__mode='kv'})

  local function constructor(instance)
    instance = instance or {}
    made_here[instance] = true
    return instance, initializer(instance)
  end

  local checker = function(instance)
    if made_here[instance] then return true end
    return false
  end

  return constructor, checker
end

return factory
