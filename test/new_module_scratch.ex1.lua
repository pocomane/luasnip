
local new_module_scratch = require 'new_module_scratch'
local t = require 'testhelper'

--------------------------------------------------------------------------

local varesult = new_module_scratch.varesult

local count, a, b, c = varesult((function() return 'a','b','c' end)())
t( count, 3 )
t( 'a', a )
t( 'b', b )
t( 'c', c )

local count, a, b = varesult((function() return 'a',nil end)())
t( count, 2 )
t( 'a', a )
t( nil, b )

local count, a, b = varesult((function() return nil,'b' end)())
t( count, 2 )
t( nil, a )
t( 'b', b )

local count, a, b = varesult((function() return nil,nil end)())
t( count, 2 )
t( nil, a )
t( nil, b )

--------------------------------------------------------------------------

local dispatcher = new_module_scratch.dispatcher

local a = {}
local c = dispatcher( a )
local m = getmetatable(c)

t( type(m.__index), 'table' )

a.x = 1
t( a.x, 1 )
t( c.x, 1 )

c.x = 2
t( a.x, 1 )
t( c.x, 2 )

local a = {}
local c = dispatcher( nil, a )
local m = getmetatable(c)

t( type(m.__newindex), 'table' )

a.x = 1
t( a.x, 1 )
t( c.x, nil )

c.x = 2
t( a.x, 2 )
t( c.x, nil )

local a, b = {}, {}
local c = dispatcher( a, b )

a.x = 1
t( c.x, 1 )
t( b.x, nil )

c.x = 2
t( a.x, 1 )
t( b.x, 2 )

local a, b = {}, {}
local c = dispatcher( 'hide', a, b )
local m = getmetatable(c)

t( m, 'hidden' )

a.x = 1
t( c.x, 1 )
t( b.x, nil )

c.x = 2
t( a.x, 1 )
t( b.x, 2 )

-- TODO : test pairs/ipairs

--------------------------------------------------------------------------

local method_accessor = new_module_scratch.method_accessor

local function inc(self,val) self.field = val+self.field return self.field end
local function sca(self,val) self.field = val*self.field return self.field end

local a = { field = 3, method = inc }

local b = method_accessor( a )

t( a.field , 3 )
t( b.field , 3 )

t( a.method , inc )
t( b.method , inc )

t( a:method(1) , 4 )
t( a.field , 4 )

t( b:method(1) , 5 )
t( a.field , 5 )

a.method = sca

t( a:method(2) , 10 )
t( a.field , 10 )

t( b.method , inc )
t( b:method(1) , 11 )
t( a.field , 11 )

--------------------------------------------------------------------------

local getsource = new_module_scratch.getsource

local src, ref = getsource( 1 )
print('# info ',ref)
local i = 0
while true do
  i = i+1
  if nil == src[i] then break end
  -- print('# info '..i..'| ',src[i])
end

-- TODO : TEST ???

--------------------------------------------------------------------------

local tableclear = new_module_scratch.tableclear

-- TODO : test ??

--------------------------------------------------------------------------

t('EXCEPT START')

local except = new_module_scratch.except

local result = {}

