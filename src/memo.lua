--[===[DOC

= memo

[source,lua]
----
function memo( coreFunc ) --> wrapFunc
----

This function take any function `coreFunc` as input and it return the memoized
version `wrapFunc`. The momoized wrapper will call the core function only the
first time that a new combination of input values is passed. If `wrapFunc` is
re-called with the same parameters, it does not call `coreFunc` but it just
returns a cashed copy of the results.

== Example

[source,lua,example]
----
local memo = require 'memo'

local f = memo(function(a) return {} end)

assert ( f'' == f'' )
assert ( f'' ~= f'x' )
----

]===]

local intern = (function()
-- [SNIP:intern.lua[
local function intern() --> reference

  local rawget, rawset, select, setmetatable =
    rawget, rawset, select, setmetatable, select
  local NIL, NAN = {}, {}

  local internmeta = {
    __index = function() error('Can not access interned content directly.', 2) end,
    __newindex = function() error('Can not cahnge or add contents to a intern.', 2) end,
  }

  local internstore = setmetatable( {}, { __mode = "kv" } )

  -- A map from child to parent is used to protect the internstore table's contents.
  -- In this way, they will he collected only when all the cildren are collected
  -- in turn.
  local parent = setmetatable( {}, { __mode = 'k' })

  return function( ... )
    local currentintern = internstore
    for a = 1, select( '#', ... ) do

      -- Get next intern field. Replace un-storable contents.
      local tonext = select( a, ... )
      if tonext ~= tonext then tonext = NAN end
      if tonext == nil then tonext = NIL end

      -- Get or create the correspondent sub-intern
      local subintern = rawget( currentintern, tonext )
      if subintern == nil then

        subintern = setmetatable( {}, internmeta )
        parent[subintern] = currentintern
        rawset( currentintern, tonext, subintern )
      end

      currentintern = subintern
    end
    return currentintern
  end
end

return intern
-- ]SNIP:intern.lua]
end)()

local setmetatable, pack, unpack = setmetatable, table.pack, table.unpack

local function memo(func)

  local memo_input = intern()
  local memo_output = setmetatable({},{__mode='k'})

  return function( ... )
    local i = memo_input( ... )
    local v = memo_output[i]
    if not v then
      v = pack(func(...))
      memo_output[i] = v
    end
    return unpack(v)
  end
end

return memo
