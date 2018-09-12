local combinetab = require 'combinetab'
local t = require 'testhelper'

local r, n
local function tres()
  r = {}
  n = 0
end
local function tcol(x)
  local t = {}
  for k,v in pairs(x) do t[k] = v end
  n = n + 1
  r[n] = t
end

tres()
combinetab({k='a'},{k='b'}, tcol)
t( #r, 2 )
t( r[1], {k='a'}, t.deepsame )
t( r[2], {k='b'}, t.deepsame )

tres()
combinetab({k='a',x='a'},{k='b'}, tcol)
t( #r, 4 )
t( r[1], {k='a',x='a'}, t.deepsame )
t( r[2], {k='b',x='a'}, t.deepsame )
t( r[3], {k='a'}, t.deepsame )
t( r[4], {k='b'}, t.deepsame )

tres()
combinetab({k='a'},{k='b',x='b'}, tcol)
t( #r, 4 )
t( r[1], {k='a'}, t.deepsame )
t( r[2], {k='b'}, t.deepsame )
t( r[3], {k='a',x='b'}, t.deepsame )
t( r[4], {k='b',x='b'}, t.deepsame )

tres()
combinetab({k='a'},{k='b'},{k='c'}, tcol)
t( #r, 3 )
t( r[1], {k='a'}, t.deepsame )
t( r[2], {k='b'}, t.deepsame )
t( r[3], {k='c'}, t.deepsame )

t()
