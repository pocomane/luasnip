local serialize = require "serialize"
local t = require "testhelper"

local function reco( v )
  return load( 'return ' .. serialize( v ) )()
end

-- Simple values
t( reco( nil ), nil, t.deepsame )
t( reco( true ), true, t.deepsame )
t( reco( 1 ), 1, t.deepsame )
t( reco( "hi" ), "hi", t.deepsame )
t( reco( {} ), {}, t.deepsame )

t( serialize( "\n" ), '"\\n"' )
t( serialize( "\r" ), '"\\13"' )

-- Table with values
t( reco( { a = true, b = { "c", 1, { d = "e" } }, } ),
         { a = true, b = { "c", 1, { d = "e" } }, },
   t.deepsame )

-- Table table key
t( reco( { [ { ok = "ok" } ] = "ok", } ),
         { [ { ok = "ok" } ] = "ok", },
   t.deepsame )

-- Multiple table values
t( reco( { ["a"] = { [ "a" ] = "a", }, ["b"] = { [ "b" ] = "b", }, } ),
         { ["a"] = { [ "a" ] = "a", }, ["b"] = { [ "b" ] = "b", }, },
   t.deepsame )

-- Mixed key/value Table
t( reco( { ["ok"] = { [ { ok = "ok" } ] = "ok", }, } ),
         { ["ok"] = { [ { ok = "ok" } ] = "ok", }, },
   t.deepsame )

-- Sequence
t( reco( { 'a','b',{'c','d'},'e'} ),
         { 'a','b',{'c','d'},'e'},
   t.deepsame )

-- Sequence with holes
t( reco( { nil,nil,nil,'a',{'c','d'},} ),
         { nil,nil,nil,'a',{'c','d'},},
   t.deepsame )

-- Table with reference
local atab = { a = "a" }
t( reco( { atab, a = atab, } ),
         { atab, a = atab, },
   t.deepsame )

-- Sequence with tables
local atab = {}
t( reco( { 1, atab, 2, atab, 3,} ),
         { 1, atab, 2, atab, 3,},
   t.deepsame )

-- Table with cycle
atab = {}
atab.a = {}
atab.a.a = atab
t( reco( atab ), atab, t.deepsame )

-- Table with multiple cycle
atab = {}
atab.kv = {}
atab[atab.kv] = atab.kv
atab[atab.kv][atab.kv] = atab[atab.kv]
t( reco( atab ), atab, t.deepsame )

-- Too deep table
local cur = atab
for n = 1, 200 do
   cur.q = {}
   cur = cur.q
end
t( reco( atab ), atab, t.deepsame )

-- Output function
local atab = {'a',2,[{}]={},}
local exp = serialize(atab)
local got = ''
t( serialize(atab, function(d) got = got .. d end), nil )
t( got, exp )

t()

