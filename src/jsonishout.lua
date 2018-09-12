--[===[DOC

= jsonishout

[source,lua]
----
function jsonishout( inputValue ) --> jsonStr
----

Generate the JSON-like string `jsonStr` from the lua value `inputValue`. Only
number or string keys are allowed in a table value. The value can be a table
itself; any other value will be converted to string.

If a table value contains only number key, a JSON array will be generated. If
it contains only string key a JSON object will be generated istead. Empty table
or mix table will produce an array.

Any table that has a metatable will always generate a JSON object, so you can
use an empty table with an empty metatable to generate an empty JSON obkec.
This access the tables with common lua `[]` operator, so metatable can be used
to hook into the generator behaviour.

]===]

local function quote_json_string(str)
  return '"'
    .. str:gsub('(["\\%c])',
      function(c)
        return string.format('\\x%02X', c:byte()) 
      end)
    .. '"'
end

local table_to_json

local function table_to_json_rec(result, t)

  if 'number' == type(t) then
    result[1+#result] = tostring(t)
    return
  end

  if 'table' ~= type(t) then
    result[1+#result] = quote_json_string(tostring(t))
    return
  end

  local isarray = false
  if not getmetatable(t) then
    local hasindex, haskey = false, false
    for _ in ipairs(t) do hasindex = true break end
    for _ in pairs(t) do haskey = true break end
    isarray = hasindex or not haskey
  end

  if isarray then
    result[1+#result] = '['
    local first = true
    for _,v in ipairs(t) do
      if not first then result[1+#result] = ',' end
      first = false
      table_to_json_rec(result, v)
    end
    result[1+#result] = ']'

  else
    result[1+#result] = '{'
    local first = true
    for k,v in pairs(t) do

      if 'number' ~= type(k) or 0 ~= math.fmod(k) then -- skip integer keys
        k = tostring(k)
        if not first then result[1+#result] = ',' end
        first = false
      
        -- Key
        result[1+#result] = quote_json_string(k)
        result[1+#result] = ':'

        -- Value
        table_to_json_rec(result, v)
      end
    end

    result[1+#result] = '}'
  end
end

table_to_json = function(t)
  local result = {}
  table_to_json_rec(result, t)
  return table.concat(result)
end

return table_to_json