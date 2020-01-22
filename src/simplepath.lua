--[===[DOC

= simplepath

[source,lua]
----
function simplepath( pathIn ) --> pathOut
----

Simplify the path contained in the string 'pathIn'. It return a
simpler string 'pathOut' with the following expansion

- . means 'last directory', so it is just removed
- .. means 'parent directory', so it will remove the previous directory (unless
  it is at beginning of the path)

== Example

[source,lua,example]
----
local simplepath = require 'simplepath'

local sps = function(x) return x:gsub("/", package.config:sub(1,1)) end

assert( simplepath(sps'A/B/./C/../D') == sps'A/B/D' )

----

]===]

local dirsep = package.config:sub(1,1)
local splitpat = '[^'..dirsep..']+'

local function simplepath( pathIn ) --> pathOut, errorStr
  local result = {}
  for part in pathIn:gmatch( splitpat ) do
    if part ~= '.' then
      if part ~= '..' then
        table.insert( result, part )
      else
        local nres = #result
        if nres > 0 and result[nres] ~= '..' then
          result[nres] = nil
        else
          table.insert( result, '..' )
        end
      end
    end
  end
  local pathOut = table.concat( result, dirsep )
  if pathIn:sub(1,1) == dirsep then pathOut = dirsep..pathOut end
  if pathOut == '' then
    pathOut = '.'
  end
  return pathOut
end

return simplepath
