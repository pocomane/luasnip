local appendfile = require "appendfile"
local t = require "testhelper"

os.remove( "appendfile.txt" )

t( appendfile( "appendfile.txt", "123" ), true )
t( t.readfile( "appendfile.txt" ), "123" )

t( appendfile( "appendfile.txt", "456" ), true )
t( t.readfile( "appendfile.txt" ), "123456" )

t( appendfile( "appendfile.txt", { "7","8" } ), true )
t( t.readfile( "appendfile.txt" ), "12345678" )

t( appendfile( "appendfile.txt", {"9","10"}, "<", ">" ), true )
t( t.readfile( "appendfile.txt" ), "12345678<9><10>" )

t.test_embedded_example()

os.remove( "appendfile.txt" )

t()
