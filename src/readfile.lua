--[===[DOC

= readfile

[source,lua]
----
local function readfile( pathStr, optStr ) --> readTabStr
local function readfile( pathStr, optStr ) --> nil, errorStr
----

Read the file specified by the path string `pathStr`. Several read option may
be provided. If the read results in a single chunk, a string is returned. If
multiple chunks are avaiable, an array of string is returned.

The avaiable read option string `optStr` are the same of the lua standard
`io.read` function: for example the `l` option can be used to read each line
separately, and to store it as an item of the returned array.

In case of error, `nil` plus an error message string `errorStr` is returned.

== Example

[source,lua,example]
----
local readfile = require 'readfile'

local f = io.open('tmp.txt', 'wb')
f:write("1 1.2 -1e3\naaa")
f:close()

assert( readfile('tmp.txt') == "1 1.2 -1e3\naaa" )

local data = readfile('tmp.txt', 'l')
assert( data[1] == "1 1.2 -1e3" )
assert( data[2] == "aaa" )

local data = readfile('tmp.txt', 'n')
assert( data[1] == 1 )
assert( data[2] == 1.2 )
assert( data[3] == -1e3 )
----

]===]

local function readfile( pathStr, optStr ) --> readTabStr
  local f, err = io.open( pathStr, 'rb' )
  if not f or err then return f, err end
  if not optStr then optStr = 'a' end
  local readTabStr = {}
  while true do
    local p = f:seek()
    local r, err = f:read( optStr )
    if err then return nil, err end
    if p == f:seek() then break end
    if r and r ~= '' then
      readTabStr[1+#readTabStr] = r
    end
  end
  if #readTabStr == 0 then return '' end
  if #readTabStr == 1 then return readTabStr[1] end
  return readTabStr
end

return readfile
