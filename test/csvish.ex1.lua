
local csvish = require 'csvish'
local t = require 'testhelper'

t( csvish'', {{''}}, t.deepsame )
t( csvish'aa', {{'aa'}}, t.deepsame )
t( csvish'aa;bb', {{'aa','bb'}}, t.deepsame )

t( csvish'aa;bb;;cc', {{'aa','bb','','cc'}}, t.deepsame )
t( csvish'aa;bb;', {{'aa','bb',''}}, t.deepsame )
t( csvish';', {{'',''}}, t.deepsame )
t( csvish';;', {{'','',''}}, t.deepsame )

t( csvish'aa\nbb', {{'aa'},{'bb'}}, t.deepsame )
t( csvish'aa\nbb\ncc', {{'aa'},{'bb'},{'cc'}}, t.deepsame )
t( csvish'aa\nbb\n', {{'aa'},{'bb'},{''}}, t.deepsame )
t( csvish'aa\n', {{'aa'},{''}}, t.deepsame )
t( csvish'aa\n\nbb', {{'aa'},{''},{'bb'}}, t.deepsame )
t( csvish'\n', {{''},{''}}, t.deepsame )

t( csvish'aa\n;\nbb', {{'aa'},{'',''},{'bb'}}, t.deepsame )

t( csvish'"aa";bb', {{'aa','bb'}}, t.deepsame )
t( csvish'"aa;bb"', {{'aa;bb'}}, t.deepsame )
t( csvish'"aa;bb";cc', {{'aa;bb','cc'}}, t.deepsame )
t( csvish'"aa;bb";cc;"dd;ee"', {{'aa;bb','cc','dd;ee'}}, t.deepsame )

t( csvish'"aa"bb', {{'aabb'}}, t.deepsame )
t( csvish'aa"bb"', {{'aabb'}}, t.deepsame )
t( csvish'aa"bb"cc', {{'aabbcc'}}, t.deepsame )
t( csvish'aa"bb"cc;dd', {{'aabbcc','dd'}}, t.deepsame )
t( csvish'zz;aa"bb"cc', {{'zz','aabbcc'}}, t.deepsame )

t( csvish'aa""bb', {{'aa"bb'}}, t.deepsame )
t( csvish'aa""', {{'aa"'}}, t.deepsame )
t( csvish'""aa', {{'"aa'}}, t.deepsame )
t( csvish'aa;bb""', {{'aa','bb"'}}, t.deepsame )
t( csvish'""aa;bb', {{'"aa','bb'}}, t.deepsame )

t( csvish'aa"\n"bb', {{'aa\nbb'}}, t.deepsame )
t( csvish'aa"\r"bb', {{'aa\rbb'}}, t.deepsame )
t( csvish'aa"\n\r"bb', {{'aa\n\rbb'}}, t.deepsame )
t( csvish'aa";"bb', {{'aa;bb'}}, t.deepsame )

t()

