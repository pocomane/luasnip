--[===[DOC

= clone

[source,lua]
----
function clone( sourceTab, depthNum ) --> clonedTab
----

This function will return the `clonedTab` table, that is a duplicate of the
`sourceTab` table. The duplicated table is a different one but it has the same
content. Any contained table will be recursively duplicated, both if it is a
key or a value.

The optional `depthNum` number defines the depth level at which the sub-tables
must be duplicated. Deeper tables are copied by reference. If it is 0, the
original table will be returned. If it is 1, any sub-table are copied by
reference. When nil all the sub-tables, at any levels, will be duplicated.

]===]

local function shallow_copy( depth, cloned, toclone )
  local source = toclone[#toclone]
  if not source then return end
  toclone[#toclone]=nil

  local root = cloned[ source ]
  if not root then
    root = {}
    cloned[ source ] = root

    for k, v in pairs( source ) do
      root[k] = v

      if not depth or depth > 1 then
        if type(k) == 'table' then
          toclone[1+#toclone] = k
        end

        if type(v) == 'table' then
          toclone[1+#toclone] = v
        end
      end
    end

    return shallow_copy( depth and depth-1, cloned, toclone )
  end
end

local function link_clones( cloned )
  for _, tolink in pairs(cloned) do

    local K, V = {}, {}
    for k, v in pairs( tolink ) do
      local newk = cloned[k]
      local newv = cloned[v]

      if newk then
         tolink[k] = nil

        -- Note: New key adding is postponed since it is forbidden
        -- during iteration
        K[#K+1] = newk or k
        V[#V+1] = newv or v

      elseif newv then
        tolink[k] = newv
      end
    end

    for i = 1, #K do
      tolink[K[i]] = V[i]
    end
  end
end

local function clone( sourceTab, depthNum )
  if depthNum == 0 then return sourceTab end
  if depthNum and depthNum < 1 then return sourceTab end
  local toclone = {sourceTab}
  local cloned = {}
  shallow_copy( depthNum, cloned, toclone )
  link_clones( cloned )
  return cloned[sourceTab]
end

return clone
