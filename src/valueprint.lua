--[===[DOC

= valueprint

[source,lua]
----
function valueprint( value [, formatFunc] ) --> str
----

It return `str` an human readable representation of the input value `value`.
If the value is a function or user data it return a reference. If it is a
non-aggregated lua type, the returned string contains just a lua literal
representing the value.

If the value is a table, it is expanded as a list of key/value pairs. If a
table is found as key, the reference only is printed. If the value contained in
the key is an already printed table, the reference only is printed. If the
value contains a new table, the key/value pairs are recursively printed.

These limitations are needed in order to avoid issues with loops or with hard
to read results. This function is ment only for human inspection: for an
accurate table dump, see the `serialize` module.

The optional `formatFunc` value can be used to change the default table output
style.  If the string "lua" is passed, a lua-parsable literal will be emitted.
If It is a function, it will called for each key/value pair. It will be also
called when a entering or quitting a sub-table. The result of the function must
be a string that will be appended to the final result.

When called on key/value pair the `formatFunc` will get the following
arguments:

- A string representing the key
- A string representing the content
- A depth index
- An info string i.e. the type of the content

When called on the entering/quitting of a sub-table, the key will be nil and
the info string will be the string 'in' or 'out'.

]===]

local function print_basic( cur )
  if "string" == type( cur ) then
    return string.format( "%q", cur ):gsub( '\n', 'n' )
  else
    return tostring( cur ):gsub( ':', '' )
  end
end

local function print_record( key, value, depth, info )
  return (key and '\n'..('| '):rep(depth)..key..': '..value)
    or (depth == 1 and info == 'in' and value) or ''
end

local function print_record_lua( k, v, d, i )
  local y = ''
  if not k then
    if i == 'in' then
      y = '{ --[[' .. v .. ']]\n'
    elseif i == 'out' then
      y = ((' '):rep(d)) .. '},\n'
    end
  else
    if k ~= 'true' and k ~= 'false' and not tonumber(k) and k:sub(1,1) ~= '"' then
      k = '"'..k..'"'
    end
    y = y .. ((' '):rep(d+1)) .. '[' .. k .. '] = '
    if i ~= 'table' then
      y = y .. v .. ',\n'
    end
  end
  return y
end

local function valueprint( value, format ) --> str

  local memo = {}
  if format == 'default' then format = print_record end
  if format == 'lua' then format = print_record_lua end
  if 'function' ~= type(format) then format = print_record end

  local function valueprint_rec( cur, depth )

    -- Flat type pr already processed table
    if "table" ~= type(cur)then
      return print_basic( cur )
    end 
    if memo[cur] then return '' end
    memo[cur] = true

    local subtab = {}

    -- Start table iteration
    table.insert( subtab, format( nil, print_basic( cur ), depth, 'in'))

    -- Recurse over each key and each value
    for k, v in pairs( cur ) do
      k = print_basic( k )
      local vs = print_basic( v )
      table.insert( subtab, format( k, vs, depth, type( v )) or '' )
      if 'table' == type(v) then
        table.insert( subtab, valueprint_rec( v, depth+1 ) or '')
      end
    end

    -- End table iteration
    table.insert( subtab, format( nil, print_basic( cur ), depth, 'out'))

    return table.concat( subtab )
  end
  return valueprint_rec( value, 1 )
end

return valueprint
