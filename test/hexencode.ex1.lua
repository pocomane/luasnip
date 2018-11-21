local hexencode = require 'hexencode'
local t = require 'testhelper'

t( hexencode '\x00', '00' )
t( hexencode '\x00\x00', '0000' )

t( hexencode '\xFF', 'FF' )
t( hexencode '\xFF\xFF', 'FFFF' )

t( hexencode '\x10\xBA', '10BA' )

t.test_embedded_example()

t()

