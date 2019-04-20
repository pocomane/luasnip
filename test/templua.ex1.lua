local templua = require( "templua" )
local t = require 'testhelper'

-- Blank templates are not touched
local m = templua( "ok" )
t( 'ok', m{} )

-- Lua expression expansion with @{}
m = templua( "@{item.a} @{item.b:upper()}" )
t( 'a B', m{ item = { a = 'a', b = 'b' } } )
t( 'B A', m{ item = { a = 'B', b = 'a' } } )

-- Mix lua statements and text with @{{}}
m = templua( "@{{for i=1,3 do}} hello @{item}!@{{end}}" )
t( ' hello world! hello world! hello world!', m{ item = 'world' } )

-- Use the output function to expand text from complex lua code
m = templua( "@{{for i=1,3 do _ENV[_ENV](' hello '..item..'!') end}}" )
t( ' hello dude! hello dude! hello dude!', m{ item = 'dude' } )

-- Last text appending
m = templua( "@{'true'} ok" )
t( 'true ok', m{} )

-- Value cast in the output function
m = templua( "@{true} ok" )
t( 'true ok', m{} )

-- Compile error is found
local m, e = templua( "@{{][}}" )
t( m, nil )
t( e, 'string "templua_script"%]:1: unexpected symbol', t.patsame )
t( e, 'Template script: ', t.patsame )
t( e, '_ENV%[_ENV%]%(""%)', t.patsame )

-- Error while expanding
m = templua( "@{{undefined_function()}}" )
local s, e = m{}
t( s, nil )
t( e, 'string "templua_script"%]:1: attempt to call a nil value', t.patsame )
t( e, 'Template script: ', t.patsame )
t( e, '_ENV%[_ENV%]%(""%)', t.patsame )

-- Nested template
local s = {}
function s.nestcall()
  return templua( "@{'B'}" )( s )
end
t( templua( "@{nestcall()}@{nestcall()}" )( s ), 'BB' )

t.test_embedded_example()

t()

