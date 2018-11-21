local copyfile = require "copyfile"
local t = require "testhelper"

local inpath = "intmp.txt"
local outpath = "outtmp.txt"
local data = ( "01f" ):rep( 512 )

t.writefile( inpath, data )
t( copyfile( inpath, outpath ), true )
t( t.readfile( outpath ), data )

os.remove( inpath )
os.remove( outpath )

t.test_embedded_example()
os.remove('s.txt')
os.remove('d.txt')

t()
