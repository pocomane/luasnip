local templua = require( "templua" )
local t = require 'testhelper'

-- Blank templates are not touched
local m = templua( "ok" )
t( 'ok', m{} )

-- Lua expression expansion with @{}
m = templua( "@{item.a} @{item.b:upper()}" )
t( 'a B', m{ item = { a = 'a', b = 'b' } } )
m = templua( "@{item.a} @{item.b:upper()}" )
t( 'B A', m{ item = { a = 'B', b = 'a' } } )

-- Call same template multiple times
m = templua( "@{x}" )
t( '1', m{ x=1 } )
t( '2', m{ x=2 } )

-- Mix lua statements and text with @{{}}
m = templua( "@{{for i=1,3 do}} hello @{item}!@{{end}}" )
t( ' hello world! hello world! hello world!', m{ item = 'world' } )

-- Use the output function to expand text from complex lua code
m = templua( "@{{for i=1,3 do out(' hello '..item..'!') end}}" )
t( ' hello dude! hello dude! hello dude!', m{ item = 'dude' } )

-- Statement that do not cover all the string
m = templua( "hello @{{a=1}} world" )
t( 'hello  world', m{} )

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

-- Error while expanding
m = templua( "@{{undefined_function()}}" )
local s, e = m{}
t( s, nil )
t( e, 'string "templua_script"%]:1: attempt to call a nil value', t.patsame )

-- Ignoring @ between templates
m = templua( "@{x} @ @{x}" )
t( 'y @ y', m{ x='y' } )

-- Nested template
local s = {}
function s.nestcall()
  return templua( "@{'B'}" )( s )
end
t( templua( "@{nestcall()}@{nestcall()}" )( s ), 'BB' )

-- Transform
t( templua( "xxx", function(a) return a:upper() end)(), 'XXX')

-- Change the transform inside the template
local transform = function(a) return a end
local change = function() transform = function(a) return a:upper() end end
t( templua( "xxx @{{change()}} xxx", function(a) return transform(a) end)({change = change}), 'xxx  XXX')

t.test_embedded_example()

t()

