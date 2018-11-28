local jsonish = require 'jsonish'
local t = require 'testhelper'

t( jsonish '', nil )
t( jsonish '1', 1 )
t( jsonish 'true', true )
t( jsonish '"hi"', "hi" )
t( jsonish '"\\u005D"', "]" )
t( jsonish '"\\\\u005D"', "\\u005D" )
t( jsonish '"h\\\\u005Di"', "h\\u005Di" )
t( jsonish '"h\\u005Di"', "h]i" )

t( jsonish '{}', {}, t.deepsame )
t( jsonish '{"hello":"world"}', {hello="world"}, t.deepsame )
t( jsonish '[1,2,3]', {1,2,3}, t.deepsame )

t( jsonish '{"hello":{"wor":"ld"}}', {hello={wor="ld"}}, t.deepsame )
t( jsonish '[1,2,[3,4]]', {1,2,{3,4}}, t.deepsame )

t( jsonish '["a","b]","c"]', {"a","b]","c"}, t.deepsame )
t( jsonish '["a","[b","c"]', {"a","[b","c"}, t.deepsame )
t( jsonish '["a","[b","c]"]', {"a","[b","c]"}, t.deepsame )
t( jsonish '["a",["b","c"]]', {"a",{"b","c"}}, t.deepsame )

t( jsonish[[{"a b": true}]], {["a b"]=true}, t.deepsame)
t( jsonish '{"hello" :"world"}', {hello="world"}, t.deepsame )

t( jsonish[[{"\"b\"":true}]], {['"b"']=true}, t.deepsame)

t.test_embedded_example()

t()

