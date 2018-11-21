local keysort = require 'keysort'
local t = require 'testhelper'

t( keysort{}, {}, t.deepsame )
t( keysort{a=9}, {'a'}, t.deepsame )
t( keysort{[1]=0}, {1}, t.deepsame )

t( keysort{a=9,b=9}, {'a','b'}, t.deepsame )
t( keysort{b=9,a=9,}, {'a','b'}, t.deepsame )

t( keysort{[1]=9,[2]=9}, {1,2}, t.deepsame )
t( keysort{[2]=9,[1]=9}, {1,2}, t.deepsame )
t( keysort{[3]=9,[20]=9}, {20,3}, t.deepsame )

t( keysort{[1]=9,["1"]=9,}, {'1',1}, t.deepsame )

t( keysort{[1]=9,["1"]=9,}, {'1',1}, t.deepsame )

t.test_embedded_example()

t()
