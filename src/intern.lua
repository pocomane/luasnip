--[===[DOC

= intern

[source,lua]
----
function intern( ... ) --> `refTab`
----

This function interns the list of arguments, i.e. it generates a reference
table `refTab` for each possible list. When it is called multiple times with
the same list, it will return the same reference.  All the reference are
automatically garbage collected when no more used.

== Inspired by

* http://lua-users.org/wiki/SimpleTuples

== Example

[source,lua,example]
----
local intern = require 'intern'

local int = intern()

local a = int( 1, nil, 0/0, 3 )
local b = int( 1, nil, 0/0, 2 )
local c = int( 1, nil, 0/0, 2 )

assert( a ~= b )
assert( b == c )

----

]===]

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
