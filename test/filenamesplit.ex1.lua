local filenamesplit = require 'filenamesplit'
local t = require 'testhelper'

t( {filenamesplit()}, {'','',''}, t.deepsame )
t( {filenamesplit''}, {'','',''}, t.deepsame )

t( {filenamesplit'path/name.ext'}, {'path/','name','.ext'}, t.deepsame )

t( {filenamesplit'/path/path/name.ext'}, {'/path/path/','name','.ext'}, t.deepsame )
t( {filenamesplit'path/name.name.ext'}, {'path/','name.name','.ext'}, t.deepsame )

t( {filenamesplit'name.ext'}, {'','name','.ext'}, t.deepsame )
t( {filenamesplit'path/.ext'}, {'path/','','.ext'}, t.deepsame )
t( {filenamesplit'path/name'}, {'path/','name',''}, t.deepsame )

t( {filenamesplit'path//name.ext'}, {'path//','name','.ext'}, t.deepsame )
t( {filenamesplit'path/name..ext'}, {'path/','name.','.ext'}, t.deepsame )

t.test_embedded_example()

t()
