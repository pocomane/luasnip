local pathpart = require 'pathpart'
local t = require 'testhelper'

t( pathpart'', {}, t.deepsame )
t( pathpart{}, '' )

t( pathpart'path/name.ext', {'path','name.ext'}, t.deepsame )
t( pathpart'path\\name.ext', {'path','name.ext'}, t.deepsame )

t( pathpart'path/b/name.ext', {'path','b','name.ext'}, t.deepsame )
t( pathpart'/path/name.ext', {'path','name.ext'}, t.deepsame )

t( pathpart'path/to/', {'path','to'}, t.deepsame )
t( pathpart'name.ext', {'name.ext'}, t.deepsame )

local s = package.config:sub(1,1)

t( pathpart{'path','name.ext'}, 'path'..s..'name.ext' )
t( pathpart{'path','pathb','name.ext'}, 'path'..s..'pathb'..s..'name.ext' )

t( pathpart{'path','to'}, 'path'..s..'to', t.deepsame )
t( pathpart{'name.ext'}, 'name.ext', t.deepsame )

t.test_embedded_example()

t()
