--[===[ LuaSnip - License



]===]

local appendfile;
local argcheck;
local bitpad;
local clearfile;
local cliparse;
local combinetab;
local copyfile;
local countiter;
local csvish;
local csvishout;
local deepsame;
local differencetab;
local escapeshellarg;
local filenamesplit;
local flatarray;
local hexdecode;
local hexencode;
local intern;
local intersecationtab;
local iscallable;
local isreadable;
local jsonish;
local jsonishout;
local keysort;
local lambda;
local localbind;
local locktable;
local logline;
local pathpart;
local simplepath;
local rawhtml;
local rawmark;
local readfile;
local searchluakeyword;
local serialize;
local sha2;
local shellcommand;
local stepdebug;
local subbytebase;
local tapfail;
local taptest;
local templua;
local timeprof;
local toposort;
local trimstring;
local tuple;
local uniontab;
local valueprint;
local object;
local factory;
local measure;
local clone;
local datestd;
local lineposition;
local memo;
local peg;
local get;
local lzw;

appendfile = (function()


local function appendfile( path, data, prefix, suffix ) --> res, err

   local function writeorclose( f, data )
      local res, err = f:write( data )
      if err then f:close() end
      return res, err
   end

   local d, derr = io.open( path, "a+b" )
   if derr then
      return nil, "Can not create or open destination file. "..derr
   end

   local ok, err = d:seek( "end" )
   if err then
      d:close()
      return nil, err
   end

   if "string" == type( data ) then
      data = { data }
   end

   -- Output loop
   for i = 1, #data do

      if prefix then
         ok, err = writeorclose( d, prefix )
         if err then return ok, err end
      end

      ok, err = writeorclose( d, data[ i ] )
      if err then return ok, err end

      if suffix then
         ok, err = writeorclose( d, suffix )
         if err then return ok, err end
      end
   end

   return d:close()
end

return appendfile


end)()

argcheck = (function()


local function argcheck( specTab, ... ) --> wrapFunc
  local arg = table.pack(...)
  local argn = arg.n
  if #specTab ~= argn then error('Invalid number of arguments. Must be '.. #specTab..' not '.. argn ..'.', 3) end
  for a = 1, argn do
    local argtype, exptype = type(arg[a]), specTab[a] 
    if argtype ~= exptype then
      error('Invalid argument #'..a..' type. Must be '..exptype..' not '..argtype..'.', 2)
    end
  end
end

return argcheck


end)()

bitpad = (function()


local function bitpad( pad, bit, str, map, imap, off )
  if not bit then bit = 1 end
  if not pad then pad = 8 - (bit % 8) end
  local result = ''

  local removing = false
  if pad < 0 then
    pad = - pad
    removing = true
  end

  local out_count = 0
  local appending = false
  local procbit = pad
  if off then
    appending = true
    procbit = off
  end
  local store = 0
  local i = 0
  local inlast = 0
  local inbit = 0

  -- Bitloop
  while true do

    -- Get new input byte as needed
    if inbit <= 0 then
      i = i + 1
      inlast = str:byte(i)
      if not inlast then break end
      if imap then
        local x = imap[inlast+1]
        inlast = (x and x:byte()) or inlast
      end
      inbit = 8
    end

    -- Calculate number of appendable bits
    local appbit = procbit
    if appbit > inbit then appbit = inbit end
    if appbit + out_count > 8 then appbit = 8 - out_count end

    -- Make space into the output for the next bits
    if not removing or appending then
      store = (store << appbit) & 0xFF
      out_count = out_count + appbit
    end

    -- Copy the next bits from the input
    if appending then
      local mask = ((~0) << (8-appbit)) & 0xFF
      store = store | ((mask & inlast ) >> (8- appbit))
    end

    -- Discard from the input the bits that were already processed
    if removing or appending then
      inbit = inbit - appbit
      inlast = (inlast << appbit) & 0xFF
    end

    -- Select bit handle mode for the next iteration
    procbit = procbit - appbit
    if procbit <= 0 then
      if appending then
        appending = false
        procbit = pad
      else
        appending = true
        procbit = bit
      end
    end

    -- Generate output byte
    if out_count >= 8 then
        result = result .. (map and map[store+1] or string.char(store))
      store = 0
      out_count = 0
    end
  end

  -- Generate odd-bit byte
  local bitadd = 0
  if out_count > 0 then
    bitadd = 8 - out_count
    store = (store << bitadd) & 0xFF
    result = result .. (map and map[store+1] or string.char(store))
  end

  return result, bitadd
end

return bitpad


end)()

clearfile = (function()


local function clearfile( pathStr ) --> statusBool, errorStr
  local f, err = io.open( pathStr, 'wb' )
  if not f or err then return nil, err end
  local s, err = f:write( '' )
  f:close()
  if not s then return nil, err end
  return true
end

return clearfile


end)()

cliparse = (function()


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


end)()

