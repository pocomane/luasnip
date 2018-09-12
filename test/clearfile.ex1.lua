local clearfile = require 'clearfile'
local t = require 'testhelper'

t.removefile( 'tmp.txt' )
clearfile'tmp.txt'
t( t.readfile'tmp.txt', '' )

t.writefile( 'tmp.txt', 'xxx' )
clearfile'tmp.txt'
t( t.readfile'tmp.txt', '' )

t()

