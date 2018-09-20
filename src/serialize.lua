--[===[DOC

= serialize

[source,lua]
----
function serialize( value, outfunc ) --> str
----

It serializes the lua value `value`.  The resulting `str` string can be parsed
by the common Lua _load_/_loadstring_ function to restore the original value.
It have not the Lua literal limitation for tables, as the one found in the
_lualiteral_ function.  So it can handle tables with cycles or with a nest
level higher than the max defined for the Lua literals (200).  It still can not
handle _userdata_ and _lightuserdata_.

If `outfunc` is passed, then nothing is returned. Instead `outfunc` will be
called multiple times with a single string parameter: a chunk of the serialized
data. They can be, for example, saved in a file one afther the other; the
resulting file can be read the common lua _load_/_loadstring_ function

]===]

local type = type

local function basic_representation( value, outfunc )
  local tv = type(value)
  if "string" == tv then
    outfunc(string.format( "%q", value ))
    return true
  elseif "table" ~= tv then
    outfunc(tostring( value ))
    return true
  end
  return false
end

local function serialize( value, outfunc ) --> str

  -- Default ouput function
  local result
  if not outfunc then
    result = {}
    outfunc = function(dat) result[1+#result]=dat end
  end

  -- Basic/Flat type
  if basic_representation( value, outfunc ) then
    return result and table.concat(result) or nil
  end

  outfunc('((function() local T=\n{')

  -- Table memo
  local reference = { value }
  local alias = { [value] = 'r' }
  local function add_reference( tab )
    if not alias[tab] then
      reference[1+#reference]=tab
      alias[tab] = 'T[' .. #reference .. ']'
    end
  end

  -- Loop over all the tables
  local t = 0
  while true do
    t = t + 1
    local tab = reference[t]
    if tab == nil then break end
    if type(tab)=='table'then

      outfunc('{')

      -- Expand basic type or placeholder for the Array part
      local already_seen = {}
      for k, v in ipairs( tab ) do
        if type(v) == 'table' then
          add_reference( v )
          outfunc('0,') -- Placeholder, it will be replaced
        else
          basic_representation( v, outfunc )
          outfunc(',')
        end
        already_seen[k] = true
      end

      for k, v in pairs( tab ) do
        if not already_seen[k] then

          -- Mark for placeholder/nested expansion
          local skip_expansion = false
          if type(k) == 'table' then
            add_reference( k )
            skip_expansion = true
          end
          if type(v) == 'table' then
            add_reference( v )
            skip_expansion = true
          end

          -- Expand basic type for the Hash part
          if not skip_expansion then
            outfunc('[')
            basic_representation( k, outfunc )
            outfunc(']=')
            basic_representation( v, outfunc )
            outfunc(',')
          end
        end
      end

      outfunc('},')
    end
  end
  
  outfunc('}')
  outfunc('\nlocal r=T[1]')

  -- Override placeholders and nested table references
  for _, tab in ipairs(reference) do
    for k, v in pairs(tab) do
      local table_key = (type(k) == 'table')
      local table_value = (type(v) == 'table')
      if table_key or table_value then
        outfunc('\n')
        outfunc(alias[tab])
        outfunc('[')
        if table_key then
          outfunc(alias[k])
        else
          basic_representation( k, outfunc )
        end
        outfunc(']=')
        if table_value then
          outfunc(alias[v])
        else
          basic_representation( v, outfunc )
        end
      end
    end
  end

  outfunc('\nreturn r end)())')

  return result and table.concat(result) or nil
end

return serialize
