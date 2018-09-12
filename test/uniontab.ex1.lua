local uniontab = require 'uniontab'
local t = require 'testhelper'

t( uniontab(), {}, t.deepsame )
t( uniontab({}), {}, t.deepsame )
t( uniontab({},{}), {}, t.deepsame )

t( uniontab({a='a'}), {a='a'}, t.deepsame )
t( uniontab({},{a='a'}), {a='a'}, t.deepsame )

t( uniontab({a='a'},{b='b'}), {a='a',b='b'}, t.deepsame )
t( uniontab({a='a'},{a='b'}), {a='a'}, t.deepsame )

t( uniontab({a='a'},{a='b'},function(a,b) return a..b end), {a='ab'}, t.deepsame )

t( uniontab({a='a',b='b',c='c'},{a='A',d='d'}), {a='a',b='b',c='c',d='d'}, t.deepsame )

t()
