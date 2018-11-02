--[===[DOC

= object

[source,lua]
----
function inherit( base1Tab[, base2Tab[, ...]] ) --> derivedTab
function isderived( derivedTab, baseTab ) --> truthnessBool
----

The `inherit` function retrun a new table that inherits from all the
`base1Tab`, `base2Tab` tables. When a field is not found in the new table, it
will be serched in the base ones, in the same orded as they were prvided (i.e.
`base1Tab` first). The first one found is returned.

The `isderived` function will check if `derivedTab` was generated ba an
`inherit` function call with `baseTab` somewhere in its arguments.

This module implements a prototype pattern, with multiple inheritace. It does
not provide a constructor semantic. You can use the `factory` module for that
purpose.

]===]

local setmetatable, move = setmetatable, table.move

local prototype_map = setmetatable({},{__mode="kv"})
local function protoadd( instance, protochain )

  local protos = prototype_map[instance]
  if not protos then
    protos = setmetatable( {meta={}}, {__mode="kv"} )
    prototype_map[instance] = protos
  end
  local meta = protos.meta

  local pn = #protochain
  if pn > 0 then
    move( protos, 1, #protos, pn+1)
  end
  move( protochain, 1, pn, 1, protos )
  pn = #protos

  if pn == 1 then
    meta.__index = protos[1]
  else
    meta.__index = function( _, k )
      for p = 1, pn do
        local field = protos[p][k]
        if field ~= nil then
          return field
        end
      end
    end
  end

  return setmetatable( instance, meta )
end

local function inherit(...)
  return protoadd({}, {...})
end

local function has_proto( derived, base )
  local protos = prototype_map[derived]
  if protos then
    for _, b in pairs(protos) do
      if b == base then return true end
      if has_proto( b, base ) then return true end -- TODO : avoid recursion? memoize?
    end
  end
  return false
end

return {
  inherit = inherit,
  isderived = has_proto,
}