combinetab = (function()


local function combinetab(...)
  local n = select('#',...)
  local f = select(n,...)
  n = n -1
  c = {}
  cc = 0
  for i=1,n do
    for k in pairs((select(i,...))) do
      if not c[k] then
        c[1+#c] = k
        cc = cc + 1
        c[k] = true
      end
    end
  end
  table.sort( c )
  local s = {}
  for i = 1,cc do s[i] = 1 end
  while s[cc] <= n do
    local a = {}
    for i = 1,cc do
      local k = c[i]
      a[k] = select(s[i],...)[k]
    end
    f(a)
    s[1] = s[1] + 1
    for i = 2,cc do -- carry
      if s[i-1] <= n then
        break
      else
        s[i-1] = 1
        s[i] = s[i] + 1
      end
    end
  end
end

return combinetab


end)()

copyfile = (function()


local function copyfile( src, dst ) --> ok, err

   local function checkerror( ... )
      local msg = ""
      for m = 1, select( "#", ... ) do
         local p = select( m, ... )
         if p ~= nil then
         msg = msg..p..". "
         end
      end
      if msg == "" then return true end
      return nil, msg
   end

   local s, serr = io.open( src, "rb" )
   if serr then
      return checkerror( "Can not open source file", serr )
   end
 
   local d, derr = io.open( dst, "wb" )
   if not d then
      s, serr = s:close()
      return checkerror( "Can not create destination file" , derr, serr )
   end

   -- Copy loop
   while true do
      buf, serr = s:read( 1024 )
      if serr or not buf then break end
      ok, derr = d:write( buf )
      if derr then break end
   end
   if serr or derr then
      return checkerror( "Error while copying", serr, derr )
   end

   s, serr = s:close()
   d, derr = d:close()
   return checkerror( serr, derr )
end

return copyfile


end)()

countiter = (function()


local function countiter( ... ) --> countInt
  local countInt = 0
  if select('#', ...) ~= 0 then
    for _ in ... do
      countInt = countInt + 1
    end
  end
  return countInt
end

return countiter


end)()

csvish = (function()


local function string_char_to_decimal( c )
  return string.format( '\\%d', c:byte( 1,1 ))
end

local function string_decimal_to_char( d )
  return string.char( tonumber( d ))
end

local function csvish( csv )

  -- Protect quoted text
  local csv = csv:gsub('"(.-)"', function( quote )
    if quote == '' then return string_char_to_decimal( '"' ) end
    return quote:gsub('[\\\n\r;"]', string_char_to_decimal )
  end)

  local result = {}

  -- Loop over records and fields
  for line in csv:gmatch('([^\n\r]*)') do
    local record
    for field in line:gmatch('([^;]*)') do

      -- New record as needed
      if not record then
        record = {}
        result[1+#result] = record
      end

      -- Expand quoted/protected text
      field = field:gsub('\\(%d%d?%d?)', string_decimal_to_char)

      -- Append the new field
      record[1+#record] = field
    end
  end

  return result
end

return csvish


end)()

csvishout = (function()


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


end)()

deepsame = (function()


local deepsame

local function keycheck( k, t, s )
  local r = t[k]
  if r ~= nil then return r end
  if 'table' ~= type(k) then return nil end
  for tk, tv in pairs( t ) do
    if deepsame( k, tk, s ) then
      r = tv
      break
    end
  end
  return r
end

function deepsame( a, b, s )
  if not s then s = {} end
  if a == b then return true end
  if 'table' ~= type( a ) then return false end
  if 'table' ~= type( b ) then return false end

  if s[ a ] == b or s[ b ] == a then return true end
  s[ a ] = b
  s[ b ] = a

  local ca = 0
  for ak, av in pairs( a ) do
    ca = ca + 1
    local o = keycheck( ak, b, s )
    if o == nil then return false end
  end

  local cb = 0
  for bk, bv in pairs( b ) do
    cb = cb + 1
    local o = keycheck( bk, a, s )
    if o == nil then return false end

    if not deepsame( bv, o, s ) then return false end
  end

  if cb ~= ca then return false end

  s[ a ] = nil
  s[ b ] = nil
  return true
end

return deepsame


end)()

differencetab = (function()


local function differencetab( firstTab, secondTab ) --> differenceTab
  local differenceTab = {}
  if not firstTab then return differenceTab end
  if not secondTab then
    for k, v in pairs(firstTab) do differenceTab[k] = v end
    return differenceTab
  end
  for k, v in pairs(firstTab) do
    if not secondTab[k] then
      differenceTab[k] = v
    end
  end
  return differenceTab
end

return differencetab


end)()

escapeshellarg = (function()


local quote_function

local function escapeshellarg( str ) --> esc

  local function posix_quote_argument(str)
    if not str:match('[^%a%d%.%-%+=/,:]') then
      return str
    else
      str = str:gsub( "[$`\"\\]", "\\%1" )
      return '"' .. str .. '"'
    end
  end

  local function windows_quote_argument(str)
    str = str:gsub('[%%&\\^<>|]', '^%1')
    str = str:gsub('"', "\\%1")
    str = str:gsub('[ \t][ \t]*', '"%1"')
    return str
  end

  if not quote_function then
    quote_function = windows_quote_argument
    local shell = os.getenv('SHELL')
    if shell then
      if '/' == shell:sub(1,1) and 'sh' == shell:sub(-2, -1) then
        quote_function = posix_quote_argument
      end
    end
  end

  return quote_function(str)
end

return escapeshellarg


end)()

filenamesplit = (function()


local function filenamesplit( str ) --> pathStr, nameStr, extStr
  if not str then str = '' end
  
  local pathStr, rest = str:match('^(.*[/\\])(.-)$')
  if not pathStr then
    pathStr = ''
    rest = str
  end

  if not rest then return pathStr, '', '' end

  local nameStr, extStr = rest:match('^(.*)(%..-)$')
  if not nameStr then
    nameStr = rest
    extStr = ''
  end

  return pathStr, nameStr, extStr
end

return filenamesplit


end)()

flatarray = (function()


local function flatarray( inTab, depthInt ) --> outTab
  local outTab = {}
  local n = 0
  local redo = false
  for _, v in ipairs( inTab ) do
    if 'table' == type(v) then
      for _, w in ipairs( v ) do
        n = n + 1
        outTab[n] = w
        if 'table' == type(w) then redo = true end
      end
    else
      n = n + 1
      outTab[n] = v
    end
  end
  if not redo then return outTab end
  if depthInt and depthInt <= 1 then return outTab end
  return flatarray( outTab, depthInt and depthInt-1 )
end

return flatarray


end)()

hexdecode = (function()


local function hexdecode( hexStr ) --> dataStr
  return hexStr:gsub( "..?", function( h )
    return string.char(tonumber(h, 16))
  end)
end

return hexdecode


end)()

hexencode = (function()


local function hexencode( dataStr ) --> hexStr
  return dataStr:gsub( ".", function( c )
    return string.format( "%02X", string.byte( c ))
  end)
end

return hexencode


end)()

intern = (function()


local function intern() --> reference

  local rawget, rawset, select, setmetatable =
    rawget, rawset, select, setmetatable, select
  local NIL, NAN = {}, {}

  local internmeta = {
    __index = function() error('Can not access interned content directly.', 2) end,
    __newindex = function() error('Can not cahnge or add contents to a intern.', 2) end,
  }

  local internstore = setmetatable( {}, { __mode = "kv" } )

  -- A map from child to parent is used to protect the internstore table's contents.
  -- In this way, they will he collected only when all the cildren are collected
  -- in turn.
  local parent = setmetatable( {}, { __mode = 'k' })

  return function( ... )
    local currentintern = internstore
    for a = 1, select( '#', ... ) do

      -- Get next intern field. Replace un-storable contents.
      local tonext = select( a, ... )
      if tonext ~= tonext then tonext = NAN end
      if tonext == nil then tonext = NIL end

      -- Get or create the correspondent sub-intern
      local subintern = rawget( currentintern, tonext )
      if subintern == nil then

        subintern = setmetatable( {}, internmeta )
        parent[subintern] = currentintern
        rawset( currentintern, tonext, subintern )
      end

      currentintern = subintern
    end
    return currentintern
  end
end

return intern


end)()

intersecationtab = (function()


local function intersecationtab( firstTab, secondTab, selectFunc ) --> intersecationTab
  local intersecationTab = {}
  if not firstTab or not secondTab then return intersecationTab end
  for k, v in pairs(firstTab) do
    local o = secondTab[k]
    if o then
      if not selectFunc then
        intersecationTab[k] = v
      else
        intersecationTab[k] = selectFunc(v, o)
      end
    end
  end
  return intersecationTab
end

return intersecationtab


end)()

iscallable = (function()


local function iscallable_rec( mask, i )

   if "function" == type( i ) then return true end

   local mt = getmetatable( i )
   if not mt then return false end
   local callee = mt.__call
   if not callee then return false end

   if mask[ i ] then return false end
   mask[ i ] = true

   return iscallable_rec( mask, callee )
end

local function iscallable( var ) --> res
   return iscallable_rec( {},  var )
end

return iscallable


end)()

isreadable = (function()


local function isreadable( path ) --> res
   local f = io.open(path, "r" )
   if not f then return false end
   f:close()
   return true
end

return isreadable


end)()

jsonish = (function()


local function json_to_table_literal(s)

  s = s:gsub('([^\\])""',"%1''")

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


end)()

jsonishout = (function()


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


end)()

keysort = (function()


local sort, tostring, type, ipairs, pairs =
  table.sort, tostring, type, ipairs, pairs

local function keysort( inTab ) --> outArr
  local outArr = {}
  local nonstring = {}
  for k in pairs(inTab) do
    if type(k) == 'string' then
      outArr[1+#outArr] = k
    else
      local auxkey = tostring(k)
      nonstring[1+#nonstring] = auxkey
      nonstring[auxkey] = k
    end
  end
  sort(outArr)
  sort(nonstring)
  for _,v in ipairs(nonstring) do
    outArr[#outArr+1] = nonstring[v]
  end
  return outArr
end

return keysort


end)()

lambda = (function()


local load = load
local memo = setmetatable( {}, { __mode = "kv" } )

local function lambda( def ) --> func, err

   -- Check cache
   local result = memo[def]
   if result then return result end

   -- Find the body and symbolic arguments
   local symb, body = def:match( "^(.-)|(.*)$" )
   if not arg or not body then
      symb = "a,b,c,d,e,f,..."
      body = def
   end

   -- Split statements from the last expression
   local stat, expr = body:match( "^(.*;)([^;]*)$" )

   -- Generate standard lua function definition
   local func = "return( function( "..symb..")"
   if not expr or expr == "" then
      func = func.."return "..body
   else
      func = func..stat.."return "..expr
   end
   func = func.." end )( ... )"

   -- Generate the function
   local result, err = load( func, "lambda", "t" )
   if result and not err then
     memo[def] = result
   end
   return result, err
end

return lambda


end)()

localbind = (function()


local pairs = pairs
local setmetatable = setmetatable
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getlocal = debug.getlocal
local setlocal = debug.setlocal

-- Return the stack index to access the i-th function, counting from the bottom.
-- Default argument is 1 and it correspond the the last lua (non C)
-- function on the stack.
local function stackfrombottom( level )
  if not level then level = 1 end
  local result = 1
  while getinfo(result) do
    result = result + 1
  end
  -- Note: the last non-nil getinfo refers to the C core; the
  --       second-last is the first lua function.
  return result - level - 2
end

local function localbind( stacklevel )
  stacklevel = stacklevel or 1
  local blevel = stackfrombottom() - stacklevel
	local func = getinfo( stackfrombottom( blevel ) ).func
  local global = {} -- Fake global when no global is compiled-in

  local function bindget( req, cache )

    -- Retrieve the locals
    local l = stackfrombottom( blevel )
    i = 0;
    while true do
      i = i + 1
      local key, value = getlocal(l, i)
      if not key then break end
      if not key:match'^%(%*' then
        if values then values[key] = value end
        if cache and not cache[key] then cache[key] = value end
        if req == key then return value, 'local', i, l-1 end
      end
    end

    -- Retrieve the upvalues
    i = 0;
    while true do
      i = i + 1
      local key, value = getupvalue(func, i)
      if not key then break end
      if values then values[key] = value end
      if key == '_ENV' then 
        global = value 
      end -- Search for the "Global table"
      if cache and not cache[key] then cache[key] = value end
      if req == key then return value, 'upvalue', i, l-1 end
    end

    -- Retrieve the globals
    if global then 
     for key, value in pairs(global) do
      if values then values[key] = value end
      if cache and not cache[key] then cache[key] = value end
      if req == key then return value, 'global', key, stackfrombottom(blevel)-1 end
    end end

    -- Not found
    return nil, 'nil', nil, stackfrombottom(blevel)-1
  end

  local function bindset( key, value )
    local _, type, index, l = bindget( key )

    -- Mutating a local
    if type and type == 'local' then
      setlocal( l, index, value )
    end

    -- Mutating an upvalue
    local func = getinfo(l).func
    if type and type == 'upvalue' then
      setupvalue( func, index, value )
    end

    -- Mutating a global
    if not type or type == 'global' or type == 'nil' then
      if global then global[key] = value end
    end
  end

  return setmetatable({}, { -- Binding proxy
    __pairs = function( self )
      local p={}
      bindget({},p)
      return pairs(p)
    end,
    __call = function( self, key )
      local v, t = bindget(key)
      return t or 'nil', v
    end,
    __index = function( self, key )
      return (bindget( key ))
    end,
    __newindex = function( self, key, value )
      bindset( key, value )
    end
  })
end

return localbind


end)()

locktable = (function()


local error, setmetatable = error, setmetatable
local pairs, ipairs = pairs, ipairs
local rawget, rawset = rawget, rawset

local function iterate( )
  error('Iteration on fielad was forbidden', 2)
end

local function readall( )
  error('Access of any field was forbidden', 2)
end

local function writeall( )
  error('Change of any field was forbidden', 2)
end

local function lockingmeta( inTab, ... ) --> proxyMet

  local function readnil( s, k )
    local v = rawget( inTab, k )
    if nil == v then
      error('Read of nil field was forbidden', 2) end
    return v
  end

  local function writenil( s, k, v )
    if nil == rawget( inTab, k ) then
      error('Write of nil field was forbidden', 2)
    end
    rawset( inTab, k, v )
  end

  local metatable = {
    __newindex = function(s, k, v) rawset( inTab, k, v ) end,
    __index = function(s,k) return rawget( inTab, k ) end,
    __pairs = function(...) return pairs(inTab, ...) end,
    __ipairs = function(...) return ipairs(inTab, ...) end,
  }

  for _, locktype in ipairs({...}) do

    if locktype == 'readnil' or locktype == 'full' then
      metatable.__index = readnil
    end
    
    if locktype == 'writenil' or locktype == 'full' then
      metatable.__newindex = writenil
    end

    if locktype == 'iterate' or locktype == 'full' then
      metatable.__pairs = iterate
      metatable.__ipairs = iterate
    end

    if locktype == 'read' or locktype == 'full' then
      metatable.__index = readall
    end

    if locktype == 'write' or locktype == 'full' then
      metatable.__newindex = writeall
    end
  end

  return metatable
end

local function locktable( inTab, ... ) --> lockedTab
  return setmetatable( {}, lockingmeta( inTab, ... ))
end

return locktable


end)()

logline = (function()


local skip_lower_level = 25

local level_list =  {
   { 25, "ERROR" },
   { 50, "DEBUG" },
   { 75, "INFO"} ,
   { 99, "VERBOSE" }
}

local level_map
local function update_level_map()
   level_map = {}
   for k,v in ipairs( level_list ) do
      level_map[ v[ 2 ] ] = v
   end
end

update_level_map()

local function logline( level, ... ) --> line
   -- Classify log level
   local level_class
   if "string" == type( level ) then
      level_class = level_map[ level:upper() ]
      if level_class then level = level_class[ 1 ] end
   elseif "number" == type( level ) then
      local level_num = #level_list
      for k = 1, level_num do
         if k == level_num or level <= level_list[k][1] then
            level_class = level_list[k] 
            break
         end
      end
   else
      return nil, "Invalid type for argument #1"
   end
   
   if not level_class then
      return nil, "Invalid symbolic log level"
   end

   local n = select( "#", ... )
   --  Single argument mode: set log level
   if n == 0 then
      skip_lower_level = level
      return
   end

   -- Multiple argument mode: generate log line

   -- Skip if the current log level is too small
   if skip_lower_level < level then
      return
   end

   -- Get info about the function in the correct stack position
   local d = debug.getinfo( 2 )
   local td = d
   local stackup = 2
   while true do
      local n = td.name
      if not n then break end
      n = n:lower()
      if  not n:match( "log$" )
      and not n:match( "^log" )
      and n ~= "" then
         break
      end
      stackup = stackup + 1
      td = debug.getinfo(stackup)
   end
   if td then d = td end

   -- Log line common part
   local line = os.date( "%Y/%m/%d %H:%M:%S" ).." "..os.clock().." "
                ..level_class[ 1 ].."."..level_class[ 2 ].." "
                ..d.short_src:match( "([^/\\]*)$" )..":"..d.currentline.." | "

   -- Append additional log info from arguments
   for m = 1,n do
      line = line..tostring( select( m, ... ) ).." | "
   end

   return line
end

return logline


end)()

pathpart = (function()


local path_separator = package.config:sub(1,1)

local function path_merge( pathTab )
  return table.concat( pathTab, path_separator )
end

local function path_split( pathStr )
  local result = {}
  for c in pathStr:gmatch( '[^/\\]+' ) do
    result[1+#result] = c
  end
  return result
end

local function pathpart( pathIn ) --> pathOut, errorStr
  local t = type(pathIn)
  if 'table' == t then return path_merge( pathIn )
  elseif 'string' == t then return path_split( pathIn )
  else return nil, 'Invalid input type'
  end
end

return pathpart


end)()

simplepath = (function()


local dirsep = package.config:sub(1,1)
local splitpat = '[^'..dirsep..']+'

local function simplepath( pathIn ) --> pathOut, errorStr
  local result = {}
  for part in pathIn:gmatch( splitpat ) do
    if part ~= '.' then
      if part ~= '..' then
        table.insert( result, part )
      else
        local nres = #result
        if nres > 0 and result[nres] ~= '..' then
          result[nres] = nil
        else
          table.insert( result, '..' )
        end
      end
    end
  end
  local pathOut = table.concat( result, dirsep )
  if pathIn:sub(1,1) == dirsep then pathOut = dirsep..pathOut end
  if pathOut == '' then
    pathOut = '.'
  end
  return pathOut
end

return simplepath


end)()

rawhtml = (function()


local function rawhtml( inStr ) --> outStr
  if inStr == '' then return '' end
  local outStr = inStr
  outStr = outStr:gsub('([{:}])',{['{']='{+}',['}']='{-}',[':']='{=}' })
  outStr = outStr:gsub('<!%-%-','{=comment=:')
  outStr = outStr:gsub('%-%->','}')
  outStr = outStr:gsub('<(/?)([^>]-)(/?)>',function(p,a,s)
    a = a:gsub('^[ \t]*(.-)[ \t]*$','%1')
    local a, b = a:match('^([^ \t]*)(.*)$')
    if p == '/' then return '}' end
    if s == '/' then s = '}' end
    if b and b ~= '' then
      b = b:gsub('^[ \t]*(.-)[ \t]*$','%1')
      b = '{=attribute=:'..b..'}'
    end
    return '{'..a..':'..b..s

  end)
  return outStr
end

return rawhtml


end)()

rawmark = (function()


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


end)()

readfile = (function()


local function readfile( pathStr, optStr ) --> readTabStr
  local f, err = io.open( pathStr, 'rb' )
  if not f or err then return f, err end
  if not optStr then optStr = 'a' end
  local readTabStr = {}
  while true do
    local p = f:seek()
    local r, err = f:read( optStr )
    if err then return nil, err end
    if p == f:seek() then break end
    if r and r ~= '' then
      readTabStr[1+#readTabStr] = r
    end
  end
  if #readTabStr == 0 then return '' end
  if #readTabStr == 1 then return readTabStr[1] end
  return readTabStr
end

return readfile


end)()

searchluakeyword = (function()


local clear_bracket_string_end

local function clear_bracket_string_start( luaStr, init )
  local s, e = luaStr:find('%[=*%[', init)
  if not s then return luaStr end
  return clear_bracket_string_end( luaStr, e-s-1, e )
end

function clear_bracket_string_end( luaStr, c, e )
  local R = ']' .. ('='):rep(c) .. ']'
  local S, E = luaStr:find(R, e, 'plain')
  if not S then S, E = #luaStr, #luaStr end
  local L = R:gsub('%]','[')
  luaStr = luaStr:sub(1,e-c-2) .. L .. (' '):rep(S-e-1) .. R .. luaStr:sub(E+1)
  return clear_bracket_string_start( luaStr, E+1 )
end

local function mask_fake_keyword( luaStr )
  local function clear_middle_string( a, x, b ) return a..(' '):rep(#x)..b end
  luaStr = luaStr:gsub('(%-%-)([^\n]*)(\n?)', clear_middle_string)
  luaStr = luaStr:gsub([[(['"])(.-)(%1)]], clear_middle_string)
  return clear_bracket_string_start( luaStr, 1 )
end

local function first_capture_list( luaStr, p )
  local result = {}
  local count = 0
  for position in luaStr:gmatch(p) do
    result[1+#result] = position
    count = count + 1
  end
  if #result == 0 then return nil, 0 end
  return result, count
end

local lua_keyword = {
  i = { -- keywords that may generate infinite loops
    "goto", "while", "repeat", "until", "in", "function", '::label::', },
  l = { -- keywords found in a limited loop
    "for", "break", },
  v = { -- keywords that are value literal
    "nil", "false", "true", },
  b = { -- keywords that generate branched execution
    "do", "end", "if", "then", "elseif", "else", },
  o = { -- keywords that are operators
    "and", "or", "not", },
  s = { -- Special symbols
    ';','{','}', '[',']', ',','...','(',')', ':', '.',
    '=','+','-','*','/','//','^','%', '&','~','|','>>','<<', '..',
    '<','<=','>','>=','==','~=', '-','#', },
}

-- local load = load

local search_pattern

local function searchluakeyword( luaStr, optionStr--[[, chunknameStr, envTab]] ) --> keywordTab
  if not optionStr then optionStr = 'ilvbo' end
  local keywordTab = {}

  if not lua_keyword_ready then
    search_pattern = {}
    for t, m in pairs(lua_keyword) do
      for _, k in pairs(m) do
        if k:match('^%a') then
          search_pattern[k] = '()%f[%a%d_]'..k..'%f[^%a%d_]'
        elseif #k == 1 then
          search_pattern[k] = '()%f[=~<>%'..k..']'..k:gsub('(.)','%%%1')..'%f[^=~<>%'..k..']'
        else
          search_pattern[k] = '()%f[%'..k:sub(1,1)..']'..k:gsub('(.)','%%%1')..'%f[^%'..k:sub(-1,-1)..']'
        end
      end
    end
    search_pattern['::label::'] = '()%f[:]::%a-::%f[^:]'
  end

  -- local exec, err = load( luaStr, chunknameStr, 't', envTab )
  -- if not exec then exec = err end

  luaStr = mask_fake_keyword( luaStr )

  local count, c = 0, 0
  for t, m in pairs(lua_keyword) do
    if optionStr:find(t) then
      for _, k in pairs(m) do
        keywordTab[k], c = first_capture_list( luaStr, search_pattern[k] )
        count = count + c
      end
    end
  end

  return keywordTab, count --, exec
end

return searchluakeyword


end)()

serialize = (function()


local type = type

local function basic_representation( value, outfunc )
  local tv = type(value)
  if "string" == tv then
    outfunc(string.format( "%q", value ):gsub('\n','n'))
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


end)()

sha2 = (function()


-- Note: Big-endian convention is used when parsing message block data from
-- bytes to words, for example, the first word of the input message "abc" after
-- padding is 0x61626380

-- For non-8-bit-multiple message:
-- It returns the pad description and the zero-padded odd bits
local function sub_byte_suffix(message, L)
  local fb = L % 8
  if fb == 0 then return 0x80 end

  fb = 7 - fb
  local val = message:byte(-1,-1)
  val = val >> fb
  val = val | 1
  val = val << fb
  return val
end

-- calc the hash of a L-bits message
local function sha2core(message, L, algospec)

  -- Cache some values for speed
  local o = 23
  local r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12,
    intsiz, hashtrunc, chunksize,
    h0, h1, h2, h3, h4, h5, h6, h7,
    k =
      table.unpack(algospec)
  local roundnum = #algospec - o
  local sb = {}
  for i = 1, 12 do sb[i] = 8 * intsiz - algospec[i] end
  local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12 = table.unpack(sb)
  local summask = (( ~0 ) << ( 8 * intsiz )) ~ ( ~0 ) -- intsiz=4 -> summask=0xffffffff
  local packspec = ">" .. ( 'I' .. intsiz ):rep( 16 ) -- intsiz=4 -> packspec=>I4I4... 16 times

  -- Pre-processing: make the length a multiple of the chunk size; the original
  -- lenght will be written in the last bytes
  local addchar = sub_byte_suffix(message, L)
  if 0x80 ~= addchar then message = message:sub(1,-2) end
  message = message 
    .. string.char(addchar)
    .. ('\0'):rep(chunksize - ((#message + 1 + 2*intsiz) % chunksize))
    .. string.pack('>I'..(2*intsiz), L)

  -- Process the message in successive fixed-lenght chunks:
  for pos = 1, #message, chunksize do
      local w = {string.unpack(packspec, message, pos)}

      -- Extend the first 16 words into the remaining words, one for each round
      for i = 17, roundnum do

          local a = w[i-15]
          local aR7  = (a >> r1) | (a << l1) -- Right-Rotate a >> r1
          local aR18 = (a >> r2) | (a << l2) -- Right-Rotate a >> r2
          local b = w[i-2]
          local bR17 = (b >> r3) | (b << l3) -- Right-Rotate b >> r3
          local bR19 = (b >> r4) | (b << l4) -- Right-Rotate b >> r4

          local s0 = aR7 ~ aR18 ~ (a >> r5)
          local s1 = bR17 ~ bR19 ~ (b >> r6)
          w[i] = (w[i-16] + s0 + w[i-7] + s1 ) & summask
      end

      -- Initialize working variables to current hash value:
      local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7

      -- Compression function main loop:
      for i = 1, roundnum do
          local eR6  = (e >> r7)  | (e << l7) -- Right-Rotate e >> r7
          local eR11 = (e >> r8)  | (e << l8) -- Right-Rotate e >> r8
          local eR25 = (e >> r9)  | (e << l9) -- Right-Rotate e >> r9
          local aR2  = (a >> r10) | (a << l10) -- Right-Rotate a >> r10
          local aR13 = (a >> r11) | (a << l11) -- Right-Rotate a >> r11
          local aR22 = (a >> r12) | (a << l12) -- Right-Rotate a >> r12

          local S1 = eR6 ~ eR11 ~ eR25
          local ch = (e & f) ~ ((~ e) & g)
          local temp1 = h + S1 + ch + algospec[o+i] + w[i]
          local S0 = aR2 ~ aR13 ~ aR22 
          local maj = (a & b) ~ (a & c) ~ (b & c)
          local temp2 = S0 + maj
   
          h = g
          g = f
          f = e
          e = (d + temp1) & summask
          d = c
          c = b
          b = a
          a = (temp1 + temp2) & summask
      end

      -- Add the compressed chunk to the current hash value:
      h0 = (h0 + a) & summask
      h1 = (h1 + b) & summask
      h2 = (h2 + c) & summask
      h3 = (h3 + d) & summask
      h4 = (h4 + e) & summask
      h5 = (h5 + f) & summask
      h6 = (h6 + g) & summask
      h7 = (h7 + h) & summask
  end

  return string.pack( ">" .. ( 'I' .. intsiz ):rep( hashtrunc ),
    h0, h1, h2, h3, h4, h5, h6, h7 )
end

local sha256_spec = {

  -- Rotation constants
  7, 18, 17, 19,
  3, 10,
  6, 11, 25,
  2, 13, 22,

  -- Integer bit size. All variables are 32 bit unsigned integers. The appended
  -- message lengt is 32 bit. The additions are calculated modulo 2^32.
  4,

  -- Hash size (max 8) -- Integer size unit
  8,

  -- Chunk size -- byte
  64,

  -- Initial hash values:
  -- (first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
  0x6a09e667,
  0xbb67ae85,
  0x3c6ef372,
  0xa54ff53a,
  0x510e527f,
  0x9b05688c,
  0x1f83d9ab,
  0x5be0cd19,

  -- Round constants:
  -- (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local sha224_spec = {

  -- Rotation constants
  7, 18, 17, 19,
  3, 10,
  6, 11, 25,
  2, 13, 22,

  -- Integer bit size. All variables are 32 bit unsigned integers. The appended
  -- message lengt is 32 bit. The additions are calculated modulo 2^32.
  4,

  -- Hash size (max 8) -- Integer size unit
  7,

  -- Chunk size -- byte
  64,

  -- Initial hash values:
  -- (The second 32 bits of the fractional parts of the square roots of the 9th through 16th primes 23..53)
  0xc1059ed8,
  0x367cd507,
  0x3070dd17,
  0xf70e5939,
  0xffc00b31,
  0x68581511,
  0x64f98fa7,
  0xbefa4fa4,

  -- Round constants:
  -- (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local sha512_spec = {

  -- Rotation constants
  1, 8, 19, 61,
  7, 6,
  14, 18, 41,
  28, 34, 39,

  -- Integer bit size. All variables are 64 bit unsigned integers. The appended
  -- message lengt is 64 bit. The additions are calculated modulo 2^64.
  8,

  -- Hash size (max 8) -- Integer size unit
  8,

  -- Chunk size -- byte
  128,
  
  -- Initial hash values:
  -- (first 64 bits of the fractional parts of the square roots of the 9th-16th primes):
  0x6a09e667f3bcc908,
  0xbb67ae8584caa73b,
  0x3c6ef372fe94f82b,
  0xa54ff53a5f1d36f1,
  0x510e527fade682d1,
  0x9b05688c2b3e6c1f,
  0x1f83d9abfb41bd6b,
  0x5be0cd19137e2179,

  -- Round constants:
  -- (first 64 bits of the fractional parts of the cube roots of the first 80 primes 2..409):
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 
    0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe, 
    0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab, 
    0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 
    0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b, 
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 
    0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 
    0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c, 
    0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 
    0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
}

local sha384_spec = {

  -- Rotation constants
  1, 8, 19, 61,
  7, 6,
  14, 18, 41,
  28, 34, 39,

  -- Integer bit size. All variables are 64 bit unsigned integers. The appended
  -- message lengt is 64 bit. The additions are calculated modulo 2^64.
  8,

  -- Hash size (max 8) -- Integer size unit
  6,

  -- Chunk size -- byte
  128,
  
  -- Initial hash values:
  -- (first 64 bits of the fractional parts of the square roots of the 9th-16th primes):
  0xcbbb9d5dc1059ed8,
  0x629a292a367cd507,
  0x9159015a3070dd17,
  0x152fecd8f70e5939,
  0x67332667ffc00b31,
  0x8eb44a8768581511,
  0xdb0c2e0d64f98fa7,
  0x47b5481dbefa4fa4,

  -- Round constants:
  -- (first 64 bits of the fractional parts of the cube roots of the first 80 primes 2..409):
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 
    0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe, 
    0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab, 
    0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 
    0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b, 
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 
    0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 
    0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c, 
    0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 
    0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
}

local function sha2( message, L, algo )
  if not L then L = 8 * #message end
  local algospec = sha256_spec
  if 'table' ~= type(algo) then
    if algo == 256 then algospec = sha256_spec end
    if algo == 224 then algospec = sha224_spec end
    if algo == 512 then algospec = sha512_spec end
    if algo == 384 then algospec = sha384_spec end
  end
  return sha2core(message, L, algospec)
end

return sha2


end)()

shellcommand = (function()




local function shellcommand( commandTab ) --> commandStr
  if not commandTab then return '' end
  local commandStr = ''
  for _, v in ipairs(commandTab) do
    commandStr = commandStr .. ' ' .. escapeshellarg(v)
  end
  local ri = ' < '
  local ro = ' > '
  local re = ' 2> '
  local moe = ''
  if commandTab.append then
    ro = ' >> '
    re = ' 2>> '
  end
  if commandTab.output == commandTab.error then
    commandTab.error = nil
    moe = ' 2>&1'
  end
  if commandTab.input then
    commandStr = commandStr .. ri .. escapeshellarg(commandTab.input) .. moe
  end
  if commandTab.output then
    commandStr = commandStr .. ro .. escapeshellarg(commandTab.output) .. moe
  end
  if commandTab.error then
    commandStr = commandStr .. re .. escapeshellarg(commandTab.error) .. moe
  end
  return commandStr
end

return shellcommand


end)()

stepdebug = (function()


local function stackbottom()
  local result = 1
  while debug.getinfo(result) do
    result = result + 1
  end
  return result
end

local onstep = function() end
local stack_level = 0
local deb_enabled = false
local stack_level_change = nil

local next_line

local this_source
local function deb_hook(event)
  if stack_level_change then
    stack_level = stack_level + stack_level_change
    stack_level_change = nil
  end
  if not deb_enabled then return end
  if not this_source then
    this_source = debug.getinfo(1).source
  end
  local b = stackbottom()
  if b > stack_level then return end
  local f = debug.getinfo(2)
  if f.source == this_source then return end
  if f.source:sub(1,1) ~= '@' then return end
  if event == 'return' then stack_level = b-1 end
  if event ~= 'line' then return end
  local result = onstep(3,event)
  if next_line then
    next_line = nil
    return result
  end
  return deb_hook(event) --> tail call
end

local function deb_next_line()
  next_line = true
  return nil
end

local function deb_break()
  stack_level = stackbottom()
  deb_enabled = true
  debug.sethook(deb_hook,'clr')
end

local function deb_continue()
  deb_enabled = false -- currently redundant
  debug.sethook() -- currently redundant
end

local function deb_target( level )
  stack_level_change = level
end

local function deb_chunk_exec( code )
  local exec, err = load('return '..code, '(*iteractive)', 't')
  if not exec or err then
    exec, err = load(code, '(*iteractive)', 't')
  end
  if not exec or err then
    print(err)
  else
    local ok, result = pcall(function() return exec() end)
    if not ok then print(result) end
    return result
  end
end

local function stepdebug( op )
  if 'function' == type(op) then
    onstep = op
    return
  end

  local cmd = op:lower():gsub('^[ \t]*(.-)[ \t]*$','%1')

  if '' == op then return
  elseif 'n' == op or 'next' == op then return deb_next_line()
  elseif 's' == op or 'step' == op then deb_target(1)
  elseif 'f' == op or 'finish' == op then deb_target(-1)
  elseif 'c' == op or 'continue' == op then deb_continue()
  elseif 'quit' == op then os.exit()

  elseif 'break' == op then
    deb_break()
    stack_level = stack_level -1

  else
    return deb_chunk_exec(op)
  end
end

return stepdebug


end)()

subbytebase = (function()




-- This can be used for base2-4-8-16 and crockford base32
local subbyte_multipurpose_alphabet = {
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
}

-- This can be used for standard base64
local subbyte_base64_alphabet = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
  'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
  'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
}

local subbyte_inverse_cache = {}

local function subbyte_alphabet_invert( map )
  if not map then return nil end
  local imap = {}

  -- cache standard inverse alphabets
  if map == subbyte_multipurpose_alphabet or map == subbyte_base64_alphabe then
    local s = subbyte_inverse_cache[map]
    if s then return s end
    subbyte_inverse_cache[map] = s
  end

  -- invert the alphabet
  for i=1,256 do for j=1,256 do
    if map[j]==string.char(i-1) then imap[i] = string.char(j-1) end
  end end
  return imap
end

local function subbytebase(bit, str, map)
  if bit == 8 then return str end
  if str == '' then return str end
  if bit == 0 then error() end
  local result = str

  local mode = 'encode'
  if bit < 0 then
    mode = 'decode'
    bit = - bit
  end

  if not map then
    if bit >= 1 and bit <= 5 then
      map = subbyte_multipurpose_alphabet
    elseif bit == 6 then
      map = subbyte_base64_alphabet
    end
  end

  local pad
  if mode == 'decode' then 

    -- handle '=' tail
    local hastail = ('=' == result:sub(-1,-1))
    result = result:gsub('%=*$', '')

    local imap = subbyte_alphabet_invert( map )
    result, pad = bitpad(bit-8,bit,result,nil,imap)

    -- handle '=' tail
    if hastail then result = result:sub(1, -2) end

  else -- mode == 'decode'

    result, pad = bitpad(8-bit,bit,result,map)

    -- handle '=' tail
    if pad ~= 0 then
      for p = 1, 8 do if (bit - pad + 8 * p) % bit == 0 then
        result = result .. (('='):rep(p))
        break
      end end
    end

  end

  return result
end

return subbytebase


end)()

tapfail = (function()


local function ton( x )
  local _, x = pcall(function() return tonumber(x) end)
  if x < 0 then return nil end
  if x ~= math.modf(x) then return nil end
  return x
end

local function tapfail( ) --> streamFunc( lineStr ) --> errorStr
  local summary
  local summary_line
  local testcount = 0
  local l = 0

  local function check_line( line )
    if line == '' then
      return nil
    elseif line:match('^#') then
      return nil
    else

      local ok = line:match('^ok (%d*)')
      if ok then
        if summary_line and l > summary_line and summary_line ~= 1 then
          return 'line after summary'
        end
        ok = ton( ok )
        if not ok then ok = -9 end
        local deltacount = ok - testcount
        testcount = ok
        if deltacount ~= 1 then
          return 'invalid count sequence'
        end
      end

      local sum = line:match('^1%.%.(.*)')
      if sum == 'N' then
        sum = true
      elseif sum then
        sum = ton( sum )
      end
      if sum then
        summary = sum
        if not summary_line then
          summary_line = l
        else
          return 'summary already found at line '..summary_line
        end
      end

      if not ok and not diag and not summary then
        return 'no diagnostic or ok line'
      end

      if not result and summary and summary ~= true then
        if summary_line==l and l > 1 and summary ~= testcount then
          return 'invalid test count'
        elseif summary<testcount then
          return 'invalid count sequence'
        end
      end

      return nil
    end
  end
  
  local last_error

  local function tapchunk( line )
    if not line then
      if not summary then
        last_error = 'summary missing'
      elseif summary ~= true and summary > testcount then
        last_error = 'missing test'
      end
      return last_error
    end

    l = l + 1
    local result = check_line( line )

    if result then last_error = result end
    return result
  end

  return tapchunk
end

return tapfail


end)()

taptest = (function()


local test_count = 0
local fail_count = 0

local function taptest( ... ) --> msg

   local function diagnostic( desc )
      local msg = "# "..desc:gsub( "\n", "\n# " )
      return msg
   end

   local function print_summary()
      local msg = '\n' .. tostring(fail_count) .. " tests failed\n"
      if fail_count == 0 then msg = '\nall is right\n' end
      msg = diagnostic(msg)
      local plan = "1.."..test_count
      return msg..'\n'..plan
   end

   local function get_report_position()
     local result
     local stackup = 2
     local testpoint = false
     while not testpoint do
       stackup = stackup + 1
       result = debug.getinfo(stackup)
       if not result then
         return debug.getinfo(3)
       end
       local j = 0
       testpoint = true
       while true do
         j = j + 1
         local k, v = debug.getlocal(stackup, j)
         if k == nil then break end
         if v and k == 'taptest_blame_caller' then
           testpoint = false
           break
         end
       end
       if testpoint then return result end
     end
   end

   local function do_check(got, expected, a, b)

      -- Extra arg parse and defaults
      local checker, err
      if "string" == type(a) then err = a end
      if "string" == type(b) then err = b end
      if not err then err = "" end
      if "function" == type(a) then checker = a end
      if "function" == type(b) then checker = b end
      if not checker then checker = function( e, g ) return e == g end end

      -- Check the condition
      test_count = test_count + 1
      local ok, info = checker( got, expected )

      -- Generate TAP line
      local msg = ""
      if ok then
         msg = msg.."ok "..test_count
      else
         fail_count = fail_count + 1
         local i = get_report_position()

         msg = msg
               .."not ok " .. test_count .. " - "
               ..i.source:match( "([^@/\\]*)$" )..":"..i.currentline..". "
      end

      -- Append automatic info
      if not ok and not info then
        msg = msg
          .. "Mismatch: ["..tostring( got ).."] "
          .. "VS ["..tostring( expected ).."]. "
      end

      -- Append user-provided info
      if info then
        msg = msg.." "..info
      end

      if not ok then
        msg = msg..err
      end

      return msg
   end

   local narg = select( "#", ... )
   if     0 == narg then return print_summary()
   elseif 1 == narg then return diagnostic( select( 1, ... ) )
   elseif 4 >= narg then return do_check( ... )
   end

   return nil, "Too many arguments"
end

return taptest


end)()

templua = (function()


local setmetatable, load = setmetatable, load
local fmt, tostring = string.format, tostring
local error = error

local function templua( template ) --> ( sandbox ) --> expstr, err
   local function expr(e) return ' out('..e..')' end
  
   -- Generate a script that expands the template
   local script = template:gsub( '(.-)@(%b{})([^@]*)',
     function( prefix, code, suffix )
        prefix = expr( fmt( '%q', prefix ) )
        suffix = expr( fmt( '%q', suffix ) )
        code = code:sub( 2, #code-1 )

        if code:match( '^{.*}$' ) then
           return prefix .. code:sub( 2, #code-1 ) .. suffix
        else
           return prefix .. expr( code ) .. suffix
        end
     end
   )

   -- Utility to append the script to the error string
   local function report_error( err )
     return nil, err..'\nTemplate script: [[\n'..script..'\n]]'
   end

   -- Special case when no template tag is found
   if script == template then
     return function() return script end
   end

   -- Compile the template expander in a empty environment
   local env = {}
   script = 'local out = _ENV.out; local _ENV = _ENV.env; ' .. script
   local generate, err = load( script, 'templua_script', 't', env )
   if err ~= nil then return report_error( err ) end

   -- Return a function that runs the expander with a custom environment
   return function( sandbox )

     -- Template environment and utility function
     local expstr = ''
     env.env = sandbox
     env.out = function( out ) expstr = expstr..tostring(out) end

     -- Run the template
     local ok, err = pcall(generate)
     if not ok then return report_error( err ) end
     return expstr
  end
end

return templua


end)()

timeprof = (function()


local clock, sqrt = os.clock, math.sqrt

local checkpoint = setmetatable({}, {mode="kv"})

local function timeprof_start(self)
  self.time_last = clock()
end

local function timeprof_stop(self)
  if self.time_last > 0 then
    local time_delta = clock() - self.time_last
    self.time_last = -1
    self.time_step = self.time_step + 1
    self.time_sum = self.time_sum + time_delta
    self.time_square_sum = self.time_square_sum + (time_delta * time_delta)
  end
end

local function timeprof_summary(self)
  local ts = self.time_sum
  local n = self.time_step
  if self.time_step < 2 then return ts, ts, 0 end
  return ts, ts/n, sqrt((self.time_square_sum - ts*ts/n)/(n-1))
end

local function timeprof_reset(self)
  self.time_sum = 0
  self.time_square_sum = 0
  self.time_step = 0
end

local function timeprof( checkpointVal ) --> resTyp
  local resTyp
  if checkpointVal then resTyp = checkpoint[ checkpointVal ] end
  if not checkpointVal or not resTyp then
    resTyp = {
      start = timeprof_start,
      stop = timeprof_stop,
      reset = timeprof_reset,
      summary = timeprof_summary,
    }
    resTyp:reset()
    if checkpointVal then
      checkpoint[ checkpointVal ] = resTyp
    else
      checkpoint[ resTyp ] = resTyp
    end
  end
  return resTyp
end

return timeprof


end)()

toposort = (function()


local pairs, ipairs = pairs, ipairs

local function toposort( depTab ) --> orderArr
  depTab = depTab or {}
  local status, orderArr, tovisit, o, n = {}, {}, {}, 0, 0
  for node in pairs( depTab ) do
    local stat = status[node]
    if not stat then
      n = n + 1
      tovisit[n] = node
      repeat
        local dlist = not stat and depTab[node]
        if dlist then
          for _, depend in ipairs(dlist) do
            local dstat = status[depend]
            if not dstat then -- just an optimization
              n = n + 1
              tovisit[n] = depend
            elseif dstat == 'seen' then -- seen but not pushed -> cycle detected
              return nil, 'cycle detected', orderArr
            end
          end 
        else
          if stat ~= 'pushed' then
            o = o + 1
            orderArr[o] = node
          end
          tovisit[n] = nil
          n = n - 1
          status[node] = 'pushed'
        end
        status[node] = status[node] or 'seen'
        node = tovisit[n]
        stat = status[node]
      until n <= 0
  end end
  return orderArr
end

return toposort


end)()

trimstring = (function()


local function trimstring( inStr ) --> trimStr
  return inStr:match('^[ %c]*(.-)[ %c]*$')
end

return trimstring


end)()

tuple = (function()




local select, getmetatable, setmetatable = select, getmetatable, setmetatable

local tuplefact = intern()

local function tuple( ... ) --> tupleTable

  local tupleTable = tuplefact( ... )
  if not getmetatable( tupleTable ).__type then -- First time initialization

    -- Store fields
    -- local n = select( '#', ... )
    -- local fields = { n=n, ... }
    -- for i = 1, fields.n do fields[i] = select( i, ... ) end
    local fields = { ... }
    fields.n = select( '#', ... )

    -- Dispatch to the stored fields, and forbid modification
    setmetatable( tupleTable, {
      type = 'tuple',
      __index = function( t, k ) return fields[k] end,
      __newindex = function( t, k ) return error( 'can not change tuple field', 2 ) end,
    })

  end
  return tupleTable
end

return tuple


end)()

uniontab = (function()


local function uniontab( firstTab, secondTab, selectFunc ) --> unionTab
  local unionTab = {}
  if secondTab then
    for k, v in pairs(secondTab) do unionTab[k] = v end
  end
  if not firstTab then return unionTab end
  for k, v in pairs(firstTab) do
    local o = unionTab[k]
    if not o then
      unionTab[k] = v
    else
      if not selectFunc then
        unionTab[k] = v
      else
        unionTab[k] = selectFunc(v, o)
      end
    end
  end
  return unionTab
end

return uniontab


end)()

valueprint = (function()


local function print_basic( cur )
  if "string" == type( cur ) then
    return string.format( "%q", cur ):gsub( '\n', 'n' )
  else
    return tostring( cur ):gsub( ':', '' )
  end
end

local function print_with_annotation( cur, memo )
  local s = print_basic( cur )
  if type(cur) == 'table' then
    if memo == true or memo[cur] then
      s = s .. ' content is not shown here'
    end
  end
  return s
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
      return print_with_annotation( cur )
    end 

    local subtab = {}

    -- Start table iteration
    local is_hidden = ' content not shown here'
    local ref = print_with_annotation( cur, memo )
    table.insert( subtab, format( nil, ref, depth, 'in'))

    -- Recurse over each key and each value
    if not memo[cur] then
      memo[cur] = true
      for k, v in pairs( cur ) do
        k = print_with_annotation( k, true )
        local vs = print_with_annotation( v, memo )
        table.insert( subtab, format( k, vs, depth, type( v )) or '' )
        if 'table' == type(v) then
          table.insert( subtab, valueprint_rec( v, depth+1 ) or '')
        end
      end
    end

    -- -- End table iteration
    table.insert( subtab, format( nil, ref, depth, 'out'))

    return table.concat( subtab )
  end
  return valueprint_rec( value, 1 )
end

return valueprint


end)()

object = (function()


local setmetatable, move = setmetatable, table.move

local prototype_map = setmetatable({},{__mode="k"})
local function protoadd( instance, protochain )

  local protos = prototype_map[instance]
  if not protos then
    protos = setmetatable( {meta={}}, {__mode="k"} )
    prototype_map[instance] = protos
  end
  local meta = protos.meta

  local pn = #protochain
  if pn > 0 then
    move( protos, 1, #protos, pn+1)
  end
  move( protochain, 1, pn, 1, protos )

  meta.__index = function( _, k )
    local pn = #protos
    for p = 1, pn do
      local field = protos[p][k]
      if field ~= nil then
        return field
      end
    end
  end

  return setmetatable( instance, meta )
end

local function inherit(b, o)
  o = o or {}
  return protoadd(o, b)
end

local function has_proto( derived, base )
  local protos = prototype_map[derived]

  if protos then
    for _, b in pairs(protos) do
      if b == base then return true end
      if has_proto( b, base ) then return true end -- TODO : avoid recursion? memoize?
    end
  end
  return false
end

return {
  inherit = inherit,
  isderived = has_proto,
}


end)()

factory = (function()


--[[

-- TODO : super accessor IDEA :
local function method_accessor( obj )
  local result = {}
  for k, v in pairs( obj ) do
    if 'function' == type( v ) then
      result[ k ] = v
    end
  end
  return setmetatable( result, { __index = obj, __newindex = obj, })
end

-- TODO : super accessor IDEA USAGE :
local make3DPoint, is3DPoint = factory(function(ins)
  make2DPoint(ins)
  local super = method_accessor(ins)
  local z = ins[3]
  function ins:getZ() return self.scale * z end
  function ins:getR2() return super:getR2() + self.scale * z*z end
end)

--]]

local type, select, setmetatable = type, select, setmetatable

local function factory( initializer )

  local made_here = setmetatable({},{__mode='kv'})

  local function checker(i)
    if i == 'all' then
      return pairs( made_here )
    else
      return made_here[i] or false
    end
  end

  local function constructor( instance )
    instance = instance or {}
    made_here[instance] = true

    local err = nil
    if initializer then
      local protect = instance
      instance, err = initializer( instance )
      if nil == instance then instance = protect end
    end

    made_here[instance] = true

    return instance, err
  end
  return constructor, checker
end

return factory


end)()

measure = (function()


local sqrt = math.sqrt

local aux_get_state = {}

local function measure( partMea ) -->

  -- init
  local M1 = 0
  local M2 = 0
  local M3 = 0
  local M4 = 0
  local n = 0
  local min = nil
  local max = nil

  local function import_set(M1F2, M2F2, M3F2, M4F2, n2, min2, max2)
    if n == 0 then
      M1, M2, M3, M4, n = M1F2, M2F2, M3F2, M4F2, n2
      min = min2
      max = max2
    else
      -- Formula: Philippe Pébay. SANDIA REPORT SAND2008-6212 (2008) - https://prod.sandia.gov/techlib-noauth/access-control.cgi/2008/086212.pdf
      local M1F1, M2F1, M3F1, M4F1, n1 = M1, M2, M3, M4, n
      local n1p2 = n1 + n2
      local nn = n1 * n2
      local n1sq = n1 * n1
      local n2sq = n2 * n2
      local D = (M1F2 - M1F1) / n1p2
      local DSQ = D * D
      M1 = M1F1 + n2 * D
      M2 = M2F1 + M2F2
           + nn * DSQ * n1p2
      M3 = M3F1 + M3F2
           + nn * (n1 - n2) * n1p2 * D * DSQ
           + 3 * (n1 * M2F2 - n2 * M2F1) * D
      M4 = M4F1 + M4F2
           + nn * (n1sq + n2sq - nn) * n1p2 * DSQ * DSQ
           + 6 * (n1sq * M2F2 + n2sq * M2F1) * DSQ
           + 4 * (n1 * M3F2 - n2 * M3F1) * D
      n = n1p2
      if min2 and min2<min then
        min = min2
      end
      if max2 and max2>max then
        max = max2
      end
    end
  end

  local function import_all( ml )
    for _, m in pairs( ml ) do
      import_set( m( aux_get_state ))
    end
  end

  local function get_measure( value )
    if value == aux_get_state then
      return M1, M2, M3, M4, n, min, max
    elseif value ~= nil then
      import_set(value, 0, 0, 0, 1, value, value)
    end
    local m, d, s, k = M1, 0, 0, 0
    if n > 1 then
      d = sqrt( M2 /( n - 1 ))
    end
    if n > 1 and d > 0 then
      -- s = M3 /( n * d * d * d ) -- wikipedia
      s = M3 * sqrt(n) /sqrt( M2 * M2 * M2 ) -- wolfram
    end
    if M2 > 0 then
      k = M4 * n /( M2 * M2 )
    end
    return m,d,s,k,n,min,max
  end

  if partMea then import_all(partMea) end
  return get_measure
end

return measure


end)()

clone = (function()


local function shallow_copy( depth, cloned, toclone )
  local source = toclone[#toclone]
  if not source then return end
  toclone[#toclone]=nil

  local root = cloned[ source ]
  if not root then
    root = {}
    cloned[ source ] = root

    for k, v in pairs( source ) do
      root[k] = v

      if not depth or depth > 1 then
        if type(k) == 'table' then
          toclone[1+#toclone] = k
        end

        if type(v) == 'table' then
          toclone[1+#toclone] = v
        end
      end
    end

    return shallow_copy( depth and depth-1, cloned, toclone )
  end
end

local function link_clones( cloned )
  for _, tolink in pairs(cloned) do

    local K, V = {}, {}
    for k, v in pairs( tolink ) do
      local newk = cloned[k]
      local newv = cloned[v]

      if newk then
         tolink[k] = nil

        -- Note: New key adding is postponed since it is forbidden
        -- during iteration
        K[#K+1] = newk or k
        V[#V+1] = newv or v

      elseif newv then
        tolink[k] = newv
      end
    end

    for i = 1, #K do
      tolink[K[i]] = V[i]
    end
  end
end

local function clone( sourceTab, depthNum )
  if depthNum == 0 then return sourceTab end
  if depthNum and depthNum < 1 then return sourceTab end
  local toclone = {sourceTab}
  local cloned = {}
  shallow_copy( depthNum, cloned, toclone )
  link_clones( cloned )
  return cloned[sourceTab]
end

return clone


end)()

datestd = (function()


local pack, unpack, modf = table.pack, table.unpack, math.modf

local function validate_date( dateTab )
  -- TODO : implement !
  return dateTab
end

local function datestd_encode( dateTab ) --> dateStr

  local dateTab, e = validate_date( dateTab )
  if not dateTab then
    return nil, e
  end

  local dateStr = ''
  if dateTab.year then
    dateStr = dateStr .. string.format("%04d-%02d-%02d", dateTab.year, dateTab.month, dateTab.day)
  end
  if dateTab.hour then
    if dateTab.year then
      dateStr = dateStr .. ' '
    end
    local sec, frac = modf(dateTab.sec)
    dateStr = dateStr .. string.format("%02d:%02d:%02d", dateTab.hour, dateTab.min, sec)
    if frac > 0 then
				dateStr = dateStr .. tostring(frac):gsub("0(.-)0*$","%1")
    end
  end
  if dateTab.zone then
    local zonestr = ''
    if dateTab.zone == 0 then
      zonestr = 'Z'
    end
    if dateTab.zone > 0 then
      zonestr = '+' .. string.format("%02d:00", dateTab.zone)
    end
    if dateTab.zone < 0 then
      zonestr = '-' .. string.format("%02d:00", -dateTab.zone)
    end
    dateStr = dateStr .. zonestr
  end
  return dateStr
end

local function datestd_decode( dateStr ) --> dateTab
  local dateTab = {}

  local cursor = 1

  local function check_pattern( pat )
    return dateStr:sub(cursor):match( '^'..pat )
  end

  local function match_pattern( pat )

    local result = pack(check_pattern( pat .. '()' ))
    if not result[1] then return nil end

    local n = result[#result]
    result[#result] = nil
    result.n = result.n - 1

    cursor = cursor + n - 1
    return unpack(result)
  end

  local function match_date()
    return match_pattern('(%d%d%d%d)%-([0-1][0-9])%-([0-3][0-9])')
  end
  
  local function match_separator()
    return match_pattern('([T ])')
  end

  local function match_time()
    return match_pattern('([0-2][0-9])%:([0-6][0-9])%:(%d+%.?%d*)')
  end

  local function match_utc_zone()
    return match_pattern('(Z)')
  end

  local function match_zone()
    return match_pattern('([%+%-])([0-9][0-9])%:([0-9][0-9])')
  end

	local function parse_date()
    local year, month, day = match_date()
    if not year then return nil, "Invalid date" end

    local hour, minute, second = '', '', '', ''

    local date_time_separator = false
    if match_separator() then
      date_time_separator = true
    end

    if date_time_separator then
      hour, minute, second, n = match_time()
      if not hour then return nil, "Invalid date" end
    end

    local zone
    if match_utc_zone() then
      zone = 0
    else
      local eastwest, offset = match_zone()
      if eastwest then
        zone = tonumber(eastwest..offset)
      end
    end

    local value = {
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = tonumber(hour),
      min = tonumber(minute),
      sec = tonumber(second),
      zone = zone,
    }

    local e
    value, e = validate_date(value)
    if not value then return nil, e end

    return value
  end

	local function parse_time()
		hour, minute, second, n = match_time()
		if not hour then return nil, "Invalid date" end

		local value = {
			hour = tonumber(hour),
			min = tonumber(minute),
			sec = tonumber(second),
		}

		local value, e = validate_date(value)
		if not value then return nil, e end

		return value
	end

  if check_pattern("%d%d%d") then
    return parse_date()
  elseif check_pattern("%d%d%:") then
    return parse_time()
  else
    return nil, "Invalid date formmat"
  end

  return dateTab
end

local function datestd( dateIn ) --> dateOut
  if type( dateIn ) == 'string' then
    return datestd_decode( dateIn )
  elseif type( dateIn ) == 'table' then
    return datestd_encode( dateIn )
  else
    return nil, "Argument #1 must be a string o ar table."
  end
end

return datestd


end)()

lineposition = (function()


local select = select

local function lineposition( str, byteNum, ... ) --> columnNum | byteNum[, lineNum]

  local lineNum = select('#', ...) > 0 and select(1, ...)

  if lineNum then
    local columnNum = byteNum
    local pat = ( "[^\n]*\n" ):rep( lineNum -1 ) .. '()'
    local lineoff = str:match( pat )
    if lineoff then
      return lineoff -1 + columnNum
    end
    return nil

  else
    local columnNum = byteNum
    lineNum = 1

    for c in str:gmatch('\n()') do
      if c > byteNum then break end
      columnNum = 1 + byteNum - c
      lineNum = lineNum + 1
    end

    return columnNum, lineNum
  end
end

return lineposition


end)()

memo = (function()




local setmetatable, pack, unpack = setmetatable, table.pack, table.unpack

local function memo(func)

  local memo_input = intern()
  local memo_output = setmetatable({},{__mode='k'})

  return function( ... )
    local i = memo_input( ... )
    local v = memo_output[i]
    if not v then
      v = pack(func(...))
      memo_output[i] = v
    end
    return unpack(v)
  end
end

return memo


end)()

peg = (function()


-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! --

local deb_verbose = false
LOG = function(...)
  if not deb_verbose then return end
  io.write("#")
  local vp = require'valueprint'
  for k = 1, select('#',...) do
    local s = select(k, ...)
    io.write(" ",vp(s):gsub('\n','\n# '),'')
  end
  io.write("\n")
end

local function peg_pattern_matcher( pattern )
  pattern = '^(' .. pattern .. ')'
  result = function( DATA, CURR )
    LOG('trying pattern ', pattern, ' at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local d = DATA:sub( CURR )
    local m = d:match( pattern )
    if not m then return nil end
    return #m, {} -- TODO : do not return {} ???
  end

  return result
end

local function peg_alternation( alternatives )
  local np = #alternatives
  for p = 1, np do local P = alternatives[p] end
  return function( DATA, CURR )
    LOG('trying alternation at',DATA:sub(CURR or 1),'...')
    for p = 1, np do
      local m, r = alternatives[p]( DATA, CURR )
      if m then return m, { p, r } end
    end
    return nil, nil
  end
end

local function peg_sequence( sequence )
  local np = #sequence
  for p = 1, np do local P = sequence[p] end
  return function( DATA, CURR )
    LOG('trying sequence at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local OLD, ext = CURR, {}
    for p = 1, np do
      local m, r = sequence[p]( DATA, CURR )
      if not m then return nil, nil end
      CURR = CURR + m
      ext[1+#ext] = r
    end
    return CURR-OLD, ext
  end
end

local function peg_not( child_parser )
  return function( DATA, CURR )
    LOG('trying not-operator at',DATA:sub(CURR or 1),'...')
    local m, r = child_parser( DATA, CURR )
    if not m then return 0, {} end -- TODO : do not return {} ???
    return nil
  end
end

local function peg_empty( )
  return function( DATA, CURR )
    LOG('trying empty at',DATA:sub(CURR or 1),'...')
    return 0
  end
end

local function peg_repetition( child_parser, min, max )
  for _, x in ipairs{ min, max} do
    local xt = type(x)
    if ('number' ~= xt and 'nil' ~= xt)
    or ('number' == xt and 0 > x)
    or ('number' == xt and 0 ~= select(2, math.modf(x)))
    then error('second and third parameter of repetition must be nil, zero or a positive integer', 3) end
  end
  return function( DATA, CURR )
    LOG('trying repetition at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local OLD, ext, count = CURR, {}, 0
    while true do
      if max and max <= count then break end
      local m, r = child_parser( DATA, CURR )
      if not m then break end
      count = count + 1
      CURR = CURR + m
      ext[1+#ext] = r
    end
    if min and count < min then return nil, nil end
    return CURR-OLD, ext
  end
end

local function peg_check_no_consume( child_parser )
  return function( DATA, CURR )
    LOG('trying optional at',DATA:sub(CURR or 1),'...')
    local m, r = child_parser( DATA, CURR )
    if m then m = 0 end
    return m, r
  end
end

-- usability wrapper
local function peg_wrap( inner )
  return setmetatable({
    EXT = function(extra)
      local old = inner
      inner = not old and extra or function( d, c, ...)
        return extra( d, c, old( d, c, ...))
      end
    end
  },{
    __call = function( t, d, c, ...) return inner( d, c, ...) end,
    __add =  function(t,o) return peg_wrap( peg_sequence{ t, o }) end,
    __unm =  function(t)   return peg_wrap( peg_not( t )) end,
    __sub =  function(t,o) return peg_wrap( peg_sequence{t,peg_not(o)}) end,
    __div =  function(t,o) return peg_wrap( peg_alternation{t,o}) end,
    __bnot = function(t)   return peg_wrap( peg_check_no_consume(t)) end,
    __bxor = function(t,o) return peg_wrap( peg_sequence{t,peg_check_no_consume(o)}) end,
    __pow =  function(t,o)
      if 0 >  o then return peg_wrap( peg_repetition(t, 0, -o)) end
      if 0 <= o then return peg_wrap( peg_repetition(t, o, nil)) end
    end,
  })
end
local function peg_compose( base, extra )
  if '' == base then base = peg_wrap( peg_empty())
  elseif 'string' == type(base) then base = peg_wrap( peg_pattern_matcher(base))
  elseif nil == base then base = peg_wrap( extra)
  end
  if extra then
    base.EXT(extra)
  end
  return base
end

local function peg_operator_wrap( op )
  return function( ... ) return peg_wrap( op( ...)) end
end
return {
  COM = peg_compose, -- Only this is actually needed: the others can be generated with math operators
  EMP = peg_operator_wrap(peg_empty),
  PAT = peg_operator_wrap(peg_pattern_matcher),
  NOT = peg_operator_wrap(peg_not),
  SEQ = peg_operator_wrap(peg_sequence),
  ALT = peg_operator_wrap(peg_alternation),
  CHE = peg_operator_wrap(peg_check_no_consume),
  REP = peg_operator_wrap(peg_repetition),
}


end)()

get = (function()


local select = select
local pcall = pcall

local function get_rec(count, parent, child, ...)
  return count < 2 and parent or get_rec(count-1, parent[child], ...)
end

return function(...) -- get
  local ok, data = pcall(function(...)
    return get_rec(select('#', ...), ...)
  end, ...)
  local result = ok and data or nil
  return result, not ok and data or nil
end


end)()

lzw = (function()


local char = string.char
local merge = table.concat

local function clean_pad(str)
  str = str:gsub('\00*$','')
  if str == '' then str = '\00' end
  return str
end

local function re_pad(str, siz)
  str = clean_pad(str)
  str = str..(('\00'):rep(siz-#str))
  return str
end

local last_base_index = 255
local last_base_key = char(255)
local function new_dict()
  local dict = {}
  -- for single byte key, return the key itself. Any en/de-coder dict is
  -- assumed to contain the identity for the single byte keys.
  for k = 0, last_base_index do
    local b = char(k)
    dict[b] = b
  end
  return dict
end

-- Generate next coded sequence
local function next_index_string(prev)

  local key = {}

  local carry = 1
  for k = 1, #prev do
    if carry == 0 then
      key[k] = prev:sub(k,k)
    end
    local nc = prev:sub(k,k):byte() + carry
    if nc < 256 then
      key[k] = char(nc)
      carry = 0
    else
      key[k] = "\x00"
      if k == #prev then
        key[k+1] = "\x01"
      end
    end
  end

  return merge(key), #key
end

local function first_index_string()
  return next_index_string(last_base_key)
end

local function lzw(def)

  -- Option parse
  local dict_size = def and def.dict_size
  local enc_size = def and def.max_size

  -- ENCODER
  local lzw_encoder
  do
    -- initialization
    local dict = new_dict()
    local len = #last_base_key
    local encoded = first_index_string()
    local resultlen = 0
    local carry = ''
    local sequence = ''
    local dictcount = 0

    function lzw_encoder(input)

      if enc_size and enc_size < resultlen then
        return ''
      end

      -- calculate the tail (needed only if this is the last chunk)
      if input == nil then
        local write = dict[carry]
        return re_pad(write, len)
      end

      local result = {}

      -- process next part of input
      for i = 1, #input do

        -- read new chars and search for the shortest sequence non already in the dict ...
        local c = input:sub(i, i)
        sequence = carry..c
        if dict[sequence] then
            carry = sequence
        else
          -- ... found!

          -- get the coded sequence matching the read one
          local write = dict[carry]
          if not write then error('this should never happend') end
          write = re_pad(write, len)

          -- stop if the "Compressed string" is longer than the size guard
          resultlen = resultlen + #write
          if enc_size and enc_size < resultlen then
            break
          end

          -- emit the sequence
          result[#result+1] = write

          -- start a new compression block if the dict threshold was reached
          if dict_size then
            if dictcount >= dict_size then
              dictcount = 0
              dict = new_dict()
            end
            dictcount = dictcount + 1
          end

          -- generate a new dict entry with the new sequence, i.e. the shortest not already in the dict
          dict[sequence] = encoded
          len = #encoded
          encoded = next_index_string(encoded)

          -- the new char is the begin of the next sequence
          carry = c
        end
      end

      -- end
      return merge(result)
    end
  end

  -- DECODER
  local lzw_decoder
  do
    -- initialization
    local prev = ''
    local dict = new_dict()
    local len = #last_base_key
    local encoded = first_index_string()
    local carry = ''
    local dictcount = 0

    function lzw_decoder(input)
      local result = {}

      input = carry .. input -- TODO : avoid this ?

      local i = 1
      while i <= #input do

        -- read a number the byte indicated by the dict handler i.e. the dimension of the last created key
        local code = input:sub(i, i+len-1)
        i = i + len

        -- store partial key for the next input step
        carry = ''
        if #code < len then
          carry = code
          break
        end

        -- decode the read sequence
        code = clean_pad(code)
        local decoded = dict[code]
        local add_to_dict
        if decoded then
          add_to_dict = prev..decoded:sub(1, 1)
        else

          -- special case: this can happen only for encoded "ababa" sequencies
          -- a = single char, b = string, ab = alredy in dictionary, aba = not in dict
          add_to_dict = prev..prev:sub(1, 1)
          decoded = add_to_dict
        end
        result[#result+1] = decoded

        -- start a new decompression block if the dict threshold was reached
        if dict_size then
          if dictcount >= dict_size then
            dictcount = 0
            dict = new_dict()
          end
          dictcount = dictcount + 1
        end

        -- generate a new dict entry; skip the first time since the string is already in the base dict
        if prev ~= '' then
          dict[clean_pad(encoded)] = add_to_dict
          encoded = next_index_string(encoded)
        end
        len = #encoded

        prev = decoded or dict[code]
        if not prev then
          return nil, "invalid compressed data"
        end
      end
      return merge(result)
    end
  end

  return lzw_encoder, lzw_decoder
end

return lzw


end)()

return {
  appendfile = appendfile,
  argcheck = argcheck,
  bitpad = bitpad,
  clearfile = clearfile,
  cliparse = cliparse,
  combinetab = combinetab,
  copyfile = copyfile,
  countiter = countiter,
  csvish = csvish,
  csvishout = csvishout,
  deepsame = deepsame,
  differencetab = differencetab,
  escapeshellarg = escapeshellarg,
  filenamesplit = filenamesplit,
  flatarray = flatarray,
  hexdecode = hexdecode,
  hexencode = hexencode,
  intern = intern,
  intersecationtab = intersecationtab,
  iscallable = iscallable,
  isreadable = isreadable,
  jsonish = jsonish,
  jsonishout = jsonishout,
  keysort = keysort,
  lambda = lambda,
  localbind = localbind,
  locktable = locktable,
  logline = logline,
  pathpart = pathpart,
  simplepath = simplepath,
  rawhtml = rawhtml,
  rawmark = rawmark,
  readfile = readfile,
  searchluakeyword = searchluakeyword,
  serialize = serialize,
  sha2 = sha2,
  shellcommand = shellcommand,
  stepdebug = stepdebug,
  subbytebase = subbytebase,
  tapfail = tapfail,
  taptest = taptest,
  templua = templua,
  timeprof = timeprof,
  toposort = toposort,
  trimstring = trimstring,
  tuple = tuple,
  uniontab = uniontab,
  valueprint = valueprint,
  object = object,
  factory = factory,
  measure = measure,
  clone = clone,
  datestd = datestd,
  lineposition = lineposition,
  memo = memo,
  peg = peg,
  get = get,
  lzw = lzw,
}