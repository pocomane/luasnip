--[===[DOC

= lineposition

[source,lua]
----
function lineposition( str, byteNum ) --> columnNum, lineNum
function lineposition( str, columnNum, lineNum ) --> byteNum
----

This function translate to/from the following representation of a position in a
string:

- Byte count from the beginning
- Column and line count

It behaves differently based on the number of arguments.

When the `str` string and a single `byteNum` integer are passed, it will
interpret the number as a byte offset in the string. The column and line are
returned.

When `str` is passed with both `columnNum` and `lineNum`, the opposite
transformation is perfomed.

== Example

[source,lua,example]
----
local lineposition = require "lineposition"

local x, y = lineposition( "a\na", 3 )
assert( x == 1 )
assert( y == 2 )

local c = lineposition( "a\na", 1, 2 )
assert( c == 3 )

----

]===]

local select = select

local function lineposition( str, byteNum, ... ) --> columnNum | byteNum[, lineNum]

  local lineNum = select('#', ...) > 0 and select(1, ...)

  if lineNum then
    local columnNum = byteNum
    local pat = ( "[^\n]*\n" ):rep( lineNum -1 ) .. '()'
    local lineoff = str:match( pat )
    if lineoff then
      return lineoff -1 + columnNum
    end
    return nil

  else
    local columnNum = byteNum
    lineNum = 1

    for c in str:gmatch('\n()') do
      if c > byteNum then break end
      columnNum = 1 + byteNum - c
      lineNum = lineNum + 1
    end

    return columnNum, lineNum
  end
end

return lineposition
