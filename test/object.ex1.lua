local object = require 'object'
local t = require 'testhelper'

local a,b,c,d,e,f,g

a = {}
b = object.inherit{ a }
c = object.inherit{ a }

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
c = object.inherit{ a, b }

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
c = object.inherit{ a, b }

t( object.isderived( c, a ), true )
t( object.isderived( a, c ), false )
t( object.isderived( c, b ), true )
t( object.isderived( b, c ), false )

a = {}
b = object.inherit{ a }
c = object.inherit{ b }
t( object.isderived( c, a ), true )
t( object.isderived( a, c ), false )

a = {a=true}
b = {b=true}

t( b.a, nil )
t( a.b, nil )

c = object.inherit({ a }, b )
t( b, c )
t( a.b, nil )
t( b.a, true )

d = {d=true}

c = object.inherit({ d }, b )
t( b, c )
t( a.b, nil )
t( b.a, true )
t( d.b, nil )
t( b.d, true )

e = {e=true}

object.inherit({ e }, a )
t( b, c )
t( a.b, nil )
t( b.a, true )
t( d.b, nil )
t( b.d, true )
t( e.b, nil )
t( a.e, true )
t( b.e, true )

t( object.isderived( a, b ), false )
t( object.isderived( b, a ), true )
t( object.isderived( d, b ), false )
t( object.isderived( b, d ), true )
t( object.isderived( e, b ), false )
t( object.isderived( a, e ), true )
t( object.isderived( b, e ), true )

t()

