local pegcore = require 'pegcore'
local t = require 'testhelper'

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

t( chca( "!!!", "uuu" ),               { false, true, '!!!' }, t.deepsame )
t( chca( "arule<-'u'", "u" ),          { false, true, '' },     t.deepsame )
t( chca( "toplevel<-'u'   !!!", "u" ), { false, true, '!!!' },  t.deepsame )

t( chca( "toplevel<-'u'", "u" ),   { tag="toplevel", "u", },     t.deepsame )
t( chca( "toplevel<-'u'", "xxx" ), nil )
t( chca( "toplevel<-'u'", "uu" ),  { tag="toplevel", "u", },     t.deepsame )
t( chca( "toplevel<-'u'", "" ),    nil )

t( chca( "toplevel<-'xyzzzz'", "xyzzzz" ),   { tag="toplevel", "xyzzzz", }, t.deepsame )
t( chca([[toplevel<-'%%']], "%"),            { tag="toplevel", "%", }, t.deepsame )
t( chca([[toplevel<-'%%']], "a"),            nil )
t( chca([[toplevel<-'.']], "a"),             { tag="toplevel", "a", }, t.deepsame)
t( chca([[toplevel<-'.']], "b"),             { tag="toplevel", "b", }, t.deepsame)
t( chca([[toplevel<-'x%\5C20y']], "x\\20y"), { tag="toplevel", "x\\20y", }, t.deepsame)

t( chca( "arule<-'u'   toplevel<-arule", "u" ), { tag="toplevel", "u" }, t.deepsame)
t( chca( "toplevel<-arule   arule<-'u'", "u" ), { tag="toplevel", "u" }, t.deepsame)

t( chca( "toplevel<-'a','b'", "ab" ), { tag="toplevel", {"a"}, {"b"}},    t.deepsame)
t( chca( "toplevel<-'a','b'", "ac" ), nil )
t( chca( "toplevel<-'a','b'", "a" ),  nil,  t.deepsame )
t( chca( "toplevel<-'a','b'", "b" ),  nil,  t.deepsame )
t( chca( "toplevel<-'a','b','c'", "abc" ),  { tag="toplevel", {"a"}, {"b"}, {"c"}},  t.deepsame )

t( chca( "toplevel<-'a'/'b'", "a" ),     { tag="toplevel", selected=1, {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'/'b'", "b" ),     { tag="toplevel", selected=2, {"b"}},   t.deepsame )
t( chca( "toplevel<-'a'/'b'/'c'", "c" ), { tag="toplevel", selected=3, {"c"}}, t.deepsame )
t( chca( "toplevel<-'a'/'b'", "c" ), nil )

t( chca( "toplevel<-'a'+", "a" ),   { tag="toplevel", {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'+", "aa" ),  { tag="toplevel", {"a"}, {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'+", "aaa" ), { tag="toplevel", {"a"}, {"a"}, {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'+", "" ),   nil )
t( chca( "toplevel<-'a'+", "b" ),  nil )

t( chca( "na<-!'a'   toplevel<-na,'b'", "b" ),                  { tag="toplevel", { tag="na" }, {"b"}},      t.deepsame )
t( chca( "na<-!'a'   nb<-!'b'   toplevel<-na , nb, 'c'", "c" ), { tag="toplevel", { tag="na" }, { tag="nb" }, {"c"}},      t.deepsame )
t( chca( "toplevel<-!'a'", "a" ),                               nil )
t( chca( "na<-!'a'   toplevel<-na,'b'", "ab" ),                 nil )

t( chca( "toplevel<-~", "a" ), { tag="toplevel" }, t.deepsame )

t( chca( "toplevel<-('a','b')", "ab" ), { tag="toplevel", {"a"}, {"b"} }, t.deepsame )

t( chca( "toplevel<-('a'/'b'),'c'", "ac" ), { tag="toplevel", { tag="a1", selected=1, {"a"}}, {"c"}},   t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "bc" ), { tag="toplevel", { tag="a2", selected=2, {"b"}}, {"c"}},   t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "c" ),  nil )
t( chca( "toplevel<-('a'/'b'),'c'", "a" ),  nil )
t( chca( "toplevel<-('a'/'b'),'c'", "b" ),  nil )

t( chca( "toplevel<-'a'/('b','c')", "a" ),   { tag="toplevel", selected=1, {"a"}},   t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "bc" ),  { tag="toplevel", selected=2, { tag="s", {"b"}, {"c"}}},   t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "b" ),   nil )
t( chca( "toplevel<-'a'/('b','c')", "c" ),   nil )
t( chca( "toplevel<-'a'/('b','c')", "abc" ), { tag="toplevel", selected=1, {"a"}}, t.deepsame )

t( chca( "toplevel<-!('a'/'b')", "a" ), nil )
t( chca( "toplevel<-!('a'/'b')", "b" ), nil )
t( chca( "toplevel<-!('a'/'b')", "c" ), { tag="toplevel", },  t.deepsame )

t( chca( "toplevel<-('a'/'b')+", "aa" ),  { tag="toplevel", { tag="a1", selected=1, {"a"}}, { tag="a1", selected=1, {"a"}}},   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "bb" ),  { tag="toplevel", { tag="a2", selected=2, {"b"}}, { tag="a2", selected=2, {"b"}}},   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "baa" ), { tag="toplevel", { tag="a2", selected=2, {"b"}}, { tag="a1", selected=1, {"a"}}, { tag="a1", selected=1, {"a"}}},   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "c" ),   nil )

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

-----------------------------------------------------------------------

t( chca( "toplevel<-'a'*", "" ),    { tag="toplevel", }, t.deepsame )
t( chca( "toplevel<-'a'*", "a" ),   { tag="toplevel", {"a"}}, t.deepsame )
t( chca( "toplevel<-'a'*", "aa" ),  { tag="toplevel", {"a"}, {"a"} }, t.deepsame )
t( chca( "toplevel<-'a'*", "aaa" ), { tag="toplevel", {"a"}, {"a"}, {"a"} }, t.deepsame )
t( chca( "toplevel<-'a'*", "aba" ), { tag="toplevel", {"a"} }, t.deepsame )
t( chca( "toplevel<-'a'*", "b" ),   { tag="toplevel", }, t.deepsame )

t( chca( "toplevel<-'a'?", "" ),   { tag="toplevel", selected=2, { tag="e" }}, t.deepsame )
t( chca( "toplevel<-'a'?", "a" ),  { tag="toplevel", selected=1, {"a"}}, t.deepsame )
t( chca( "toplevel<-'a'?", "aa" ), { tag="toplevel", selected=1, {"a"}}, t.deepsame )
t( chca( "toplevel<-'a'?", "b" ),  { tag="toplevel", selected=2, { tag="e" }}, t.deepsame )

t( chca( "a<-&'a'   toplevel<-a,'a'", "a" ), { tag="toplevel", {tag="a"}, {"a"}}, t.deepsame )
t( chca( "a<-&'a'   toplevel<-a,'b'", "b" ), nil )

-- & precedence over ,
t( chca( "toplevel<-&'a','a'", "a" ),        { tag="toplevel", { tag="n" }, {"a"}}, t.deepsame )
t( chca( "a<-'a','a'   toplevel<-&a", "a" ), nil )

-- whitespace
t( chca( " x <- 'x' \n toplevel <- 'a' / x / ! 'b' / 'c' * / ~ / ( 'd' ) ",  "a" ), { tag="toplevel", selected=1, {"a"}}, t.deepsame )

t.test_embedded_example()

t()
