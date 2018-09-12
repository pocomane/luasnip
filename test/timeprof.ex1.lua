local timeprof = require 'timeprof'
local t = require 'testhelper'

local e02, e002 = t.number_tollerance(0.02), t.number_tollerance(0.002)
local a, b, c, f, m, s

-- Get timers, same are returned if same argument is passed (except nil)

a = timeprof'a'
t( a, timeprof'a' )
b = timeprof'b'
c = timeprof()
t( b, a, t.diff )
t( b, c, t.diff )
t( a, c, t.diff )

-- Timer Api

a = timeprof()

t( a:start(), nil )
t( a:stop(),  nil )
t( a:reset(), nil )

-- Single time measurement

a = timeprof()
f, m, s = a:summary()

t( f, 0 )
t( m, 0 )
t( s, 0 )

a:start()
t.wait(0.2)
a:stop()
f, m, s = a:summary()

t( f, 0.2, e02 )
t( m, 0.2, e02 )
t( s, 0, e02 )

t.wait(0.1)

-- Adding two time measurement

a:start()
t.wait(0.1)
a:stop()
f, m, s = a:summary()

t( f, 0.3, e02 )
t( m, 0.15, e02 )
t( s, 0.0707, e002 )

a:start()
t.wait(0.3)
a:stop()
f, m, s = a:summary()

t( f, 0.6, e02 )
t( m, 0.2, e02 )
t( s, 0.1, e002 )

-- Resetting measurements

a:reset()
f, m, s = a:summary()

t( f, 0 )
t( m, 0 )
t( s, 0 )

a:start()
t.wait(0.01)
a:stop()
f, m, s = a:summary()

t( f, 0.01, e002 )
t( m, 0.01, e002 )
t( s, 0 )

-- Multiple timers

a = timeprof()
b = timeprof()

a:start()
t.wait(0.01)
b:start()
t.wait(0.02)
a:stop()
b:stop()
f, m, s = a:summary()

t( f, 0.03, e002 )
t( m, 0.03, e002 )
t( s, 0 )

f, m, s = b:summary()

t( f, 0.02, e002 )
t( m, 0.02, e002 )
t( s, 0 )

t()

