--[===[DOC

= flatarray

[source,lua]
----
function flatarray( inTab[, depthInt] ) --> outTab
----

Recursively expands the nested array in the input array `inTab` array and
return the result in the `outTab` array. The max depth level `depthInt` can be
passed.

]===]

local function flatarray( inTab, depthInt ) --> outTab
  local outTab = {}
  local n = 0
  local redo = false
  for _, v in ipairs( inTab ) do
    if 'table' == type(v) then
      for _, w in ipairs( v ) do
        n = n + 1
        outTab[n] = w
        if 'table' == type(w) then redo = true end
      end
    else
      n = n + 1
      outTab[n] = v
    end
  end
  if not redo then return outTab end
  if depthInt and depthInt <= 1 then return outTab end
  return flatarray( outTab, depthInt and depthInt-1 )
end

return flatarray
