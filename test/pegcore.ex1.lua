local peg = require 'pegcore'
local t = require 'testhelper'

local P, N, S, A, Z, E, O, M, C =
  peg.PAT, peg.NOT, peg.SEQ, peg.ALT, peg.ZER, peg.EMP, peg.ONE, peg.OPT, peg.CHE
local COM = peg.COM

t( P('u') ('u'),  1)
t( P('u') ('u'),  1)
t( P('u') ('x'),  nil)
t( P('u') ('xx'), nil)
local _, a = P("u")("x")
local _, b = P("u")("u")
t( a, nil, t.deepsame)
t( b, {}, t.deepsame)

t( P('xyzzzz')   ('xyzzzz'), 6)
t( P('%%')       ('%'),      1)
t( P('%%')       ('a'),      nil)
t( P('.')        ('a'),      1)
t( P('.')        ('b'),      1)
t( P('x\x5C20y') ('x\\20y'), 5)

local G = N(P'a')
t( G ("ab"), nil )
t( G ("ba"), 0 )
local G = -P'a'
t( G ("ab"), nil )
t( G ("ba"), 0 )
local _, a = G('x')
local _, b = G('a')
t( a, {}, t.deepsame)
t( b, nil, t.deepsame)

local G = S{ P('a'), P('b'), }
t( G('ab'),  2)
t( G('ac'),  nil)
t( G('a'),   nil)
t( G('b'),   nil)
t( G('abb'), 2)
local G = P'a' + P'b'
t( G('ab'),  2)
t( G('ac'),  nil)
t( G('a'),   nil)
t( G('b'),   nil)
t( G('abb'), 2)
local _, a = G('ab')
local _, b = G('ba')
t( a, {{},{}}, t.deepsame)
t( b, nil, t.deepsame)

local G = P'a' - P'b'
t( G('ab'),  nil)
t( G('ac'),  1)
t( G('a'),   1)
t( G('b'),   nil)
t( G('abb'), nil)
local _, a = G('ac')
local _, b = G('ab')
t( a, {{},{}}, t.deepsame)
t( b, nil, t.deepsame)

local G = A{ P'a', P'b', }
t( G('a'),  1)
t( G('b'),  1)
t( G('ab'), 1)
t( G('c'),  nil)
t( A{ P'a', P'b', P'c',} ('c'),  1)
local G = P'a' / P'b'
t( G('a'),  1)
t( G('b'),  1)
t( G('ab'), 1)
t( G('c'),  nil)
t( A{ P'a', P'b', P'c',} ('c'),  1)
local _, a = G('ac')
local _, b = G('bc')
local _, c = G('cc')
t( a, {1, {}}, t.deepsame)
t( b, {2, {}}, t.deepsame)
t( c, nil, t.deepsame)

local G = Z(P'a')
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     0)
t( G('ab'),   1)
t( G('ba'),   0)
local G = P'a' ^0
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     0)
t( G('ab'),   1)
t( G('ba'),   0)
local _, a = G('c')
local _, b = G('ac')
local _, c = G('aac')
t( a, {}, t.deepsame)
t( b, {{}}, t.deepsame)
t( c, {{},{}}, t.deepsame)

t( E() ("ab"), 0 )
t( E() (""), 0 )
local _, a = G('c')
t( a, {}, t.deepsame)

local G = S{A{P'a',P'b'},P'c'}
t( G ("ac"), 2 )
t( G ("bc"), 2 )
t( G ("c"),  nil )
t( G ("a"),  nil )
t( G ("b"),  nil )

local G = A{P'a',S{P'b',P'c'}}
t( G ("a"),   1)
t( G ("bc"),  2)
t( G ("b"),   nil)
t( G ("c"),   nil)
t( G ("abc"), 1)

local G = N(A{P'a',P'b'})
t( G ("a"), nil)
t( G ("b"), nil)
t( G ("c"), 0)

local G = Z(A{P'a',P'b'})
t( G ("aa"),  2)
t( G ("bb"),  2)
t( G ("baa"), 3)
t( G ("c"),   0)

