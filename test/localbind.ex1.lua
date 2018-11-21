local localbind = require 'localbind'
local t = require 'testhelper'

-- Accessing local variable
;(function()
  local L = {}
  local lb = localbind( 1 )
  t( lb.L, L )
  lb.L = 1
  t( lb.L, 1 )
  t( L, 1 )
end)()

-- Accessing upvalue
local U = 1
;(function()
  local lb = localbind( 1 )
  t( lb.U, 1 )
  lb.U = 2
  t( lb.U, 2 )
  t( U, 2 )
end)()

-- Accessing deeper stack position
local U = 'u'
;(function()
  local L = U -- just to let U be linked in the compiled function
  L = 'l'
  t( localbind(1).L, 'l' )
  t( localbind(1).U, 'u' )
  ;(function()
    t( localbind(2).L, 'l' )
    t( localbind(2).U, 'u' )
    ;(function()
      t( localbind(3).L, 'l' )
      t( localbind(3).U, 'u' )
      localbind(3).L = 'L'
      localbind(3).U = 'U'
      t( localbind(3).U, 'U' )
      t( localbind(3).L, 'L' )
    end)();
    t( localbind(2).U, 'U' )
    t( localbind(2).L, 'L' )
  end)();
  t( localbind(1).U, 'U' )
  t( localbind(1).L, 'L' )
  t( L, 'L' )
end)();

-- Accessing global when no global is compiled-in
G = 1
;(function()
  local lb = localbind(1)
  t( lb.G, nil )
  lb.G = 2
  t( lb.G, 2 )
  t( lb._ENV, nil )
end)()
t( G, 1 )

-- Accessing global (compiled-in)
G = 1
local e = _ENV
;(function()
  local L = print -- print referred to let the global be linked in the compiled function
  local lb = localbind(1)
  t( lb.G, 1 )
  lb.G = 2
  t( lb.G, 2 )
  t( lb._ENV, e )
end)()
t( G, 2 )

-- Check variable type
G = 1
local U = 1
;(function()
  -- Note: global is linked due to t and localbind reference
  local L
  L = U -- U referred to let it be linked in the compiled function
  local lb = localbind(1)
  t( lb('L'), 'local' )
  t( lb('U'), 'upvalue' )
  t( lb('G'), 'nil' )
end)()

-- Check global variable type
G = 1
local U = 1
;(function()
  -- Note: global is linked due to t and localbind reference
  local L
  L = U -- U referred to let it be linked in the compiled function
  L = print -- print referred to let the global be linked in the compiled function
  local lb = localbind(1)
  t( lb('L'), 'local' )
  t( lb('U'), 'upvalue' )
  t( lb('G'), 'global' )
end)()

-- Accessing different global (compiled-in)
local chunkglobal = _ENV
local testglobal = {G=1}
G = 3
_ENV = testglobal
;(function()
  -- Note: global is linked due to t and localbind reference
  local lb = localbind(1)
  t( lb.G, 1 )
  t( G, 1 )
  lb.G = 2
  t( lb.G, 2 )
  t( G, 2 )
  t( lb._ENV, _ENV )
end)(localbind, t)
_ENV = chunkglobal
t( G, 3 )
t( testglobal.G, 2 )

-- Accessing hidden upvalue
local h = {}
local auxFunc, auxTest
do
  local H = h
  auxFunc = function( auxFunc )
    local L = H -- H referred just to be compiled into the funcition
    auxFunc()
    return 1 -- just to avoid tail recursion
  end
  auxTest = function() return H end
end
auxFunc(function()
  local lb = localbind( 2 )
  t( lb.H, h )
  lb.H = 1
  t( lb.H, 1 )
  t( lb('H'), 'upvalue' )
end)
t( auxTest(), 1 )

-- Binding iterator
local chunkglobal = _ENV
local testglobal = {type=type, pairs=pairs}
local iter = {}
local count = 0
_ENV = testglobal
;(function()
  local lb = localbind(1)
  for k, v in pairs(lb) do
    count = count + 1
    iter[k] = lb(k)..' '..type(v)
  end
end)(localbind, t)
_ENV = chunkglobal
t( iter._ENV, 'upvalue table' )
t( iter.count, 'upvalue number' )
t( iter.lb, 'local table' )
t( iter.iter, 'upvalue table' )
t( iter.localbind, 'upvalue function' )
t( iter.pairs, 'global function' )
t( iter.type, 'global function' )
t( count, 7 )

t.test_embedded_example()

t()

