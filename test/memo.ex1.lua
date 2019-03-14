
local memo = require 'memo'
local t = require 'testhelper'

local c = 0
local add=memo(function(a,b) c=c+1 return a+b end)

t(c, 0)
t(add(1,2), 3)
t(c, 1)
t(add(1,2), 3)
t(c, 1)
t(add(1,2), 3)
t(c, 1)
t(add(2,2), 4)
t(c, 2)
t(add(2,2), 4)
t(c, 2)

t.test_embedded_example()

t()

