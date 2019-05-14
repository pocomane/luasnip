local rawhtml = require 'rawhtml'
local t = require 'testhelper'

t( rawhtml'', '' )
t( rawhtml'{', '{+}' )
t( rawhtml'}', '{-}' )
t( rawhtml':', '{=}' )

t( rawhtml'<div>', '{div:' )
t( rawhtml'</div>', '}' )
t( rawhtml'<div/>', '{div:}' )

t( rawhtml'<div>hi</div>', '{div:hi}' )
t( rawhtml'<div><b>hi</b></div>', '{div:{b:hi}}' )
t( rawhtml'{:}<div>x<b/>y</div>', '{+}{=}{-}{div:x{b:}y}' )

t( rawhtml'<div x y z>', '{div:{=attribute=:x y z}' )
t( rawhtml'<div x y z >', '{div:{=attribute=:x y z}' )
t( rawhtml'<div x y z/>', '{div:{=attribute=:x y z}}' )
t( rawhtml'</div x y z>', '}' )

t( rawhtml'<!--bla bla', '{=comment=:bla bla' )
t( rawhtml'bla bla-->', 'bla bla}' )
t( rawhtml'<!--bla bla-->', '{=comment=:bla bla}' )

local r = require 'rawmark'

t( r( rawhtml'<!--{:}--><div my-attr="hi">x< b  />y</div>' ), {type='',{type='=comment=','{',':','}'},{type='div',{type='=attribute=','my-attr="hi"'},'x',{type='b',''},'y'}}, t.deepsame )

t.test_embedded_example()

t()