except.try(function()
  result[1+#result] = 'a'
  except.trow(1)
  result[1+#result] = 'WRONG'
end, function(x)
  result[1+#result] = 'b'
  result[1+#result] = x
  result[1+#result] = 'c'
end)

t( result, {'a','b',1,'c'}, t.deepsame )

t('EXCEPT END')

--------------------------------------------------------------------------

local tempnest = new_module_scratch.tempnest

t( tempnest[[ print( @{"1"..'@{"2"}'.."3"} ) ]], [[ print( 123 ) ]])
t( tempnest[[ print( "@{{for @{"i".."i"}=1,3 do}}@{ii}@{{end}}" ) ]], [[ print( "123" ) ]])

--------------------------------------------------------------------------

local loadfunc = new_module_scratch.loadfunc

local f = loadfunc [[ return x ]]

t( f{x=1}, 1 )
t( f{x=2}, 2 )

--------------------------------------------------------------------------

local cocatch = new_module_scratch.cocatch

local res = ""
local function out(x) res = res .. x end

local A,B,C,coA,coB,coC

-- coroutine.resume like usage: catching any yielded value

coA = coroutine.create(function()
  out'a'
  coroutine.yield('c')
  out'b'
  return 'x'
end)
res = ""

cocatch(nil, coA)

t( res, 'a' )

cocatch(nil, coA)

t( res, 'ab' )

-- Return value

coA = coroutine.create(function()
  coroutine.yield('a')
end)

A, B, C = cocatch(nil, coA)

t( A, true )
t( B, 'a' )
t( C, nil )

-- Deep coroutine.resume like usage

coA = coroutine.create(function()
  out'b'
  coroutine.yield('c')
  out'd'
end)
coB = coroutine.create(function()
  out'a'
  cocatch(nil, coA)
  out'c'
  cocatch(nil, coA)
  out'e'
  return 'x'
end)
res = ""

cocatch(nil, coB)

t( res, 'abcde' )

-- coroutine.resume like with nil yield

coA = coroutine.create(function()
  out'b'
  coroutine.yield(nil)
  out'd'
end)
coB = coroutine.create(function()
  out'a'
  cocatch(nil, coA)
  out'c'
  cocatch(nil, coA)
  out'e'
  return 'x'
end)
res = ""

cocatch(nil, coB)

t( res, 'abcde' )

-- Catch specific yielded value

coA = coroutine.create(function()
  out'b'
  coroutine.yield('x')
  out'd'
end)
coB = coroutine.create(function()
  out'a'
  cocatch('x', coA)
  out'c'
  return 'y'
end)
res = ""

cocatch(nil, coB)

t( res, 'abc' )

-- Catching nil

coA = coroutine.create(function()
  out'b'
  coroutine.yield(nil)
  out'x'
end)
coB = coroutine.create(function()
  out'a'
  cocatch('y', coA)
  out'x'
  return 'x'
end)
res = ""

cocatch(nil, coB)

t( res, 'ab' )

-- Pass through unmatching catch

coA = coroutine.create(function()
  out'c'
  coroutine.yield('w')
  out'p'
end)
coB = coroutine.create(function()
  out'b'
  cocatch('x', coA)
  out'q'
  return 'z'
end)
coC = coroutine.create(function()
  out'a'
  cocatch(nil, coB)
  out'd'
  return 'w'
end)
res = ""

cocatch(nil, coC)

t( res, 'abcd' )

-- Multiple resume

coA = coroutine.create(function()
  out'b'
  coroutine.yield('x')
  out'c'
  coroutine.yield('x')
  out'y'
end)
coB = coroutine.create(function()
  out'a'
  cocatch('z', coA)
  out'z'
  return 'z'
end)
res = ""

cocatch(nil, coB)
cocatch(nil, coB)

t( res, 'abc' )

--------------------------------------------------------------------------

local bafind = new_module_scratch.bafind
local s, f

s, f = bafind( 'a', 'b', 'ab' )
t( s, 1 )
t( f, 2 )

s, f = bafind( 'a', 'b', 'xaxbx' )
t( s, 2 )
t( f, 4 )

s, f = bafind( 'a', 'b', 'aabb' )
t( s, 1 )
t( f, 4 )

s, f = bafind( 'a', 'b', 'aababb' )
t( s, 1 )
t( f, 6 )

s, f = bafind( 'a+', 'b+', 'aaabb' )
t( s, 1 )
t( f, 5 )

s, f = bafind( 'a', 'b', 'a' )
t( s, nil )
t( f, nil )

s, f = bafind( 'a', 'b', 'b' )
t( s, nil )
t( f, nil )

s, f = bafind( 'a', 'b', 'ba' )
t( s, nil )
t( f, nil )

s, f = bafind( 'a', 'b', 'aab' )
t( s, nil )
t( f, nil )

--------------------------------------------------------------------------
-- TODO : delete !!! just some benchmarks !!! vvvvvvvvvvvvvvvvvvvvvvvvvvvv
local do_banchmark = false if do_banchmark then

local select = select

local a = function(r,...) r[1]=select('#',...) return ... end
local b = function() return nil,2,3,nil,5,6,7,8,nil end
local c = function(...) return ...,select('#',...)  end

local N = 99999
local s

local u={}
s=os.clock()
for k=1,N do a(u,b()) end
print('# info ',os.clock()-s)

s=os.clock()
for k=1,N do c(b()) end
print('# info ',os.clock()-s)

------------------------

local N = 99 --2000
local S = 10000

local cur = {x='1'}
for i=1,N do
  cur = setmetatable({},{__index=cur})
end
local s=os.clock()
local x
for i=1,S do x = cur.x end
print('# info y',os.clock()-s)
print('# info y',cur.x)

local cur = {x='1'}
local lst = {}
for i=1,N do
  lst[1+#lst] = {}
end
lst[#lst] = cur
cur = setmetatable({},{__index=function(t,k) for i=1,#lst do if nil ~= lst[i][k] then return lst[i][k] end end end})
local s=os.clock()
local x
for i=1,S do x = cur.x end
print('# info x',os.clock()-s)
print('# info x',cur.x)

local cur = {x='1'}
for i=1,N do
  local o = cur
  local n = setmetatable({},{__index=function(t,k) return o[k] end})
  cur = n
end
local s=os.clock()
local x
for i=1,S do x = cur.x end
print('# info x',os.clock()-s)
print('# info x',cur.x)

end
-- TODO : delete !!! just some benchmarks !!! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--------------------------------------------------------------------------

t.test_embedded_example()

t()
