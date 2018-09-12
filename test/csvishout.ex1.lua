local csvishout = require 'csvishout'
local t = require 'testhelper'

t( csvishout{}, '' )
t( csvishout{{}}, '\n' )
t( csvishout{{},{}}, '\n\n' )

t( csvishout{{1}}, '1\n' )
t( csvishout{{'a'}}, 'a\n' )
t( csvishout{{1,2}}, '1;2\n' )
t( csvishout{{'',2}}, ';2\n' )

t( csvishout{{1,2,3}}, '1;2;3\n' )
t( csvishout{{1,2,3},{1,2,3}}, '1;2;3\n1;2;3\n' )
t( csvishout{{1,2,3},{1,2}}, '1;2;3\n1;2\n' )
t( csvishout{{1,2,3},{1,2}}, '1;2;3\n1;2\n' )

t( csvishout{{1},{},{2}}, '1\n\n2\n' )

t( csvishout{{';'}}, '";"\n' )
t( csvishout{{'\n'}}, '"\n"\n' )
t( csvishout{{'a"b'}}, '"a""b"\n' )

t( csvishout{{';','ok'}}, '";";ok\n' )
t( csvishout{{'\n','ok'}}, '"\n";ok\n' )
t( csvishout{{'"','ok'}}, '"""";ok\n' )
t( csvishout{{'ok"ok','ok'}}, '"ok""ok";ok\n' )

t()

