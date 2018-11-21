local readfile = require 'readfile'
local t = require 'testhelper'

t.writefile('tmp_1.txt', '')
t( readfile('tmp_1.txt'), '' )

t.writefile('tmp_1.txt', 'aaa\naaa')
t( readfile('tmp_1.txt'), 'aaa\naaa' )

t.writefile('tmp_1.txt', 'aaa\naaa')
t( readfile('tmp_1.txt', 'l'), {'aaa','aaa'}, t.deepsame )

t.writefile('tmp_1.txt', 'aaa\n')
t( readfile('tmp_1.txt', 'l'), 'aaa' )

t.writefile('tmp_1.txt', 'aaa\n\raaa')
t( readfile('tmp_1.txt', 'L'), {'aaa\n','\raaa'}, t.deepsame )

t.writefile('tmp_1.txt', 'aaaa')
t( readfile('tmp_1.txt', 2), {'aa','aa'}, t.deepsame )

t.writefile('tmp_1.txt', '1 1.2 -1e3')
t( readfile('tmp_1.txt', 'n'), {1,1.2,-1e3}, t.deepsame )

t.test_embedded_example()
os.remove('tmp.txt')

t()
