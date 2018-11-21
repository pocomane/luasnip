local intern = require 'intern'
local t = require 'testhelper'

t( type( intern() ), 'function' )

local int = intern()

t( type( int( 1 )), 'table' )
t( int( 1 ), int( 2 ), t.diff )

t( type( int( 1, nil, 0/0, 3 )), 'table' )
t( int( 1, nil, 0/0, 3 ), int( 1, nil, 0/0, 3 ))

t( int( 1, nil, 0/0, 3 ), int( 1, nil, 0/0 ), t.diff )
t( int( 1, nil, 0/0, 3 ), int( 1, nil ), t.diff )
t( int( 1, nil, 0/0, 3 ), int( 1 ), t.diff )
  
t( int( 1, nil, 0/0, 3 ), int( 1, nil, 0/0, 2 ), t.diff)
t( int( 1, nil, 0/0, 3 ), int( 1, nil, 0, 3 ), t.diff)
t( int( 1, nil, 0/0, 3 ), int( 1, '', 0/0, 3 ), t.diff)
t( int( 1, nil, 0/0, 3 ), int( 4, nil, 0/0, 3 ), t.diff)

-- Multiple store
local alt = intern()
t( type( alt( 1, nil, 0/0, 3 )), 'table' )
t( alt( 1, nil, 0/0, 3 ), alt( 1, nil, 0/0, 3 ))
t( alt( 1, nil, 0/0, 3 ), int( 1, nil, 0/0, 3 ), t.diff )

-- Garbage collection test

local gccount = 0
local x = int( true, false )
x = setmetatable( x, {__gc=function(t) gccount = gccount + 1 end} )

-- No collection if some reference is still around
collectgarbage('collect')
t( gccount, 0 )

-- Automatic collection
x = nil
collectgarbage('collect')
t( gccount, 1 )

t.test_embedded_example()

t()

