--[===[DOC

= pathpart

[source,lua]
----
function pathpart( pathIn ) --> pathOut, errorStr
----

Convert between two path representation: the string one, and the array of
strings one. `pathIn` may be any of them: the other will be generated as
`pathOut`.  In case of error, `nil` plus the `errorStr` string is returned
instead.

While converting from string, any of the following path separator is valid:
'\', '.'.

While converting from array of string, the path separator from `package.config`
is used.

The strings in the array representation do not contain any path separator: each
array entry correspond to a single path step, and contains exactly the folder
name.

]===]

local path_separator = package.config:sub(1,1)

local function path_merge( pathTab )
  return table.concat( pathTab, path_separator )
end

local function path_split( pathStr )
  local result = {}
  for c in pathStr:gmatch( '[^/\\]*' ) do
    if c ~= '' then
      result[1+#result] = c
    end
  end
  return result
end

local function pathpart( pathIn ) --> pathOut, errorStr
  local t = type(pathIn)
  if 'table' == t then return path_merge( pathIn )
  elseif 'string' == t then return path_split( pathIn )
  else return nil, 'Invalid input type'
  end
end

return pathpart