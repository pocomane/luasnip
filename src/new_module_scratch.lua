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

assert ( nil == new_module_scratch.a_new_idea() )

----

]===]

-----------------------------------------------------------

-- TODO : tabsearch ?
-- TODO : converter rawtag_table -> rawtag_string ???

----------------------------------------------------------

local new_module_scratch = {}

do
  local function a_new_idea()
  end

  new_module_scratch.a_new_idea = a_new_idea
end

----------------------------------------------------------

do
  local function varesult( ... )
    return select( '#', ... ), ...
  end

  new_module_scratch.varesult = varesult
end

----------------------------------------------------------

do
  local function dispatcher( a, b, c )
    local meta, read, write, pair
    if a ~= 'hide' then
      read, write, pair = a, b, a
    else
      meta = 'hidden'
      read, write = b, c
      pair = b -- wrong ???
    end
    return setmetatable({},{
      __metatable = meta,
      __newindex = write,
      __index = read,
      __pairs = pair,
      __ipairs = pair,
    })
  end

  new_module_scratch.dispatcher = dispatcher
end

----------------------------------------------------------

do
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
end

-----------------------------------------------------------

do

  local cachesource = {}

  local function getsource( level )
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

  new_module_scratch.getsource = getsource
end

-----------------------------------------------------------

local tableclear
do
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

  new_module_scratch.tableclear = tableclear
end

-----------------------------------------------------------

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

  new_module_scratch.except = {
    try = try,
    trow = trow,
  }
end

----------------------------------------------------------

do

  -- templua simplification ?!!
  local function templua( template, ename ) --> scriptString
     if not ename then ename = '_o' end
     local function expr(e) return ' '..ename..'('..e..')' end

     local script = template:gsub( '(.-)@(%b{})([^@]*)',
       function( prefix, code, suffix )
          prefix = expr( string.format( '%q', prefix ) )
          suffix = expr( string.format( '%q', suffix ) )
          code = code:sub( 2, #code-1 )

          if code:match( '^{.*}$' ) then
             return prefix .. code:sub( 2, #code-1 ) .. suffix
          else
             return prefix .. expr( code ) .. suffix
          end
       end
     )

     return script
  end

  local function tempnest( script )
    local stepcount = 0
    while true do
        local translated = templua( script )
        if translated == script then break end
        stepcount = stepcount + 1
        script = translated
    end
    local expanded = script
    for i = 1, stepcount do
      local nextstep = ''
      local env = setmetatable( {}, { __index = _ENV })
      env._o = function(x) nextstep = nextstep .. tostring(x) end -- TODO : use ename somehow
      local f, e = load( expanded, "expander", "t", env )
      if e ~= nil then return nil, e end
      local s, e = pcall(f)
      if not s then return e end
      expanded = nextstep
    end
    return expanded
  end

  new_module_scratch.tempnest = tempnest
end

----------------------------------------------------------

do
  local function loadfunc(a,b,c,...)
    local env = {}
    local func, err = load( a, b or 'template', c or 't', env, ...)
    if err ~= nil then return nil, err end
    return function( sandbox )
        sandbox = sandbox or {}
        local metatable = {
            __index = sandbox,
            __newindex == sandbox,
        }
        setmetatable( env , metatable )
        return func()
    end
  end

  new_module_scratch.loadfunc = loadfunc
end

----------------------------------------------------------

do
  local coresume = coroutine.resume

  local coyield = coroutine.yield
  local taunpack = table.unpack

  local function auxpack( a, b, ... )
    return a, b, { ... }
  end

  local function cocatch( wait_for, co, ... )
    local status, signal, rest = auxpack( coresume( co, ... ))
    while wait_for ~= nil and signal ~= wait_for do
      status, signal, rest = auxpack( coresume( co, coyield( wait_for, taunpack( rest) )))
    end
    return status, signal, taunpack( rest )
  end

  new_module_scratch.cocatch = cocatch
end

----------------------------------------------------------

do

  local function bafind( openpat, closepat, text, init )
    local current = init or 1
    local count = 0
    local start, finish
    local a, b, c, d
    repeat
      if not a then a, b = text:find( openpat, current ) end
      if not c then c, d = text:find( closepat, current ) end
      if a and (not c or a < c) then
        current = b + 1
        count = count + 1
        start = start or a
        a, b = nil, nil
      elseif c and (not a or c < a) then
        current = d + 1
        count = count - 1
        if count == 0 then
          finish = d
        end
        c, d = nil, nil
      else
        break
      end
    until count <= 0
    start = finish and start
    finish = start and finish
    return start, finish
  end
  
  new_module_scratch.bafind = bafind
end

----------------------------------------------------------

return new_module_scratch