local G = O(P'a')
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     nil)
t( G('ab'),   1)
t( G('ba'),   nil)
local G = P'a' ^1
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     nil)
t( G('ab'),   1)
t( G('ba'),   nil)
local _, a = G('c')
local _, b = G('ac')
local _, c = G('aac')
t( a, nil, t.deepsame)
t( b, {{}}, t.deepsame)
t( c, {{},{}}, t.deepsame)

local G = M(P'a')
t( G(''),   0)
t( G('a'),  1)
t( G('aa'), 1)
t( G('b'),  0)
local G = P'a' ^-1
t( G(''),   0)
t( G('a'),  1)
t( G('aa'), 1)
t( G('b'),  0)
local _, a = G('c')
local _, b = G('ac')
local _, c = G('aac')
t( a, {}, t.deepsame)
t( b, {}, t.deepsame)
t( c, {}, t.deepsame)

local G = C(P'a')
t( G('a'), 0)
t( G('b'), nil)
local G = ~P'a'
t( G('a'), 0)
t( G('b'), nil)
local _, a = G('a')
local _, b = G('b')
t( a, {}, t.deepsame)
t( b, nil, t.deepsame)

local G = P'b' ~ P'a'
t( G('ba'), 1)
t( G('bc'), nil)

local G = COM'' -- same as E()
t( G('ab'), 0 )
t( G(''), 0 )
local _, a = G('c')
t( a, nil, t.deepsame)

local G = COM'a' -- same as P'a'
t( G('a'), 1)
t( G('b'), nil)
local _, a = G('a')
local _, b = G('b')
t( a, {}, t.deepsame)
t( b, nil, t.deepsame)

local G = P'b'
COM(G, P'a') -- replace
t( G('a'), 1)
t( G('b'), nil)
local _, a = G('a')
local _, b = G('b')
t( a, {}, t.deepsame)
t( b, nil, t.deepsame)

local GC = P'a'
local G = COM()
COM(G, S{GC, M(G)}) -- recursive definition for G
t( G('b'), nil)
t( G('a'), 1)
t( G('aa'), 2)
t( G('aab'), 2)
t( G('aaa'), 3)
local _, a = G('a')
local _, b = G('aab')
t( a, {{},{}}, t.deepsame)
t( b, {{},{{},{}}}, t.deepsame)

local check
local function ext(...) check = {...} return 'ok' end

local G = P'a'
COM(G, ext)
t( G('a'), 'ok')
t( check, {'a', nil, 1, {}}, t.deepsame)
t( G('b'), 'ok')
t( check, {'b'}, t.deepsame)
local G = P'a'
G.EXT(ext)
t( G('a'), 'ok')
t( check, {'a', nil, 1, {}}, t.deepsame)
t( G('b'), 'ok')
t( check, {'b'}, t.deepsame)

-----------------------------------------------------------------------------------

-- TODO : move the rest somewhere else ! (maybe remove?)

local pegcore = peg.pegcore

local function chca( peg_rule_str, text, callb )
  local a, b = pegcore(peg_rule_str,callb)
  local CURR, ast
  if a ~= #peg_rule_str then
    CURR, ast = a, nil, b
  else
    CURR, ast = a, b
  end
  local POS = CURR and CURR+1 or 1
  if not CURR or not ast or not ast.func then
    return {false, CURR~=nil, peg_rule_str:sub( POS )}, ast, "bad"
  end
  return (function(a,b,...) return b,a,... end) (ast.func(text))
end

-----------------------------------------------------------------------

-- grammar
t( chca( "!!!", "uuu" ),               { false, true, '!!!' }, t.deepsame )
t( chca( "arule<-'u'", "u" ),          { false, true, '' },     t.deepsame )
t( chca( "toplevel<-'u'   !!!", "u" ), { false, true, '!!!' },  t.deepsame )
t( chca( "arule<-'u'   toplevel<-arule", "u" ), { tag="toplevel", "u" }, t.deepsame)
t( chca( "toplevel<-arule   arule<-'u'", "u" ), { tag="toplevel", "u" }, t.deepsame)
t( chca( "toplevel<-('a','b')", "ab" ), { tag="toplevel", {"a"}, {"b"} }, t.deepsame )

