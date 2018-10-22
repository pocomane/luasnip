local object = require 'object'
local t = require 'testhelper'

local a,b,c,d,e,f,g

a = {}
b = object.inherit(a)
c = object.inherit(a)

t( a, b, t.diff )
t( a, c, t.diff )
t( c, b, t.diff )

t( a.method, nil )
t( b.method, nil )
t( c.method, nil )

f = function() end
a.method = f

t( a.method, f )
t( b.method, f )
t( c.method, f )

g = function() end
b.method = g

t( a.method, f )
t( b.method, g )
t( c.method, f )

h = function() end
a.method = h

t( a.method, h )
t( b.method, g )
t( c.method, h )

a = {}
b = {}
c = object.inherit(a,b)

f = function() end
b.method = f

t( a.method, nil )
t( b.method, f )
t( c.method, f )

g = function() end
a.method = g

t( a.method, g )
t( b.method, f )
t( c.method, g )

h = function() end
b.method = h

t( a.method, g )
t( b.method, h )
t( c.method, g )

f = function() end
c.method = f

t( a.method, g )
t( b.method, h )
t( c.method, f )

a = {}
b = {}
c = object.inherit(a,b)

t( object.isderived( c, a ), true )
t( object.isderived( a, c ), false )
t( object.isderived( c, b ), true )
t( object.isderived( b, c ), false )

t()

