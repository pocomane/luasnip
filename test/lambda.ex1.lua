local lambda = require "lambda"
local t = require "testhelper"

-- lambda-like syntax
t( 1, lambda"x|x+1"( 0 ) )

-- multiple arguments
t( 4, lambda"x,y|x+y"( 1, 3 ) )

-- additional statement, only the last expression is returned
t( 3, lambda"x| x=x+1; x+1"( 1 ) )

-- default args are a,b,c,d,e,f,...( vararg )
t( 1, lambda"a+1"( 0 ) )

-- Memo
local m = lambda'a+1'
t( m, lambda'a+1' )

t.test_embedded_example()

t()
