--[===[DOC

= jsonish

[source,lua]
----
function jsonish( jsonStr ) --> dataTab
----

This function parses the json-like string `jsonStr` to the lua table `dataTab`.
It does not perform any validation. The parser is not fully JSON compliant,
however it is very simple and it should work in most the cases.

This function internally works by trasforming the string into a valid lua table
literal. For this reasons it accept also some syntax that is not actually valid
JSON, e.g. mixed array/hash syntax: `{1, "a":"b"}.

== Example

[source,lua,example]
----
local jsonish = require 'jsonish'

local data = jsonish '{ "a":{"hello":"world"}, "b":[99,100,101]}'

assert( data.a.hello == "world" )
assert( data.b[1] == 99 )
assert( data.b[2] == 100 )
assert( data.b[3] == 101 )
----

]===]

local function json_to_table_literal(s)

  s = s:gsub([[\\]],[[\u{5C}]])
  s = (' '..s):gsub('([^\\])(".-[^\\]")', function( prefix, quoted )
    -- Matched string: quoted, non empty

    quoted = quoted:gsub('\\"','\\u{22}')
    quoted = quoted:gsub('\\[uU](%x%x%x%x)', '\\u{%1}')
    quoted = quoted:gsub('%[','\\u{5B}')
    quoted = quoted:gsub('%]','\\u{5D}')
    return prefix .. quoted
  end)

  s = s:gsub('%[','{')
  s = s:gsub('%]','}')
  s = s:gsub('("[^"]-")%s*:','[%1]=')

  return s
end

local function json_to_table(s)
  local loader, e =
    load('return '..json_to_table_literal(s), 'jsondata', 't', {})
  if not loader or e then return nil, e end
  return loader()
end

return json_to_table
