--[===[DOC

= tuple

[source,lua]
----
function tuple( ... ) --> tupleTable
----

Constructs a tuple type, i.e. an object representing an unmodifiable list of
fields.

It returns the `tupleTable` table that allows to read the tuple fields, but it
forbit the modification of the fields.

When called with same arguments, the same table reference will be returned. The
unused reference will be automatically garbage collected.

== Inspired by

* http://lua-users.org/wiki/SimpleTuples

]===]

-- [SNIP:intern.lua[
local intern = (function()

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

end)()
-- ]SNIP:intern.lua]

local tuplefact = intern()

local function tuple( ... ) --> tupleTable

  local tupleTable = tuplefact( ... )
  if not getmetatable( tupleTable ).__type then -- First time initialization

    -- Store fields
    -- local n = select( '#', ... )
    -- local fields = { n=n, ... }
    -- for i = 1, fields.n do fields[i] = select( i, ... ) end
    local fields = { ... }
    fields.n = select( '#', ... )

    -- Dispatch to the stored fields, and forbid modification
    setmetatable( tupleTable, {
      type = 'tuple',
      __index = function( t, k ) return fields[k] end,
      __newindex = function( t, k ) return error( 'can not change tuple field', 2 ) end,
    })

  end
  return tupleTable
end

return tuple