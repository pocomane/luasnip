--[===[DOC

= cliparse

[source,lua]
----
function cliparse( argArr [, defaultStr] ) --> parsedTab
----

Simple function to parse command line arguments, that must be passed as the array
of string `arrArg`.

All the arguments are collected in the output `parsedTab`. Each flag or option
became a key of the table, while some arguments may be collected as values.
Three type of arguments are supported:

- `-aBc` - Will generate a key for each character (e.g. 'a') with an
empty-table value.
- `--key` - a key will be generate with the whole identifier (e.g. 'key') and
an empty table is used as value; if the next argument does not start with '-'
it will be appended in the table.
- `--key=value`, `--key:value`, `-key=value` or `-key:value` - will generate a
key with the suffix (e.g. 'key'); a table
will be generated as value, containing the found suffix (e.g. 'value').
  
For the last two forms, if the same key is found more time, each value is
appended into the table.

All the arguments not associated to any key, will be collected under the
default empty string (i.e. ''). The additional argument string `defaultStr` can
be used to override this default.

]===]

local function addvalue( p, k, value )
  local prev = p[k]
  if not prev then prev = {} end
  if 'table' ~= type(value) then
    prev[1+#prev] = value
  else
    for v = 1, #value do
      prev[1+#prev] = value[v]
    end
  end
  p[k] = prev
end

local function cliparse( args, default_option )

  if not args then args = {} end
  if not default_option then default_option = '' end
  local result = {}

  local append = default_option
  for _, arg in ipairs(args) do
    if 'string' == type( arg ) then
      local done = false

      -- CLI: --key=value, --key:value, -key=value, -key:value
      if not done then
        local key, value = arg:match('^%-%-?([^-][^ \t\n\r=:]*)[=:]([^ \t\n\r]*)$')
        if key and value then
          done = true 
          addvalue(result, key, value)
        end
      end
    
      -- CLI: --key
      if not done then
        local keyonly = arg:match('^%-%-([^-][^ \t\n\r=:]*)$')
        if keyonly then
          done = true
          if not result[keyonly] then
            addvalue(result, keyonly, {})
          end
          append = keyonly
        end
      end

      -- CLI: -kKj
      if not done then
        local flags = arg:match('^%-([^-][^ \t\n\r=:]*)$')
        if flags then
          done = true
          for i = 1, #flags do
            local key = flags:sub(i,i)
            addvalue(result, key, {})
          end
        end
      end

      -- CLI: value
      if not done then
        addvalue(result, append, arg)
        append = default_option
      end
    end
  end

  return result
end

return cliparse