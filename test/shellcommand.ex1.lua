local shellcommand = require 'shellcommand'
local t = require 'testhelper'

local lua, argdumputiil, outpath = t.argdumputil()

t( shellcommand(), '' )
t( shellcommand{}, '' )

os.execute( shellcommand{lua, argdumputiil, 'x'} )
t( t.readfile(outpath), 'x' )

os.execute( shellcommand{lua, argdumputiil, 'x', 'y'} )
t( t.readfile(outpath), 'xy' )

t( shellcommand{lua, argdumputiil, '-i'}, shellcommand({lua, argdumputiil})..' -i' )
t( shellcommand{lua, argdumputiil, '-o'}, shellcommand({lua, argdumputiil})..' -o' )
t( shellcommand{lua, argdumputiil, '-e'}, shellcommand({lua, argdumputiil})..' -e' )

t.writefile('tmp_1.txt','abc')
os.execute( shellcommand{lua, argdumputiil, '-i', input='tmp_1.txt'} )
t( t.readfile(outpath), 'abc' )

os.execute( shellcommand{lua, argdumputiil, 'z', 'w', '-o', output='tmp_2.txt'} )
t( t.readfile(outpath), 'zw' )
t( t.readfile( 'tmp_2.txt'), 'zw' )

os.execute( shellcommand{lua, argdumputiil, '-i', '-o', input='tmp_1.txt', output='tmp_2.txt'} )
t( t.readfile(outpath), 'abc' )
t( t.readfile( 'tmp_2.txt'), 'abc' )

os.execute( shellcommand{lua, argdumputiil, 'z', 'w', '-o', append=true, output='tmp_2.txt'} )
t( t.readfile(outpath), 'zw' )
t( t.readfile( 'tmp_2.txt'), 'abczw' )

os.execute( shellcommand{lua, argdumputiil, '-i', '-e', input='tmp_1.txt', output='tmp_2.txt', error='tmp_3.txt'} )
t( t.readfile(outpath), 'abc' )
t( t.readfile( 'tmp_2.txt'), '' )
t( t.readfile( 'tmp_3.txt'), 'abc' )

os.execute( shellcommand{lua, argdumputiil, 'z', 'w', '-e', append=true, output='tmp_2.txt', error='tmp_3.txt'} )
t( t.readfile(outpath), 'zw' )
t( t.readfile( 'tmp_2.txt'), '' )
t( t.readfile( 'tmp_3.txt'), 'abczw' )

os.execute( shellcommand{lua, argdumputiil, 'a', 'b', '-o', 'c', 'd', '-e', output='tmp_2.txt', error='tmp_2.txt'} )
local o = t.readfile('tmp_2.txt')
t( #o, 4 )
t( o, 'ab', t.patsame )
t( o, 'cd', t.patsame )

t.test_embedded_example()

t()

