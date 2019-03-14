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
    return {false, CURR~=nil, peg_rule_str:sub( POS )}, ast
  end
  local c, a = ast.func(text)
  local p = c and c+1 or 1
  return {true, c~=nil, text:sub( p )}, a
end

t( chca( "!!!", "uuu" ),               { false, true, '!!!' }, t.deepsame )
t( chca( "arule<-'u'", "u" ),          { false, true, '' },     t.deepsame )
t( chca( "toplevel<-'u'   !!!", "u" ), { false, true, '!!!' },  t.deepsame )

t( chca( "toplevel<-'u'", "u" ),   { true, true, '' },     t.deepsame )
t( chca( "toplevel<-'u'", "xxx" ), { true, false, 'xxx' }, t.deepsame )
t( chca( "toplevel<-'u'", "uu" ),  { true, true, 'u' },    t.deepsame )
t( chca( "toplevel<-'u'", "" ),    { true, false, '' },    t.deepsame )

t( chca("toplevel<-'xyzzzz'", "xyzzzz"),  { true,true,'' }, t.deepsame)
t( chca([[toplevel<-'x\20y']], "x\x20y"), { true,true,'' }, t.deepsame)

t( chca( "arule<-'u'   toplevel<-arule", "u" ), { true, true, '' }, t.deepsame)
t( chca( "toplevel<-arule   arule<-'u'", "u" ), { true, true, '' }, t.deepsame)

t( chca( "toplevel<-'a','b'", "ab" ), { true, true, '' },    t.deepsame)
t( chca( "toplevel<-'a','b'", "ac" ), { true, false, 'ac' }, t.deepsame )
t( chca( "toplevel<-'a','b'", "a" ),  { true, false, 'a' },  t.deepsame )
t( chca( "toplevel<-'a','b'", "b" ),  { true, false, 'b' },  t.deepsame )

t( chca( "toplevel<-'a'/'b'", "a" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b'", "b" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b'", "c" ), { true, false, 'c' }, t.deepsame )

t( chca( "toplevel<-'a'+", "a" ),  { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'+", "aa" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'+", "" ),   { true, false, '' },  t.deepsame )
t( chca( "toplevel<-'a'+", "b" ),  { true, false, 'b' }, t.deepsame )

t( chca( "na<-!'a'   toplevel<-na,'b'", "b" ),                  { true, true, '' },      t.deepsame )
t( chca( "na<-!'a'   nb<-!'b'   toplevel<-na , nb, 'c'", "c" ), { true, true, '' },      t.deepsame )
t( chca( "toplevel<-!'a'", "a" ),                               { true, false, 'a' },    t.deepsame )
t( chca( "na<-!'a'   toplevel<-na,'b'", "ab" ),                 { true, false, 'ab' },   t.deepsame )

t( chca( "toplevel<-~", "a" ), { true, true, "a" }, t.deepsame )

t( chca( "toplevel<-('a','b')", "ab" ), { true, true, '' }, t.deepsame )

t( chca( "toplevel<-('a'/'b'),'c'", "ac" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "bc" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "c" ),  { true, false, 'c' }, t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "a" ),  { true, false, 'a' }, t.deepsame )
t( chca( "toplevel<-('a'/'b'),'c'", "b" ),  { true, false, 'b' }, t.deepsame )

t( chca( "toplevel<-'a'/('b','c')", "a" ),   { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "bc" ),  { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "b" ),   { true, false, 'b' }, t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "c" ),   { true, false, 'c' }, t.deepsame )
t( chca( "toplevel<-'a'/('b','c')", "abc" ), { true, true, 'bc' }, t.deepsame )

t( chca( "toplevel<-!('a'/'b')", "a" ), { true, false, 'a' }, t.deepsame )
t( chca( "toplevel<-!('a'/'b')", "b" ), { true, false, 'b' }, t.deepsame )
t( chca( "toplevel<-!('a'/'b')", "c" ), { true, true, 'c' },  t.deepsame )

t( chca( "toplevel<-('a'/'b')+", "aa" ),     { true, true, '' },   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "bb" ),     { true, true, '' },   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "baabba" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-('a'/'b')+", "c" ),      { true, false, 'c' }, t.deepsame )

-- + precedence over /
t( chca( "toplevel<-'a'+/'b'", "aa" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b'+", "a" ),  { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b'+", "bb" ), { true, true, '' },   t.deepsame )

-- ! precedence over /
t( chca( "toplevel<-!'a'/'a'", "a" ),        { true, true, '' },     t.deepsame )
t( chca( "a<-'a'/'a'   toplevel<-!a", "a" ), { true, false, 'a' },   t.deepsame )

-- ~ precedence over /
t( chca( "toplevel<-'a'/~", "a" ), { true, true, '' },  t.deepsame )
t( chca( "toplevel<-'a'/~", "" ),  { true, true, '' },  t.deepsame )
t( chca( "toplevel<-~/'a'", "" ),  { true, true, '' },  t.deepsame )
t( chca( "toplevel<-~/'a'", "a" ), { true, true, 'a' }, t.deepsame )

-- , precedence over /
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "ab" ),  { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "c" ),   { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "de" ),  { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a','b'/'c'/'d','e'", "abe" ), { true, true, 'e' },  t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "bcd" ), { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "a" ),   { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "e" ),   { true, true, '' },   t.deepsame )
t( chca( "toplevel<-'a'/'b','c','d'/'e'", "ace" ), { true, true, 'ce' }, t.deepsame )

-----------------------------------------------------------------------

t( chca( "toplevel<-'a'*", "" ),   { true, true, '' }, t.deepsame )
t( chca( "toplevel<-'a'*", "a" ),  { true, true, '' }, t.deepsame )
t( chca( "toplevel<-'a'*", "aa" ), { true, true, '' }, t.deepsame )
t( chca( "toplevel<-'a'*", "b" ),  { true, true, 'b' }, t.deepsame )

t( chca( "toplevel<-'a'?", "" ),   { true, true, '' }, t.deepsame )
t( chca( "toplevel<-'a'?", "a" ),  { true, true, '' }, t.deepsame )
t( chca( "toplevel<-'a'?", "aa" ), { true, true, 'a' }, t.deepsame )
t( chca( "toplevel<-'a'?", "b" ),  { true, true, 'b' }, t.deepsame )

t( chca( "a<-&'a'   toplevel<-a,'a'", "a" ), { true, true, '' }, t.deepsame )
t( chca( "a<-&'a'   toplevel<-a,'b'", "b" ), { true, false, 'b' }, t.deepsame )

-- & precedence over ,
t( chca( "toplevel<-&'a','a'", "a" ),        { true, true, '' }, t.deepsame )
t( chca( "a<-'a','a'   toplevel<-&a", "a" ), { true, false, 'a' }, t.deepsame )

-- whitespace
t( chca( " x <- 'x' \n toplevel <- 'a' / x / ! 'b' / 'c' * / ~ / ( 'd' ) ",  "a" ), { true, true, '' }, t.deepsame )

t.test_embedded_example()

t()
