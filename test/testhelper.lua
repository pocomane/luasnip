--[===[DOC

= testhelper

These function are reported only as internal reference. They are not really
part of LuaSnip, but they are used e.g. in tests and documentation examples.

]===]

local t = require 'taptest'
local v = require 'valueprint'
local d = require 'deepsame'

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

setmetatable( th, {__call = function( s, ... )
  local taptest_blame_caller = true
  local r = t( ... )
  print(r)
  return r
end})

return th
