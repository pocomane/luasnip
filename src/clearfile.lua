--[===[DOC

= clearfile

[source,lua]
----
function clearfile( pathStr ) --> statusBool, errorStr
----

Create a empty file at path specified by the `pathStr` string. If the file
exists its content will be deleted.

It will return `true` if the file is created/cleared correctly. Nil otherwise,
with the additional error string `errorStr`.

]===]

local function clearfile( pathStr ) --> statusBool, errorStr
  local f, err = io.open( pathStr, 'wb' )
  if not f or err then return nil, err end
  local s, err = f:write( '' )
  f:close()
  if not s then return nil, err end
  return true
end

return clearfile
