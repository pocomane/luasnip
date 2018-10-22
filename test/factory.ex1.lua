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
  local private1, private2 = {}, {}
  function ins:getprivate()
    return private1, private2
  end
  return private1, private2
end)

local a, b, c = makeA()
local d, e, f = makeA()

local B, C = a:getprivate()
local E, F = d:getprivate()

t( b, B )
t( c, C )
t( e, E )
t( f, F )

t()

