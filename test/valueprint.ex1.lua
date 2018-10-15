local valueprint = require "valueprint"
local t = require "testhelper"

t( valueprint(1), '1' )
t( valueprint(true), 'true' )
t( valueprint("hi"), '"hi"' )
t( valueprint({}), '^table 0?x?%x*$', t.patsame )
t( valueprint(nil), 'nil' )

t( valueprint({1,2}), '^table 0?x?%x*\n| 1: 1\n| 2: 2$' , t.patsame )
t( valueprint({a="b",c="d"}), '^table 0?x?%x*\n.*| "a": "b"' , t.patsame )
t( valueprint({a="b",c="d"}), '^table 0?x?%x*\n.*| "c": "d"' , t.patsame )
t( valueprint({a={b="c"}}), '^table 0?x?%x*\n| "a": table 0?x?%x*\n| | "b": "c"$' , t.patsame )

local at = {}
at[1] = {}
at[1][1] = at[1]
at[1][at[1]]=true
local r = tostring(at):gsub(':','')
local r1 = tostring(at[1]):gsub(':','')

local v = valueprint( at )
t( v, '^'
    .."table 0?x?%x*\n"
    .."| 1: (table 0?x?%x*)\n"
    .."| | 1: %1\n"
    .."| | %1: true"
    ..'$', t.patsame )

local function p(k,v,d,i)
  local y = '<'..(k or 'nil')..'|'..v..'|'..d..'|'..i..'>'
  x = x..y
  return y
end

x = ''
local v = valueprint({101,102,{b="c"},true,x=nil}, p)
t( v, x )

t( v, '^'
    ..'<nil|(table 0?x?%x*)|1|in>'
    ..'<1|101|1|number>'
    ..'<2|102|1|number>'
    ..'<3|(table 0?x?%x*)|1|table>'
    ..'<nil|%2|2|in>'
    ..'<"b"|"c"|2|string>'
    ..'<nil|%2|2|out>'
    ..'<4|true|1|boolean>'
    ..'<nil|%1|1|out>'
    ..'$', t.patsame )

t()

