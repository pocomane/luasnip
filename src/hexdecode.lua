--[===[DOC

= hexdecode

[source,lua]
----
function hexdecode( inputStr ) --> hexStr
----

This function will encode an ASCII Hexadecimal string `inputStr` into a binary
sequence.

The input string must be composed of a sequence of digit or upper case letters
from 'A' to 'F'.

For each two bytes in the input, a byte of the output `hexStr` string is
generated.

]===]

local function hexdecode( hexStr ) --> dataStr
  return hexStr:gsub( "..?", function( h )
    return string.char(tonumber(h, 16))
  end)
end

return hexdecode