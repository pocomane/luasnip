local pegcore = require 'pegcore'
local t = require 'testhelper'

local P, S, A, Z, N, E = peg.PAT, peg.SEQ, peg.ALT, peg.ZER, peg.NOT, peg.EMP

t( P('u') ('u'),  1)
t( P('u') ('u'),  1)
t( P('u') ('x'),  nil)
t( P('u') ('xx'), nil)

t( P('xyzzzz')   ('xyzzzz'), 6)
t( P('%%')       ('%'),      1)
t( P('%%')       ('a'),      nil)
t( P('.')        ('a'),      1)
t( P('.')        ('b'),      1)
t( P('x\x5C20y') ('x\\20y'), 5)

local G = S{ P('a'), P('b'), }
t( G('ab'),  2)
t( G('ac'),  nil)
t( G('a'),   nil)
t( G('b'),   nil)
t( G('abb'), 2)

local G = A{ P'a', P'b', }
t( G('a'),  1)
t( G('b'),  1)
t( G('ab'), 1)
t( G('c'),  nil)
t( A{ P'a', P'b', P'c',} ('c'),  1)

local G = Z(P'a')
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     0)
t( G('ab'),   1)
t( G('ba'),   0)

local G = N(P'a')
t( G ("ab"), nil )
t( G ("ba"), 0 )

t( E() ("ab"), 0 )
t( E() (""), 0 )

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

local function O(p) return S{p,Z(p)} end

local G = O(P'a')
t( G('a'),    1)
t( G('aa'),   2)
t( G('aaa'),  3)
t( G(''),     nil)
t( G('ab'),   1)
t( G('ba'),   nil)

local function M(p) return A{p,E()} end

local G = M(P'a')
t( G(''),   0)
t( G('a'),  1)
t( G('aa'), 1)
t( G('b'),  0)

local function C(p) return N(N(p)) end

local G = C(P'a')
t( G('a'), 0)
t( G('b'), nil)

-- TODO : move the rest somewhere else ! (maybe remove?)

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
