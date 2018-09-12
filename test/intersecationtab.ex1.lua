local intersecationtab = require 'intersecationtab'
local t = require 'testhelper'

t( intersecationtab(), {}, t.deepsame )
t( intersecationtab({}), {}, t.deepsame )
t( intersecationtab({},{}), {}, t.deepsame )

t( intersecationtab({a='a'}), {}, t.deepsame )
t( intersecationtab({},{a='a'}), {}, t.deepsame )

t( intersecationtab({a='a'},{b='b'}), {}, t.deepsame )
t( intersecationtab({a='a'},{a='b'}), {a='a'}, t.deepsame )

t( intersecationtab({a='a'},{a='b'},function(a,b) return a..b end), {a='ab'}, t.deepsame )

t( intersecationtab({a='a',b='b',c='c'},{a='A',d='d'}), {a='a'}, t.deepsame )

t()
