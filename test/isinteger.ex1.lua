local isinteger = require "isinteger"
local t = require "testhelper"

t( isinteger( 1 ),      true )
t( isinteger( 0 ),      true )
t( isinteger( 1.1 ),   false )
t( isinteger( "1" ),   false )
t( isinteger( true ),  false )
t( isinteger( { 1 } ), false )
t( isinteger(),        false )

t()
