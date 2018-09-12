local jsonishout = require 'jsonishout'
local t = require 'testhelper'

t( jsonishout(1), '1' )
t( jsonishout'', '""' )
t( jsonishout'hi', '"hi"' )

t( jsonishout{}, "[]" )
t( jsonishout{1}, '[1]' )
t( jsonishout{2,1}, '[2,1]' )
t( jsonishout{2,1,{}}, '[2,1,[]]' )

t( jsonishout{a=1}, '{"a":1}' )
t( jsonishout{a=1,b=2}, "^{[^,]*,[^,]*}$", t.patsame )
t( jsonishout{a=1,b=2}, '"a":1', t.patsame )
t( jsonishout{a=1,b=2}, '"b":2', t.patsame )

local empty = setmetatable({},{})
t( jsonishout(empty), '{}' )
t( jsonishout{a=empty}, '{"a":{}}' )

t( jsonishout{1,2,a=1}, '[1,2]' )

t( jsonishout{{a=1},{1}}, '[{"a":1},[1]]' )

t( jsonishout'\"', '"\\x22"' )
t( jsonishout'\n', '"\\x0A"' )

t()

