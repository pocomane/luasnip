local deepsame = require 'deepsame'
local t = require 'testhelper'

t( deepsame({}, {}), true )
t( deepsame({1}, {1}), true )
t( deepsame({1}, {2}), false )

t( deepsame({1,2}, {1}), false )
t( deepsame({1}, {1,2}), false )

t( deepsame({[{1}]=1}, {[{1}]=1}), true )
t( deepsame({[{1}]=1}, {[{2}]=1}), false )
t( deepsame({[{1}]=1}, {[{1}]=2}), false )

t( deepsame({{}}, {{}}), true )
t( deepsame({{1}}, {{1}}), true )
t( deepsame({{1}}, {{2}}), false )

t( deepsame({{1},{2}}, {{1}}), false )
t( deepsame({{1}}, {{1},{2}}), false )

t( deepsame({[{{1}}]={1}}, {[{{1}}]={1}}), true )
t( deepsame({[{{1}}]={1}}, {[{{2}}]={1}}), false )
t( deepsame({[{{1}}]={1}}, {[{{1}}]={2}}), false )

local a = {y={}}
local x = {}
x.y = x
local w = {}
w.y = w
local z = {y={}}
z.y.y = z

t( deepsame(a, x), false )
t( deepsame(x, a), false )
t( deepsame(x, w), true )
t( deepsame(w, x), true )
t( deepsame(x, z), true )
t( deepsame(z, x), true )

t( deepsame( { false }, { false } ), true )

-- Table with multiple cycle
local atab = {}
atab.kv = {}
atab[atab.kv] = atab.kv
atab[atab.kv][atab.kv] = atab[atab.kv]
local btab = {}
btab.kv = {}
btab[btab.kv] = btab.kv
btab[btab.kv][btab.kv] = btab[btab.kv]
t( t.deepsame( atab, btab ), true )

t()
