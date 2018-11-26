local lineposition = require "lineposition"
local t = require "testhelper"

-- ex: column/line to byte

t( lineposition("a a", 1, 1), 1 )
t( lineposition("a a\na", 1, 1), 1 )
t( lineposition("a a\na", 2, 1), 2 )
t( lineposition("a a\na", 1, 2), 5 )
t( lineposition("a dfklj\na;sdf kj\n$LA@ f\n1 3x45 \nas d f\nas dfkj", 3, 4 ), 27 )

-- ex: byte to column/line 

local x,y

x, y = lineposition("a a", 1)
t( y, 1 )
t( x, 1 )

x, y = lineposition("a a", 3)
t( y, 1 )
t( x, 3 )

x, y = lineposition("a\na", 3)
t( y, 2 )
t( x, 1 )

x, y = lineposition("a dfklj\na;sdf kj\n$LA@ f\n1 3x45 \nas d f\nas dfkj", 28)
t( y, 4 )
t( x, 4 )

t.test_embedded_example()

t()

