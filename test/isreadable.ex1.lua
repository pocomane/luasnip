local isreadable = require "isreadable"
local t = require "testhelper"

io.open( "isreadable.txt", "wb" ):close()
t( isreadable( "isreadable.txt" ), true )

os.remove( "isreadable.txt" )
t( isreadable( "isreadable.txt" ), false )

t.test_embedded_example()

t()
