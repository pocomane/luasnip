--[===[DOC

= csvish

[source,lua]
----
function csvish( csvStr ) --> datTab
----

This is a very simple parser for a Comma Separed Value (CSV) file format. The
record separator is the newline, while the field separator is the semicolon. A
field containing a separators can be quoted with the double quote. The double
quote itself can be escaped with `""`.

It takes the `csvStr` string containing the CSV data, and it return the table
`datTab` containing the same data as an array. Each item represents a CSV
record. The item is an array by itself containing the fields as a string.


== Example

[source,lua,example]
----
local csvish = require 'csvish'

local data = csvish [[
a;b;c
d;;e;f;
"g;\""
]]

assert( data[1][1] == 'a' )
assert( data[1][2] == 'b' )
assert( data[1][3] == 'c' )
assert( data[1][4] == nil )
assert( data[2][1] == 'd' )
assert( data[2][2] == '' )
assert( data[2][3] == 'e' )
assert( data[2][4] == 'f' )
assert( data[3][1] == 'g;\\"' )
assert( data[3][2] == nil )

----

]===]

local function string_char_to_decimal( c )
  return string.format( '\\%d', c:byte( 1,1 ))
end

local function string_decimal_to_char( d )
  return string.char( tonumber( d ))
end

local function csvish( csv )

  -- Protect quoted text
  local csv = csv:gsub('"(.-)"', function( quote )
    if quote == '' then return string_char_to_decimal( '"' ) end
    return quote:gsub('[\\\n\r;"]', string_char_to_decimal )
  end)

  local result = {}

  -- Loop over records and fields
  for line in csv:gmatch('([^\n\r]*)') do
    local record
    for field in line:gmatch('([^;]*)') do

      -- New record as needed
      if not record then
        record = {}
        result[1+#result] = record
      end

      -- Expand quoted/protected text
      field = field:gsub('\\(%d%d?%d?)', string_decimal_to_char)

      -- Append the new field
      record[1+#record] = field
    end
  end

  return result
end

return csvish
