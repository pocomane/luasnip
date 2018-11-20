--[===[DOC

= testhelper

These function are reported only as internal reference. They are not really
part of LuaSnip, but they are used e.g. in tests and documentation examples.

]===]

local t = (function()
-- [SNIP:taptest.lua[
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
-- ]SNIP:taptest.lua]
end)()

local v = (function()
-- [SNIP:valueprint.lua[
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
-- ]SNIP:valueprint.lua]
end)()

local d = (function()
-- [SNIP:deepsame.lua[
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
-- ]SNIP:deepsame.lua]
end)()

local th = {}

function th.diff( a, b )
  if a ~= b then return true end
  return false, tostring(a)..' VS '..tostring(b)
end

function th.deepsame( a, b )
  local s = d( a, b )
  if s then return true end
  local s, i = pcall(function() return '\n' .. v(a) .. '\nVS\n' .. v(b) end)
  return false, s and i or nil
end

local function h(x)
  return x:gsub( ".", function( c )
    return string.format( "%02X", string.byte( c ))
  end)
end

function th.bytesame(a,b)
  if a == b then return true end
  return false, h(a)..' VS '..h(b)
end

function th.hexsame(a,b)
  a = h(a)
  if a == b then return true end
  return false, a..' VS '..b
end

function th.patsame(a,b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= 'string' and a == b then return true end
  if type(a) == 'string' and a:match(b) then return true end
  return false, '['..tostring(a)..'] VS %['..tostring(b)..']'
end

function th.itemorder(t,d)
  local a,b = d[1],d[2]
  local a_seen = false
  local b_seen = false
  for i,v in ipairs(t) do
    if v == a then a_seen = i end
    if v == b then b_seen = i end
  end
  if a_seen and b_seen and a_seen<b_seen then return true end
  return false, 'Invalid order '..tostring(d[1])..' should came before '..tostring(d[2])..': '..v(t)
end


function th.readfile( path ) 
  local f = io.open( path, 'rb' )
  if not f then return nil end
  local r = f:read( '*a' )
  f:close()
  return r
end

function th.writefile( path, data ) 
  local f = io.open( path, 'wb' )
  if not f then
    t( '', '', function() return false, 'Test setup failed, do not trust next tests' end )
  end
  f:write( data )
  f:close()
  if data ~= th.readfile( path ) then
    t( '', '', function() return false, 'Test setup failed, do not trust next tests' end )
  end
end

function th.removefile( path )
  os.remove( path )
  if nil ~= th.readfile( path ) then
    t( '', '', function() return false, 'Test setup failed, do not trust next tests' end )
  end
end

local lua_cmd
do
  local a = 1
  while true do
    a = a -1
    if not arg[a] then break end
    lua_cmd = arg[a]
  end
end
function th.luacommand() return lua_cmd end

function th.argdumputil()
  local scr, out = 'tmp_shcompare_0.lua', 'tmp_shcompare_1.txt'
  th.writefile( scr, [[
    local r = ''
    local a = 0
    local o = io.open( ']]..out..[[', 'wb' )
    while true do
      a = a + 1
      local d = arg[a]
      if not d then break end
      if d == '-i' then
        local x = io.read('a')
        o:write(x)
        r = r .. x 
      elseif d == '-e' then
        io.stderr:write(r)
        r = ''
      elseif d == '-o' then
        io.write(r)
        r = ''
      else
        o:write(d)
        r = r .. d
      end
    end
    o:close()
  ]] )
  return th.luacommand(), scr, out
end

function th.filterr(func,...)
  local ok, err = pcall(func, ...)
  if ok then return nil end
  return err:gsub('^[^:]*:[^:]*: ','')
end

function th.type(a,b)
  if type(a) == b then return true end
  return false, type(a)..' VS '..b
end

function th.wait(s)
  local c = os.clock()
  while os.clock()-c < s do end
end

function th.number_tollerance( eps )
  return function(a, b)
    local d = a - b
    if d < 0 then d = -d end
    if d <= eps then return true end
    return false, a..' VS '..b
  end
end


function th.embedded_example_fail()

  local path = debug.getinfo(2).source
  path = path:sub(2)
  path = path:gsub('test([/\\])','src%1')
  path = path:gsub('%.ex.%.','.')

  local f, err = io.open(path,'rb')
  if not f or err then
    return 'Can not find module file "'..path..'"\n'
  end

  local src, err = f:read('a')
  if not src or err then return err end

  local function clearsrc(str,pat)
    local result = ''
    local last = 1
    for a, b, c in str:gmatch(pat) do
      result = result
        .. str:sub(last,b-1):gsub('[^\r\n]',' ')
        .. str:sub(b,c-1)
      last = c
    end
    result = result .. str:sub(last):gsub('[^\r\n]',' ')
    return result
  end

  src = clearsrc(src, '%-%-%[(=*)%[DOC().-()%]%1]')
  src = clearsrc(src, '%[source,lua,example%][\r\n]*(%-+)()[^%-].-()%1')

  local func, err = load(src,path,'t')
  if not func or err then return err end

  -- Check if there is some code (No empty src)
  local lineofcode = 0
  for _, v in pairs(debug.getinfo(func, 'L').activelines) do
    if v then lineofcode = lineofcode + 1 end
  end

  if lineofcode < 2 then
    return 'No valid example code in '..path
  end

  ok, err = pcall(func)
  return err
end

setmetatable( th, {__call = function( s, ... )
  local taptest_blame_caller = true
  local r = t( ... )
  print(r)
  return r
end})

return th
