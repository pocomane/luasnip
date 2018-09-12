--[===[DOC

= toposort

[source,lua]
----
function toposort( dependenceTab ) --> orderArr
----

Topological sort the `dependenceTab` table. It returns the `orderArr` array
containing the all the items sorted with respect to the input dependencies.

Each key of `dependeceTab` is an item to sort. The value associated to each of
them must be an array containing the dependency of the item.

]===]

local pairs, ipairs = pairs, ipairs

local function toposort( depTab ) --> orderArr
  depTab = depTab or {}
  local status, orderArr, tovisit, o, n = {}, {}, {}, 0, 0
  for node in pairs( depTab ) do
    local stat = status[node]
    if not stat then
      n = n + 1
      tovisit[n] = node
      repeat
        local dlist = not stat and depTab[node]
        if dlist then
          for _, depend in ipairs(dlist) do
            local dstat = status[depend]
            if not dstat then -- just an optimization
              n = n + 1
              tovisit[n] = depend
            elseif dstat == 'seen' then -- seen but not pushed -> cycle detected
              return nil, 'cycle detected', orderArr
            end
          end 
        else
          if stat ~= 'pushed' then
            o = o + 1
            orderArr[o] = node
          end
          tovisit[n] = nil
          n = n - 1
          status[node] = 'pushed'
        end
        status[node] = status[node] or 'seen'
        node = tovisit[n]
        stat = status[node]
      until n <= 0
  end end
  return orderArr
end

return toposort