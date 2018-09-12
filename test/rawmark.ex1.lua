local rawmark = require 'rawmark'
local t = require 'testhelper'

t( rawmark( '' ), { '', type='default' }, t.deepsame )
t( rawmark( 'a' ), { 'a', type='default' }, t.deepsame )

t( rawmark( '@{}' ), {{ '', type='default' }, type='default' }, t.deepsame )
t( rawmark( '@{a}' ), {{ 'a', type='default' }, type='default' }, t.deepsame )

t( rawmark( 'a@{}' ), { 'a', { "", type='default' }, type='default' }, t.deepsame )

t( rawmark( 'a@{b}' ), { 'a', { "b", type='default' }, type='default' }, t.deepsame )
t( rawmark( '@{b}a' ), {{ "b", type='default' }, 'a', type='default' }, t.deepsame )
t( rawmark( 'a@{b}c' ), { 'a', { "b", type='default' }, 'c', type='default' }, t.deepsame )

t( rawmark( '@{a}b@{c}' ), {{ "a", type='default' }, 'b', { "c", type='default' }, type='default' }, t.deepsame )
t( rawmark( 'a@{b}@{c}' ), { "a", { "b", type='default' }, { "c", type='default' }, type='default' }, t.deepsame )
t( rawmark( '@{a}@{b}c' ), {{ "a", type='default' }, { "b", type='default' }, "c", type='default' }, t.deepsame )

t( rawmark( '@{@{a}}' ), {{{ 'a', type='default' }, type='default' }, type='default' }, t.deepsame )
t( rawmark( '@{@{@{a}}}' ), {{{{ 'a', type='default' }, type='default' }, type='default' }, type='default' }, t.deepsame )
t( rawmark( '@{@{a}}b@{@{c}}' ), {{{ 'a', type='default' }, type='default' }, 'b', {{ 'c', type='default' }, type='default' }, type='default' }, t.deepsame )

t( rawmark( '',  't' ), { '', type='t' }, t.deepsame )
t( rawmark( '@t{a}' ), {{ 'a', type='t' }, type='default' }, t.deepsame )
t( rawmark( '@tt{a}b@TT2{c}', 't3' ), {{ "a", type='tt' }, 'b', { "c", type='TT2' }, type='t3' }, t.deepsame )

t( rawmark( '@a-+_b{}' ), {{ '', type='a-+_b' }, type='default' }, t.deepsame )

t( rawmark( '{+}' ), {'{', type='default' }, t.deepsame )
t( rawmark( '{-}' ), {'}', type='default' }, t.deepsame )
t( rawmark( '{=}' ), {'@', type='default' }, t.deepsame )

t( rawmark( '{=}{+}{-}' ), {'@{}', type='default' }, t.deepsame )
t( rawmark( '{=}{}' ), {'@{}', type='default' }, t.deepsame )
t( rawmark( '{=}{+}}' ), {'@{}', type='default' }, t.deepsame )
t( rawmark( '{=}{{-}' ), {'@{}', type='default' }, t.deepsame )

t( rawmark( '{=}@{}' ), {'@', { '', type='default' }, type='default' }, t.deepsame )

t( rawmark( '{a}' ), {'a', type='default' }, t.deepsame )

t()

