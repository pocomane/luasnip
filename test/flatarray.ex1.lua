local flatarray = require 'flatarray'
local t = require 'testhelper'

t( flatarray{}, {}, t.deepsame )
t( flatarray{1}, {1}, t.deepsame )
t( flatarray{1,2,3,4}, {1,2,3,4}, t.deepsame )

t( flatarray{1,{2,3},4}, {1,2,3,4}, t.deepsame )

t( flatarray{1,{{2,3}},4}, {1,2,3,4}, t.deepsame )

t( flatarray({1,{{2,3}},4}, 1), {1,{2,3},4}, t.deepsame )

t( flatarray{1,{2,{3}},{{4}}}, {1,2,3,4}, t.deepsame )

t.test_embedded_example()

t()
