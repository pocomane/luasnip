--[===[DOC

= rawmark

[source,lua]
----
function rawmark( dataStr ) --> parsedTab 
----

This function implement a raw markup language. It take an input `dataStr`
string and generate the `parsedTab` table representation of it. The format of the
input strigs is based on the following core expansion:

`{type:data}`::
Where `type` is the only metadata that can be added and `data` is the content.
If `type` is not present, the empty string will be used as default.  The type
can contain any character except `:`, `{` and `}`. The data can be any string,
also the empty one.  In the data the `{}` is recursively expanded.

The `:` can be omitted: the sequences like `{abc}` are equivalent to `{:abc}`.

The following exact sequences are substituted:

- `{=}` is expanded to `:`
- `{+}` is expanded to `{`
- `{-}` is expanded to `}`

Note that the sequences like `{:=}` are expanded as usual, i.e. a sub-tag with
the default type and containing only `=`.

The function will return a table with the only string key `type` containing
``. All the other keys form a sequence of natural number from 1 to N. To each
key is associated the string value for a verbatim content, or a sub-table in
case of `{}` sub-expansion. This sub-table is contructed at same way with the
`type` field set to the metatada in the tag, or `default` if not present.

For example the string `aaa{bbb:ccc}` will be expanded to the lua table `{
type='', 'aaa', {type='bbb', 'ccc'} }`.

== Example

[source,lua,example]
----
local rawmark = require 'rawmark'

local data = rawmark '{M:{a}} b {X: {c} }'

assert( data.type == '' )

assert( data[1].type == 'M' )
assert( data[1][1].type == '' )
assert( data[1][1].type == '' )
assert( data[1][1][1] == 'a' )

assert( data[2] == ' b ' )

assert( data[3].type == 'X' )

assert( data[3][1] == ' ' )
assert( data[3][2].type == '' )
assert( data[3][2][1] == 'c' )
assert( data[3][3] == ' ' )
----

]===]

local function rawmark( str, typ )

  -- Special cases
  typ = typ or ''
  if str == '' then return { str, type = typ } end

  local result, merge = { type = typ }, false
  while str and str ~= '' do

    -- Split verbatim and container parts
    local ver, exp, rest = str:match('^(.-)(%b{})(.*)$')
    if ver == nil then ver = str end
    str = rest -- Prepare next iteration

    -- Append verbatim prefix
    if ver and ver ~= '' then result[1+#result] = ver end

    -- Handle escape sequences
    local sub = exp and ({ ['{+}']='{', ['{-}']='}', ['{=}']=':' })[exp]
    if sub then
      merge = true
      result[1+#result] = sub
      exp = nil
    end

    -- Parse tag
    if exp and exp ~= '' then
      local typ, col, exp = exp:match('^{([^:]*)(:?)(.*)}$')
      if col == '' then exp, typ = typ, '' end
      result[1+#result] = rawmark( exp, typ )
    end
  end

  return result
end

return rawmark
