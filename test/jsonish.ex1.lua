local jsonish = require 'jsonish'
local t = require 'testhelper'

t( jsonish '', nil )
t( jsonish '1', 1 )
t( jsonish 'true', true )
t( jsonish '"hi"', "hi" )
t( jsonish '""', "" )

t( jsonish [["\u0021"]],    [[!]] )
t( jsonish [["h\u0021i"]],  [[h!i]] )
t( jsonish [["\\u0021"]],   [[\u0021]] )
t( jsonish [["h\\u0021i"]], [[h\u0021i]] )
t( jsonish [["\\\u0021"]],  [[\!]] )

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
t( jsonish[[ ["a","b\"]","c"] ]], {"a","b\"]","c"}, t.deepsame )

t( jsonish[[{"a":"","b":[],"c":0}]], {a="",b={},c=0}, t.deepsame )
t( jsonish[[{"a":"\"","b":[],"c":0}]], {a='"',b={},c=0}, t.deepsame )

t.test_embedded_example()

t()

