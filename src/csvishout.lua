--[===[DOC

= csvishout

[source,lua]
----
function csvishout( datTab[, outFunc] ) --> csvStr
----

Generate the Comma Separed Value (CSV) rapresentation `csvStr` of the input array
`datTab`. The ouput will be CSV string containing a list record. Each record is
itself a list of fields. The record separator is the newline while the field
separator is the semicolon.

If a field contains a newlines ora a semicolons, it will be quoted with double
quote (`"`). The double quote itself will be escaped with the sequence
`""`.

If an `outFunc` is passed, it is called on each output row. It this case the
returned value will be always nil.

]===]

local function csvishout( tab, outFunc )
  local result = ''
  for _, record in ipairs(tab) do
    if 'table' == type(record) then
      local first = true
      for _, field in ipairs(record) do
        if not first then result = result .. ';' end
        first = false
        field = tostring(field)
        if field:match('[;\n"]') then
          field = field:gsub('"','""')
          field = '"' .. field .. '"'
        end
        result = result .. field
      end
      result = result .. '\n'
      if outFunc then
        outFunc(result)
        result = ''
      end
    end
  end
  if outFunc then return nil end
  return result
end

return csvishout
