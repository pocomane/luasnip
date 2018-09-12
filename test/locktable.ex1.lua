local locktable = require 'locktable'
local t = require 'testhelper'

local err = t.filterr

local l = { a = 1 }
l = locktable( l, 'readnil' )
t( l.a, 1 )
t( err(function() return l.b end), nil, t.diff )
t( err(function() l.b = 2 end), nil )
t( err(function() l.a = 2 end), nil )

local l = { a = 1 }
l = locktable( l, 'writenil' )
t( l.a, 1 )
t( l.b, nil )
t( err(function() l.b = 2 end), nil, t.diff )
t( err(function() l.a = 2 end), nil )

local l = { a = 1 }
l = locktable( l, 'readnil', 'writenil' )
t( l.a, 1 )
t( err(function() return l.b end), nil, t.diff )
t( err(function() l.b = 2 end), nil, t.diff )
t( err(function() l.a = 2 end), nil )

local w = locktable( {a=1}, 'readnil', 'writenil', 'write' )
t( w.a, 1 )
t( err(function() return w.b end), nil, t.diff )
t( err(function() w.b = 2 end), nil, t.diff )
t( err(function() w.a = 2 end), nil, t.diff )

local w = locktable( {a=1}, 'write' )
t( w.a, 1 )
t( w.b, nil )
t( err(function() w.b = 2 end), nil, t.diff )
t( err(function() w.a = 2 end), nil, t.diff )

local r = locktable( {a=1}, 'read' )
t( err(function() return r.a end), nil, t.diff )
t( err(function() return r.b end), nil, t.diff )
t( err(function() r.b = 2 end), nil )
t( err(function() r.a = 2 end), nil )

local l = {a=1}
local f = locktable( l, 'full' )
t( err(function() return f.a end), nil, t.diff )
t( err(function() return f.b end), nil, t.diff )
t( err(function() f.b = 2 end), nil, t.diff )
t( err(function() f.a = 2 end), nil, t.diff )
t( err(function() return l.a end), nil )
t( err(function() return l.b end), nil )
t( err(function() l.b = 2 end), nil )
t( err(function() l.a = 2 end), nil )

local l = {}
local f = locktable( l, 'write' )
t( err(function() f.a = 2 end), nil, t.diff )
t( l.a, nil )
t( f.a, nil )
t( err(function() l.a = 1 end), nil )
t( l.a, 1 )
t( f.a, 1 )
t( err(function() f.a = 2 end), nil, t.diff )
t( l.a, 1 )
t( f.a, 1 )

local l = { a = 1 }
l = locktable( l, 'readnil', 'writenil' )
t( l.a, 1 )
t( err(function() return l.b end), nil, t.diff )
t( err(function() l.b = 2 end), nil, t.diff )
t( err(function() l.a = 2 end), nil )

local l = { a = 1 }
l = locktable( l, 'iterate' )
t( err(function() for _ in pairs(l) do end end), nil, t.diff )

local function strict() _ENV = locktable( _ENV, 'readnil' ) end
global_a = 1
strict()
t( global_a, 1 )
t( err(function() return global_b end), nil, t.diff )
t( err(function() global_b = 2 end), nil )
t( err(function() global_a = 2 end), nil )

t()
