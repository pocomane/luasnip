--[===[DOC

= rawmark

[source,lua]
----
function rawmark( dataStr ) --> parsedTab 
----

This function implement a raw markup language. It take an input `dataStr`
string and generate the `parsedTab` table representation of it. The format of the
input strigs is based on the following core expansion:

`@type{data}`::
Where `type` is the only metadata that can be added and `data` is the content.
If `type` is not present, the default `default` will be used.  The type can be
any sequence of letters, numbers and any of '_+-.,/=%'. The content can
be any string. In the content the `@{}` is recursively expanded.

Moreover, the escape sequence `{x}`, is replaced with `x`, where `x` is any
single byte character. The only exceptions are:

- `{=}` is expanded to `@`
- `{+}` is expanded to `{`
- `{-}` is expanded to `}`

However, `{+}` and `{-}` are just needed to insert unbalanced `{` and `}`,
otherwise `{=}` is enough to escape mark tags.

The function will return a table with the only string key `type` containing
`default`. All the other keys form a sequence of natural number from 1 to N. To
each key is associated the string value for a verbatim content, or a sub-table
in case of `@{}` sub-expansion. This sub-table is contructed at same way with
the `type` field set to the metatada in the tag, or `default` if not present.

For example the string

[source]
------------
aaa@bbb{ccc}
------------

will be expanded to the lua table

[source,lua]
------------
{ type='default', 'aaa', {type='bbb', 'ccc'} }
------------

== Example

[source,lua,example]
----
local rawmark = require 'rawmark'

local data = rawmark '@M{@{a}} b @X{ @{c} }'

assert( data.type == 'default' )

assert( data[1].type == 'M' )
assert( data[1][1].type == 'default' )
assert( data[1][1].type == 'default' )
assert( data[1][1][1] == 'a' )

assert( data[2] == ' b ' )

assert( data[3].type == 'X' )

assert( data[3][1] == ' ' )
assert( data[3][2].type == 'default' )
assert( data[3][2][1] == 'c' )
assert( data[3][3] == ' ' )
----

]===]

local function rawmark(str, typ)
  if not typ or typ == '' then typ = 'default' end
  local result = {type = typ}

  if str == '' then
    result[1+#result] = str
    return result
  end

  local cur = str
  while cur and cur ~= '' do
    -- Split verbatim and container parts
    -- local ver, exp, res, typ = cur:match('^(.-)@(%b{})(.*)$')
    local ver, typ, exp, res = cur:match('^(.-)@([A-Za-z0-9_/=,%.%-%+%%]*)(%b{})(.*)$')
    if not ver then ver = cur end

    -- Substitute escape sequences
    ver = ver:gsub('{(.)}', function(c)
      local escape = ({ ['+']='{', ['-']='}', ['=']='@' }) [c]
      return escape or c
    end)

    if ver and ver ~= '' then result[1+#result] = ver end
    if exp then result[1+#result] = rawmark(exp:sub(2,-2), typ) end

    cur = res
  end

  return result
end

return rawmark
