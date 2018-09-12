--[===[DOC

= intersecationtab

[source,lua]
----
function intersecationtab( firstTab, secondTab, selectFunc ) --> intersecationTab
----

Creates the `intersecationTab` table that contain the keys shared by the
`firstTab` and `secondTab` tables. By default, the value of the first table
will be used as value in the result.

The `selectFunc` function may be optionally passed to select which value to
associate to the key.  It will be called with the two value associated to the
same key in the two argument table.  Its result will be used in the
intersecation table.

]===]

local function intersecationtab( firstTab, secondTab, selectFunc ) --> intersecationTab
  local intersecationTab = {}
  if not firstTab or not secondTab then return intersecationTab end
  for k, v in pairs(firstTab) do
    local o = secondTab[k]
    if o then
      if not selectFunc then
        intersecationTab[k] = v
      else
        intersecationTab[k] = selectFunc(v, o)
      end
    end
  end
  return intersecationTab
end

return intersecationtab