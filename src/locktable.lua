--[===[DOC

= locktable

[source,lua]
----
function locktable( inTab [, modeStr ...] ) --> protectTab
----

Return the `protectTab` proxy table: each operation on it will be actually
performed on the `inTab` input table. A list of string can be optionally passed
to forbid some kind of operation. If an operation is forbidden, when trying to
perform it on `protectTab`, an error will be thrown.

The avaiable limitation are:

- 'readnil': error if try to read a empty key
- 'writenil': error if try to write an empty key
- 'read': error if try to read any key
- 'write': error if try to write any key
- 'iterate': error if try to iterate with `pairs` or `ipairs`
- 'full': all the previous

Any of this limitation specifier can be as optiontional alrgument. More
limitation can be passed as variadic argument list.

A typical usage is the protection of the environment to check the access to a
undefined global:

```
_ENV = require 'locktable' ( _ENV, 'readnil' )
local x = True --> this rises an error, while normally just nil was placed in x
```

]===]

local error, setmetatable = error, setmetatable
local pairs, ipairs = pairs, ipairs
local rawget, rawset = rawget, rawset

local function iterate( )
  error('Iteration on fielad was forbidden', 2)
end

local function readall( )
  error('Access of any field was forbidden', 2)
end

local function writeall( )
  error('Change of any field was forbidden', 2)
end

local function lockingmeta( inTab, ... ) --> proxyMet

  local function readnil( s, k )
    local v = rawget( inTab, k )
    if nil == v then
      error('Read of nil field was forbidden', 2) end
    return v
  end

  local function writenil( s, k, v )
    if nil == rawget( inTab, k ) then
      error('Write of nil field was forbidden', 2)
    end
    rawset( inTab, k, v )
  end

  local metatable = {
    __newindex = function(s, k, v) rawset( inTab, k, v ) end,
    __index = function(s,k) return rawget( inTab, k ) end,
    __pairs = function(...) return pairs(inTab, ...) end,
    __ipairs = function(...) return ipairs(inTab, ...) end,
  }

  for _, locktype in ipairs({...}) do

    if locktype == 'readnil' or locktype == 'full' then
      metatable.__index = readnil
    end
    
    if locktype == 'writenil' or locktype == 'full' then
      metatable.__newindex = writenil
    end

    if locktype == 'iterate' or locktype == 'full' then
      metatable.__pairs = iterate
      metatable.__ipairs = iterate
    end

    if locktype == 'read' or locktype == 'full' then
      metatable.__index = readall
    end

    if locktype == 'write' or locktype == 'full' then
      metatable.__newindex = writeall
    end
  end

  return metatable
end

local function locktable( inTab, ... ) --> lockedTab
  return setmetatable( {}, lockingmeta( inTab, ... ))
end

return locktable
