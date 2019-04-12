--[===[DOC

= new_module_scratch

[source,lua]
----
function func( argBool[, optInt [, ...]] ) --> resultTab, errorStr
----

Here there is some scratch for some new Luasnip module, or improvement ideas.

== Example

[source,lua,example]
----
local new_module_scratch = require 'new_module_scratch'

assert ( nil == new_module_scratch.nothing() )

----

]===]

-----------------------------------------------------------

-- TODO : tabsearch ?
-- TODO : converter rawtag_table -> rawtag_string ???

----------------------------------------------------------

local new_module_scratch = {}
function new_module_scratch.nothing() return nil end

----------------------------------------------------------

local function varesult( ... )
  return select( '#', ... ), ...
end

new_module_scratch.varesult = varesult

----------------------------------------------------------

local function dispatcher( a, b, c )
  local read, write
  if a == 'hide' then
    if b then read = function(t,k) return b[k] end end
    if c then write = function(t,k,v) c[k]=v end end
  else
    read = a
    write = b
  end
  return setmetatable({},{
    __newindex = write,
    __index = read,
    __pairs = read, -- wrong when 'hide' ?!!!
    __ipairs = read, -- wrong when 'hide' ?!!!
  })
end

new_module_scratch.dispatcher = dispatcher

----------------------------------------------------------

local function method_accessor( obj )
  local result = {}
  for k, v in pairs( obj ) do
    if 'function' == type( v ) then
      result[ k ] = v
    end
  end
  return setmetatable( result, { __index = obj, __newindex = obj, })
end

new_module_scratch.method_accessor = method_accessor

-----------------------------------------------------------

local getsource
do

  local cachesource = {}

  function getsource( level )
    if not level then level = 1 end
    local info = debug.getinfo( 1+level )
    if not info then return nil, 'Invalid level' end
    local cur = info.currentline
    local fil = info.short_src
    local path = info.source
    path = path:sub(2)
    local s = cachesource[ path ]
    if not s then
      local f = io.open( path, 'r' )
      if not f then error() end
      s = {}
      while true do
        local line = f:read('l')
        if not line then break end
        s[1+#s] = line
      end
      f:close()
      cachesource[ path ] = s
    end
    return setmetatable({},{
      __index = function(t,k) return s[k] end,
      __newindex = function() error('xxx',2) end,
    }), info.short_src .. ':' .. info.currentline
  end
end

new_module_scratch.getsource = getsource

-----------------------------------------------------------

local function tableclear( ... )
  local a = select(1,...)
  if a == 'meta' then
  -- if a == 'raw' then
    for k=2,select('#',...) do
      local v=select(k,...)
      for K in pairs(v) do
        -- rawset(v,K)
        v[K]=nil
      end
    end
  else
    for k=1,select('#',...) do
      local v=select(k,...)
      for K in pairs(v) do
        rawset(v,K)
        -- v[K]=nil
      end
    end
  end
end

-----------------------------------------------------------

local except
do
  local cocreate, costatus = coroutine.create, coroutine.status
  local coresume, coyield = coroutine.resume, coroutine.yield

  local EXCEPTION = {}

  local function trow(...)
      return coyield(EXCEPTION, ...)
  end

  local function try(f,h)
    local t = cocreate(f)
    return (function(ok, ex, ...)
      if not ok then error(ex, ...) end
      if ex == EXCEPTION then
          return h(...)
      else
        -- handle normal yielding from/to a coroutine
        if costatus(t) == 'suspended' then
          return coresume(coyield(ex, ...))
        end
        return ok, ex, ...
      end
    end)(coresume(t))
  end

  except = {
    try = try,
    trow = trow,
  }
end

new_module_scratch.except = except

----------------------------------------------------------

return new_module_scratch
