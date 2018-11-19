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

]===]

local function json_to_table_literal(s)
  s = s:gsub("\\[uU](%x%x%x%x)","\\u{%1}")
  s = s:gsub('("[^"]*")', function(a)
    return a:gsub('[%[%]]', function (b)
      return string.format('\\u{%x}', b:byte())
    end)
  end)
  s = s:gsub('%[','{')
  s = s:gsub('%]','}')
  s = s:gsub('("[%w_-]-"):','[%1]=')
  return s
end

local function json_to_table(s)
  local loader, e =
    load('return '..json_to_table_literal(s), 'jsondata', 't', {})
  if not loader or e then return nil, e end
  local dataTab, e = loader()
  if not dataTab or e then return nil, e end
  return dataTab
end

return json_to_table
