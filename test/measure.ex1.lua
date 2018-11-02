local measure = require 'measure'
local t = require 'testhelper'
local e002 = t.number_tollerance(0.002)

local a,b,c

a = measure()
t( a(),  0 )
t( a(),  0 )
t( a(1), 1 )
t( a(),  1 )
t( a(3), 2 )
t( a(5), 3 )

-- mean
a = measure()
t( a(),  0 )
t( a(1), 1 )

-- sample number
a = measure()
b = {a()}
t( b[5], 0 )
a(0)
b = {a()}
t( b[5], 1 )
b = {a()}
t( b[5], 1 )
a(0)
b = {a()}
t( b[5], 2 )
b = {a()}
t( b[5], 2 )

-- standard deviation
a = measure()
a(0)
a(0)
a(0)
a(1)
b = {a()}
t( b[2], 0.5 )

-- normalized skewness
a = measure()
a(0)
a(0)
a(0)
a(0)
a(1)
b = {a()}
t( b[3], 1.5, e002 )

-- normalized kurtosis
a = measure()
a(2)
a(2)
b = {a()}
t( b[1], 2.0, e002 )
t( b[2], 0, e002 )

a(8)
b = {a()}
t( b[1], 4.0, e002 )
t( b[2], 3.464, e002 )
t( b[3], 0.707, e002 )
t( b[4], 1.5, e002 )
t( b[5], 3 )

a(4)
b = {a()}
t( b[1], 4.0 )
t( b[2], 2.828, e002 )
t( b[3], 0.816, e002 )
t( b[4], 2.0, e002 )
t( b[5], 4 )

a = measure()
b = measure()
a(2) a(2)
b(4) b(8)
a = measure{a, b}
a = {a()}
b = measure()
b(2) b(4) b(8) b(2)
b = {b()}
t( a[1], b[1], e002 )
t( a[2], b[2], e002 )
t( a[3], b[3], e002 )
t( a[4], b[4], e002 )
t( a[5], b[5], e002 )

t()
