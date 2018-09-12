--[===[DOC

= deepsame

[source,lua]
----
function deepsame( firstTab, secondTab ) --> sameBool
----

Deep comparison of the two tables `firstTab` and `secondTab`. It will return
`true` if they contain recursively the same data, otherwise `false`.

]===]

local deepsame

local function keycheck( k, t, s )
  local r = t[k]
  if r ~= nil then return r end
  if 'table' ~= type(k) then return nil end
  for tk, tv in pairs( t ) do
    if deepsame( k, tk, s ) then
      r = tv
      break
    end
  end
  return r
end

function deepsame( a, b, s )
  if not s then s = {} end
  if a == b then return true end
  if 'table' ~= type( a ) then return false end
  if 'table' ~= type( b ) then return false end

  if s[ a ] == b or s[ b ] == a then return true end
  s[ a ] = b
  s[ b ] = a

  for ak, av in pairs( a ) do
    local o = keycheck( ak, b, s )
    if o == nil then return false end
  end

  for bk, bv in pairs( b ) do
    local o = keycheck( bk, a, s )
    if o == nil then return false end

    if not deepsame( bv, o, s ) then return false end
  end

  s[ a ] = nil
  s[ b ] = nil
  return true
end

return deepsame