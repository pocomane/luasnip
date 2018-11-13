local clone = require 'clone'
local t = require 'testhelper'

local s = {}
t( clone(s), s, t.diff )
t( clone(s), s, t.deepsame )

local s = {1}
t( clone(s), s, t.diff )
t( clone(s), s, t.deepsame )

local s = { a = 'a' }
local d = clone(s)
t( s, d, t.deepsame )

local s = { a = {} }
local d = clone(s)
t( s, d, t.deepsame )
t( s.a, d.a, t.diff )

local s = { a = {1} }
local d = clone(s)
t( s, d, t.deepsame )
t( s.a, d.a, t.diff )

local r = {}
local s = { a = r, b = r }
local d = clone(s)
t( s, d, t.deepsame )
t( s.a, d.a, t.diff )
t( s.b, d.b, t.diff )
t( d.a, d.b )

local r = {}
local s = { r, [r] = 1 }
local d = clone(s)
t( s, d, t.deepsame )
t( s[1], d[1], t.diff )
local kc
for k in pairs(d) do kc = k end
t( d[1], kc )

local s = { }
s[1] = s
local d = clone(s)
t( s, d, t.deepsame )
t( s[1], d[1], t.diff )
t( d, d[1] )

local k = {}
local s = { [k] = 2 }
local d = clone(s)
t( s, d, t.deepsame )
local kc
for k in pairs(d) do kc = k end
t( k, kc, t.deepsame )
t( k, kc, t.diff )

local s = {}
s.a = {}
s.a.a = {}
local d = clone( s ,2 )
t( s, d, t.deepsame )
t( s.a, d.a, t.diff )
t( s.a.a, d.a.a )

local s = {}
local r,q = {},{}
s[r] = 'a'
r[q] = 'a'
local d = clone( s ,2 )
t( s, d, t.deepsame )
local kc
for k in pairs(d) do kc = k end
local kcc
for k in pairs(kc) do kcc = k end
t( r, kc, t.diff )
t( q, kcc )

t()

