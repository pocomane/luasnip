
local get = require 'get'
local t = require 'testhelper'

t( nil, get({},'a'))
t( 'b', get({a='b'},'a'))

t( 'd', get({a={b={c='d'}}},'a','b','c'))
t( nil, get({a={b={c='d'}}},'a','x','c'), nil )

t( nil, get({a={b={c='d'}}},'a',nil,'c'), nil )

t( nil, get(nil,'a','b','c'), nil )
t( nil, get({a={b=0}},'a','b','c'), nil )

t.test_embedded_example()

t()
