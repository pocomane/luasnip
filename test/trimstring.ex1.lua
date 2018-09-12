local trimstring = require 'trimstring'
local t = require 'testhelper'

t( trimstring(''), '' )
t( trimstring('a'), 'a' )

t( trimstring(' a'), 'a' )
t( trimstring('a '), 'a' )
t( trimstring(' a '), 'a' )

t( trimstring(' a a'), 'a a' )
t( trimstring('a a '), 'a a' )
t( trimstring(' a a '), 'a a' )

t( trimstring(' \nstr\r\t '), 'str' )

t()
