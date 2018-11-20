local a = require 'argcheck'
local t = require 'testhelper'

local function argcheck(...) return t.filterr(a, ...) end

t( argcheck({}), nil )
t( argcheck({}, 1), 'Invalid number of arguments. Must be 0 not 1.' )

t( argcheck({'number'}, 1), nil )
t( argcheck({'number'}, 'a'), 'Invalid argument #1 type. Must be number not string.' )
t( argcheck({'boolean'}, 'a'), 'Invalid argument #1 type. Must be boolean not string.' )
t( argcheck({'string'}, false), 'Invalid argument #1 type. Must be string not boolean.' )
t( argcheck({'table'}, false), 'Invalid argument #1 type. Must be table not boolean.' )

t( argcheck({'number','string','boolean'}, 1, 'a', false), nil )
t( argcheck({'number','string','boolean'}, 1, false, false), 'Invalid argument #2 type. Must be string not boolean.' )

t( nil, t.embedded_example_fail() )

t()
