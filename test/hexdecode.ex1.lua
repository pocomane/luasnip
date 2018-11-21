local hexdecode = require 'hexdecode'
local t = require 'testhelper'

t( hexdecode '00', '\x00' )
t( hexdecode '0000', '\x00\x00' )

t( hexdecode 'FF', '\xFF' )
t( hexdecode 'FFFF', '\xFF\xFF' )

t( hexdecode '10BA', '\x10\xBA' )

t( hexdecode 'F', '\x0F' )

t.test_embedded_example()

t()

