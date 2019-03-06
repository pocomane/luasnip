local factory = require 'factory'
local t = require 'testhelper'

local makeA, isA = factory(function(ins)
  if not ins.built then ins.built = '' end
  ins.built = ins.built .. 'A'
end)

local makeB, isB = factory(function(ins)
  if not ins.built then ins.built = '' end
  ins.built = ins.built .. 'B'
end)

local makeC, isC = factory(function(ins)
  makeA(ins)
  makeB(ins)
  if not ins.built then ins.built = '' end
  ins.built = ins.built .. 'C'
end)

local a = makeA()
local b = makeB()
local c = makeC { built = 'X' }

t( a.built, 'A' )
t( b.built, 'B' )
t( c.built, 'XABC' )

t( isA(a), true )
t( isB(a), false )
t( isC(a), false )

t( isA(b), false )
t( isB(b), true )
t( isC(b), false )

t( isA(c), true )
t( isB(c), true )
t( isC(c), true )

makeA, isA = factory(function(ins)
  local private1, private2 = {'p1'}, {'p2'}
  function ins:getprivate()
    return private1, private2
  end
end)

local a = makeA()
local d = makeA()

local B, C = a:getprivate()
local E, F = d:getprivate()

t( true, B ~= E )
t( true, C ~= F )
t( 'p1', B[1] )
t( 'p1', E[1] )
t( 'p2', C[1] )
t( 'p2', F[1] )

-- Method protection example
makeA, isA = factory(function(ins)
  ins.t = 'a'
  return setmetatable({}, { __index = ins })
end)
a = {}
b = makeA(a)

t( a.t, 'a' )
t( b.t, 'a' )
a.t = 'c'
t( a.t, 'c' )
t( b.t, 'c' )
b.t = 'b'
t( a.t, 'c' )
t( b.t, 'b' )

t( isA(a), true ) -- TODO : change this ?
t( isA(b), true )

t.test_embedded_example()

t()