-- captures
t( chca( "a<-'a'+   toplevel<-a,'b',:a", "aabaaa" ),  { tag="toplevel", {tag='a',{"a"},{"a"}}, {"b"}, {tag='c',"aa"}},   t.deepsame )
t( chca( "a<-'a'+   toplevel<-a,'b',:a", "aaba" ),  nil,   t.deepsame )

-- undefined capture
t( chca( "toplevel<-'b',:a,'b'", "bb" ), { tag="toplevel", {"b"}, {tag="e"}, {"b"}}, t.deepsame )
t( chca( "a<-'a'   toplevel<-'b',:a,'b'", "bb" ), { tag="toplevel", {"b"}, {tag="e"}, {"b"}}, t.deepsame )

-- multiple captures
t( chca( "a<-'a'   b<-'b'   toplevel<-a,b,:a,:b", "abab" ),  { tag="toplevel", {tag='a',"a"}, {tag="b","b"}, {tag='c',"a"}, {tag='c',"b"}},   t.deepsame )

-----------------------------------------------------------------------

-- + precedence over /
t( chca( "toplevel<-'a'+/'b'", "aa" ), { tag="toplevel", selected=1, { tag="o", {"a"}, {"a"}}},   t.deepsame )
t( chca( "toplevel<-'a'/'b'+", "a" ),  { tag="toplevel", selected=1, {"a"}}, t.deepsame )
t( chca( "toplevel<-'a'/'b'+", "bb" ), { tag="toplevel", selected=2, { tag="o", {"b"}, {"b"}}},   t.deepsame )

-- ! precedence over /
t( chca( "toplevel<-!'a'/'a'", "a" ),        { tag="toplevel", selected=2, {"a"}},     t.deepsame )
t( chca( "a<-'a'/'a'   toplevel<-!a", "a" ), nil )

-- + precedence over !
t( chca( "toplevel<-!'a'+", "bb" ), { tag="toplevel", }, t.deepsame )
t( chca( "toplevel<-!'a'+", "aa" ), nil )

-- ~ precedence over /
t( chca( "toplevel<-'a'/~", "a" ), { tag="toplevel", selected=1, {"a"}},  t.deepsame )
t( chca( "toplevel<-'a'/~", "" ),  { tag="toplevel", selected=2, { tag="e" }},  t.deepsame )
t( chca( "toplevel<-~/'a'", "" ),  { tag="toplevel", selected=1, { tag="e" }},  t.deepsame )
t( chca( "toplevel<-~/'a'", "a" ), { tag="toplevel", selected=1, { tag="e" }}, t.deepsame )

-- , precedence over /
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "ab" ),  { tag="toplevel", selected=1, { tag="s", {"a"}, {"b"}}},   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "c" ),   { tag="toplevel", selected=2, {"c"}},   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "de" ),  { tag="toplevel", selected=3, { tag="s", {"d"},{"e"}}},   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "abe" ), { tag="toplevel", selected=1, { tag="s", {"a"},{"b"}}},  t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "bcd" ), { tag="toplevel", selected=2, {tag="s", {"b"}, {"c"}, {"d"}}},   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "a" ),   { tag="toplevel", selected=1, {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "e" ),   { tag="toplevel", selected=3, {"e"}},   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "ace" ), { tag="toplevel", selected=1, {"a"}}, t.deepsame )

-- & precedence over ,
t( chca( "toplevel<-&'a','a'", "a" ),        { tag="toplevel", { tag="n" }, {"a"}}, t.deepsame )
t( chca( "a<-'a','a'   toplevel<-&a", "a" ), nil )

-- whitespace
t( chca( " x <- 'x' \n toplevel <- 'a' / x / ! 'b' / 'c' * / ~ / ( 'd' ) ",  "a" ), { tag="toplevel", selected=1, {"a"}}, t.deepsame )

t.test_embedded_example()

t()
