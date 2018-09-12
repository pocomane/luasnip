local differencetab = require 'differencetab'
local t = require 'testhelper'

t( differencetab(), {}, t.deepsame )
t( differencetab({}), {}, t.deepsame )
t( differencetab({},{}), {}, t.deepsame )

t( differencetab({a='a'}), {a='a'}, t.deepsame )
t( differencetab({},{a='a'}), {}, t.deepsame )

t( differencetab({a='a'},{b='b'}), {a='a'}, t.deepsame )
t( differencetab({a='a'},{a='b'}), {}, t.deepsame )

t( differencetab({a='a',b='b',c='c'},{a='A',d='d'}), {b='b',c='c'}, t.deepsame )

t()
