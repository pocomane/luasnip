--[===[DOC

= localbind

[source,lua]
----
function localbind( [levelInt [, execStr] ) --> bindTab, typeTab
----

It allows to inspect or change upvalues or local variable of any
function on the stack. This function is useful for debugging, e.g. it
can be stored in a global variable and so the user can recall it from
a `debug.debug()` sesssion.

The returned `bindTab` table contains all the locals, upvalues and globals as
seen from the target function. A change to a value in the table will
be propagated to the correspondent local variale or upvalue or global.

The __call metamethod of `bindTab` is set so you can call the table with a
variable name; it will return `local`, `upvalue` or `global` depending on the
type of the binding.

Varargs are not supported.

The optional `levelInt` index specifies the level on the stack where there is
the target function. 1 means the function calling localbind. If nil it will
default to 1. When selecting the value of this parameter, we should be careful
to tail recursion call that just take one stack position for the caller and the
callee.

Note that if a function does not access any global variable, the standard lua
compiler will not add a global reference into the compiled function. So the
code

```
G = 1
(function()
  localbind( 1 ).G = 2
end)()
print( G )
```

will print `1`, while

```
G = 1
(function()
  local l = print
  localbind( 1 ).G = 2
end)()
print( G )
```

will print `2`.

Moreover it is impossible to access an upvalue that was not compiled into the
function. So when the code try to access a upper-level variables that was not
accessed also in the function body, it will fallback to a global. E.g.

```
y = 0
local x, y = 1, 1
(function()
  local z = x
  print(localbind( 1 ).x, localbind( 1 ).y)
end)()
```

will print `1 0`

== Example

[source,lua,example]
----
local localbind = require 'localbind'

local function check(A, B)
  local M = localbind(3)

  assert( M('a') == 'upvalue' )
  assert( M('b') == 'local' )

  assert( M.a == A )
  assert( M.b == B )
end

local function set(A, B)
  local M = localbind(3)
  M.a = A
  M.b = B
end

local a = 1
(function()
  a = 2
  local b = 2
  (function()

    a,b = 3,3
    check(3,3)

    a,b = 0,0
    check(0,0)

    set(1,1)
    assert( a == 1 )
    assert( b == 1 )

  end)()
end)()
----

]===]

local pairs = pairs
local setmetatable = setmetatable
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getlocal = debug.getlocal
local setlocal = debug.setlocal

-- Return the stack index to access the i-th function, counting from the bottom.
-- Default argument is 1 and it correspond the the last lua (non C)
-- function on the stack.
local function stackfrombottom( level )
  if not level then level = 1 end
  local result = 1
  while getinfo(result) do
    result = result + 1
  end
  -- Note: the last non-nil getinfo refers to the C core; the
  --       second-last is the first lua function.
  return result - level - 2
end

local function localbind( stacklevel )
  stacklevel = stacklevel or 1
  local blevel = stackfrombottom() - stacklevel
	local func = getinfo( stackfrombottom( blevel ) ).func
  local global = {} -- Fake global when no global is compiled-in

  local function bindget( req, cache )

    -- Retrieve the locals
    local l = stackfrombottom( blevel )
    i = 0;
    while true do
      i = i + 1
      local key, value = getlocal(l, i)
      if not key then break end
      if not key:match'^%(%*' then
        if values then values[key] = value end
        if cache and not cache[key] then cache[key] = value end
        if req == key then return value, 'local', i, l-1 end
      end
    end

    -- Retrieve the upvalues
    i = 0;
    while true do
      i = i + 1
      local key, value = getupvalue(func, i)
      if not key then break end
      if values then values[key] = value end
      if key == '_ENV' then 
        global = value 
      end -- Search for the "Global table"
      if cache and not cache[key] then cache[key] = value end
      if req == key then return value, 'upvalue', i, l-1 end
    end

    -- Retrieve the globals
    if global then 
     for key, value in pairs(global) do
      if values then values[key] = value end
      if cache and not cache[key] then cache[key] = value end
      if req == key then return value, 'global', key, stackfrombottom(blevel)-1 end
    end end

    -- Not found
    return nil, 'nil', nil, stackfrombottom(blevel)-1
  end

  local function bindset( key, value )
    local _, type, index, l = bindget( key )

    -- Mutating a local
    if type and type == 'local' then
      setlocal( l, index, value )
    end

    -- Mutating an upvalue
    local func = getinfo(l).func
    if type and type == 'upvalue' then
      setupvalue( func, index, value )
    end

    -- Mutating a global
    if not type or type == 'global' or type == 'nil' then
      if global then global[key] = value end
    end
  end

  return setmetatable({}, { -- Binding proxy
    __pairs = function( self )
      local p={}
      bindget({},p)
      return pairs(p)
    end,
    __call = function( self, key )
      local v, t = bindget(key)
      return t or 'nil', v
    end,
    __index = function( self, key )
      return (bindget( key ))
    end,
    __newindex = function( self, key, value )
      bindset( key, value )
    end
  })
end

return localbind
