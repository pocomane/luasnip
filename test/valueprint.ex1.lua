local valueprint = require "valueprint"
local t = require "testhelper"

t( valueprint(1), '1' )
t( valueprint(true), 'true' )
t( valueprint("hi"), '"hi"' )
t( valueprint({}), '^table 0?x?%x*$', t.patsame )
t( valueprint(nil), 'nil' )

t( type(valueprint({1,2})), 'string')
t( valueprint({1,2}) ~= '', true)

local x = ''
local function p(k,v,d)
  local y='<'..(k or 'nil')..'|'..v..'|'..d..'>'
  x=x..y
  return y
end

x = ''
local v = valueprint({{1,2},1,"a",nil,true,azk="a",bup={1,2}}, p)
t( v, x )
t( v, '^'..('<[^>]*>'):rep(11)..'$', t.patsame )
t( v, '<nil|table 0?x?%x*|0>', t.patsame )
t( v, '<1|table 0?x?%x*|1>', t.patsame )
t( v, '<1|1|2>', t.patsame )
t( v, '<2|2|2>', t.patsame )
t( v, '<2|1|1>', t.patsame )
t( v, '<3|"a"|1>', t.patsame )
t( v, '<5|true|1>', t.patsame )
t( v, '<"azk"|"a"|1>', t.patsame )
t( v, '<"bup"|table 0?x?%x*|1>', t.patsame )
t( v, '<1|1|2>', t.patsame )
t( v, '<2|2|2>', t.patsame )

local at = {}
at[1] = {}
at[1][1] = at[1]
at[1][at[1]]=true
local r = tostring(at):gsub(':','')
local r1 = tostring(at[1]):gsub(':','')

x = ''
local v = valueprint( at, p )
t( v, x )
t( v, '^'..('<[^>]*>'):rep(4)..'$', t.patsame )
t( v, '<nil|'..r..'|0>', t.patsame )
t( v, '<1|'..r1..'|1>', t.patsame )
t( v, '<1|'..r1..'|2>', t.patsame )
t( v, '<'..r1..'|true|2>', t.patsame )

t()

