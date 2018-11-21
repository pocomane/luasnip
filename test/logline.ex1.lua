local logline = require "logline"
local t = require 'testhelper'

-- Default log level is 25 a.k.a. ERROR
-- Only logline with smaller level will generate a message

t( logline( 10, "test" ), "|", t.patsame )
t( logline( 25, "test" ), "|", t.patsame )
t( logline( 26, "test" ), nil, t.patsame )
t( logline( 99, "test" ), nil, t.patsame )

-- Change log level
logline( 60 )
t( logline( 10, "test" ), "|", t.patsame )
t( logline( 60, "test" ), "|", t.patsame )
t( logline( 61, "test" ), nil, t.patsame )
t( logline( 99, "test" ), nil, t.patsame )

-- Symbolic log level name

logline( "error" )
t( logline( 25, "test" ),        "|", t.patsame )
t( logline( 26, "test" ),        nil, t.patsame )
t( logline( "error", "test" ),   "|", t.patsame )
t( logline( "debug", "test" ),   nil, t.patsame )
t( logline( "info", "test" ),    nil, t.patsame )
t( logline( "verbose", "test" ), nil, t.patsame )

logline( "debug" )
t( logline( 50, "test" ),        "|", t.patsame )
t( logline( 51, "test" ),        nil, t.patsame )
t( logline( "error", "test" ),   "|", t.patsame )
t( logline( "debug", "test" ),   "|", t.patsame )
t( logline( "info", "test" ),    nil, t.patsame )
t( logline( "verbose", "test" ), nil, t.patsame )

logline( "info" )
t( logline( 75, "test" ),        "|", t.patsame )
t( logline( 76, "test" ),        nil, t.patsame )
t( logline( "error", "test" ),   "|", t.patsame )
t( logline( "debug", "test" ),   "|", t.patsame )
t( logline( "info", "test" ),    "|", t.patsame )
t( logline( "verbose", "test" ), nil, t.patsame )

logline( "verbose" )
t( logline( 99, "test" ),        "|", t.patsame )
t( logline( 100, "test" ),       nil, t.patsame )
t( logline( "error", "test" ),   "|", t.patsame )
t( logline( "debug", "test" ),   "|", t.patsame )
t( logline( "info", "test" ),    "|", t.patsame )
t( logline( "verbose", "test" ), "|", t.patsame )

-- Message contains source position
t( logline( 99, "test" ), "logline%.ex1%.lua:54", t.patsame ) -- he line 54 is this one

-- In some case the caller source position is used:
-- - Tail calls
-- - Functions with names that start or end with "log"

function wraplog( ... ) return logline( 99, ... ) end
function wraplogfakebarrier( ... ) return logline( 99, ... ) end
function wraplogbarrier( ... )
   local res = logline( 99, ... ) -- line 63
   return res
end

t( wraplog( "test" ),            "logline%.ex1%.lua:67", t.patsame ) -- line 67
t( wraplogfakebarrier( "test" ), "logline%.ex1%.lua:68", t.patsame ) -- line 68
t( wraplogbarrier( "test" ),     "logline%.ex1%.lua:63", t.patsame )

-- The argument are appended to the result string
t( logline( 99, "a", 1), "| a | 1 | $", t.patsame )

print( "# "..logline( 80, "ok" ) )

t.test_embedded_example()

t( )

