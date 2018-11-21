--[===[DOC

= hexencode

[source,lua]
----
function hexencode( inputStr ) --> binStr
----

This function will return the hexadecimal rapresentation `binStr` of the data
passed as the input string `inputStr`. The input is interpreted as binary data,
whyle the output will be a string composed by an even sequence of digit or
upper case
letters from 'A' to 'F'. Each pair represent a subsequent byte in the input
string.

== Example

[source,lua,example]
----
local hexencode = require 'hexencode'

assert( hexencode '\x10\xBA' == '10BA' )

----

]===]

local function hexencode( dataStr ) --> hexStr
  return dataStr:gsub( ".", function( c )
    return string.format( "%02X", string.byte( c ))
  end)
end

return hexencode
