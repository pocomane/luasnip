local cliparse = require 'cliparse'
local t = require 'testhelper'

t( cliparse(), {}, t.deepsame )
t( cliparse({}), {}, t.deepsame )
t( cliparse({'a'}), {['']={'a'}}, t.deepsame )
t( cliparse({'a','b'}), {['']={'a','b'}}, t.deepsame )

t( cliparse({'-a'}), {['a']={}}, t.deepsame )
t( cliparse({'-a','b'}), {['a']={},['']={'b'}}, t.deepsame )
t( cliparse({'-a','-b','c'}), {['a']={},['b']={},['']={'c'}}, t.deepsame )

t( cliparse({'-ab','c'}), {['a']={},['b']={},['']={'c'}}, t.deepsame )

t( cliparse({'--aa'}), {['aa']={}}, t.deepsame )
t( cliparse({'--aa','c'}), {['aa']={'c'}}, t.deepsame )
t( cliparse({'--aa','c','d'}), {['aa']={'c'},['']={'d'}}, t.deepsame )

t( cliparse({'--aa','--bb'}), {['aa']={},['bb']={}}, t.deepsame )

t( cliparse({'--aa','b','c','--aa','d'}), {['aa']={'b','d'},['']={'c'}}, t.deepsame )

t( cliparse({'--aa=b','c'}), {['aa']={'b'},['']={'c'}}, t.deepsame )
t( cliparse({'--aa:b','c'}), {['aa']={'b'},['']={'c'}}, t.deepsame )
t( cliparse({'--aa=b=c','d'}), {['aa']={'b=c'},['']={'d'}}, t.deepsame )

t( cliparse({'-a=b','c'}), {['a']={'b'},['']={'c'}}, t.deepsame )
t( cliparse({'-a:b','c'}), {['a']={'b'},['']={'c'}}, t.deepsame )
t( cliparse({'-aa=b','c'}), {['aa']={'b'},['']={'c'}}, t.deepsame )

t.test_embedded_example()

t()

