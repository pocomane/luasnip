--[===[DOC

= filenamesplit

[source,lua]
----
function filenamesplit( filepathStr ) --> pathStr, nameStr, extStr
----

Split a file path string `filepathStr` into the following strings: the folder
path `pathStr`, filename `nameStr` and extension `extStr`.

Note that `pathStr` contains the trailing separator, and the `extStr` contains
the dot prefix. In this way you can get the original string cocatenating the
three results.

The valid path separators in the string are '/' and '\'.

== Example

[source,lua,example]
----
local filenamesplit = require 'filenamesplit'

local a, b, c = filenamesplit'/path/path/name.ext'

assert( a == '/path/path/' )
assert( b == 'name' )
assert( c == '.ext' )

----


]===]

local function filenamesplit( str ) --> pathStr, nameStr, extStr
  if not str then str = '' end
  
  local pathStr, rest = str:match('^(.*[/\\])(.-)$')
  if not pathStr then
    pathStr = ''
    rest = str
  end

  if not rest then return pathStr, '', '' end

  local nameStr, extStr = rest:match('^(.*)(%..-)$')
  if not nameStr then
    nameStr = rest
    extStr = ''
  end

  return pathStr, nameStr, extStr
end

return filenamesplit
