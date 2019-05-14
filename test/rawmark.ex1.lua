local rawmark = require 'rawmark'
local t = require 'testhelper'

local v = function(...) print('# '..((require'valueprint'(...)):gsub('\r?\n','\n# '))) end

t( rawmark( '' ), { '', type='' }, t.deepsame )
t( rawmark( 'a' ), { 'a', type='' }, t.deepsame )

t( rawmark( '{}' ), {{ '', type='' }, type='' }, t.deepsame )
t( rawmark( '{a}' ), {{ 'a', type='' }, type='' }, t.deepsame )
t( rawmark( '{:a}' ), {{ 'a', type='' }, type='' }, t.deepsame )

t( rawmark( 'a{}' ), { 'a', { "", type='' }, type='' }, t.deepsame )

t( rawmark( 'a{b}' ), { 'a', { "b", type='' }, type='' }, t.deepsame )
t( rawmark( '{b}a' ), {{ "b", type='' }, 'a', type='' }, t.deepsame )
t( rawmark( 'a{b}c' ), { 'a', { "b", type='' }, 'c', type='' }, t.deepsame )

t( rawmark( '{a}b{c}' ), {{ "a", type='' }, 'b', { "c", type='' }, type='' }, t.deepsame )
t( rawmark( 'a{b}{c}' ), { "a", { "b", type='' }, { "c", type='' }, type='' }, t.deepsame )
t( rawmark( '{a}{b}c' ), {{ "a", type='' }, { "b", type='' }, "c", type='' }, t.deepsame )

t( rawmark( '{{a}}' ), {{{ 'a', type='' }, type='' }, type='' }, t.deepsame )
t( rawmark( '{{{a}}}' ), {{{{ 'a', type='' }, type='' }, type='' }, type='' }, t.deepsame )
t( rawmark( '{{a}}b{{c}}' ), {{{ 'a', type='' }, type='' }, 'b', {{ 'c', type='' }, type='' }, type='' }, t.deepsame )

t( rawmark( '',  't' ), { '', type='t' }, t.deepsame )
t( rawmark( '{t:}' ), {{ '', type='t' }, type='' }, t.deepsame )
t( rawmark( '{t:a}' ), {{ 'a', type='t' }, type='' }, t.deepsame )
t( rawmark( '{t::}' ), {{ ':', type='t' }, type='' }, t.deepsame )
t( rawmark( '{t:a:c}' ), {{ 'a:c', type='t' }, type='' }, t.deepsame )
t( rawmark( '{tt:a}b{TT2:c}', 't3' ), {{ "a", type='tt' }, 'b', { "c", type='TT2' }, type='t3' }, t.deepsame )

t( rawmark( '{a-+_b:}' ), {{ '', type='a-+_b' }, type='' }, t.deepsame )

t( rawmark( '{+}' ), {'{', type='' }, t.deepsame )
t( rawmark( '{-}' ), {'}', type='' }, t.deepsame )
t( rawmark( '{=}' ), {':', type='' }, t.deepsame )
t( rawmark( 'a{+}b{=}c{:d}e{-}' ), { 'a','{','b',':','c', {'d', type=''} ,'e','}', type='' }, t.deepsame )

t( rawmark( 'a{b' ), {'a{b', type='' }, t.deepsame )
t( rawmark( 'a}b' ), {'a}b', type='' }, t.deepsame )
t( rawmark( 'a{b{c}d' ), {type='', 'a{b', { type='', 'c'}, 'd' }, t.deepsame ) -- TODO : change this ?
t( rawmark( 'a{b}c}d' ), {type='', 'a', { type='', 'b'}, 'c}d' }, t.deepsame ) -- TODO : change this ?

t.test_embedded_example()

t()

