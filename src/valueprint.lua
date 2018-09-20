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
style.  It will be called one time for each key/value pair and should give a
string result accepting three argument: key, value and depth. This function is
also called with the root value if it is a table. In this case the key is `nil`
and the value is the reference string of the table.

]===]

local function print_basic( cur )
  if "string" == type( cur ) then
    return string.format( "%q", cur ):gsub( '\n', '10' )
  else
    return tostring( cur ):gsub( ':', '' )
  end
end

local function print_record( key, value, depth )
  return not key and value or '\n'..('| '):rep(depth)..key..': '..value
end

local function valueprint( value, format ) --> str

  local memo = {}
  if 'function' ~= type(format) then format = print_record end

  local function valueprint_rec( cur, depth )

    -- Flat type pr already processed table
    if "table" ~= type(cur)then
      return print_basic( cur )
    end 
    if memo[cur] then return '' end
    memo[cur] = true

    -- First table iteration
    local subtab = {}
    if depth == 0 then
      table.insert( subtab, format( nil, print_basic( value ), 0 ))
      depth = 1
    end

    -- Recurse over each key and each value
    for k, v in pairs( cur ) do
      k = print_basic( k )
      local vs = print_basic( v )
      table.insert( subtab, format( k, vs, depth ) or '' )
      if 'table' == type(v) then
        table.insert( subtab, valueprint_rec( v, depth+1 ) or '')
      end
    end

    return table.concat( subtab )
  end
  return valueprint_rec( value, 0 )
end

return valueprint
