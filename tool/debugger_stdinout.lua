--[===[DOC

= Command line debugger

The 'debugger_stdinout' module provide a full command line debugger for lua. It
is based on 'stepdebug' module of Luasnip. It install a step-debug handler that
read from the standard input and passes the line to 'stepdebug', so you can
refer to <<stepdebug>> documentation for a list of accepted commands.

As described in the <<stepdebug>> documentataion, it does not support classical
breakpoint through filename and line number, but the execution can be
explicitally stopped in the debugged source code with somethig like 

```
LD = require 'debug_stdinout' ; LD"break"
```

Moreover the 'localbind' module of Luasnip is exposed in the 'L' global, so you
can access locals and upvalues of the current executed line with simple
expressions like `print(L.a_local_variable)`. Values can be changed with the
intuitive syntax `L.a_local_variable = "New value"`. Also deeper stack
inspections are possible with expressions like
`print(L(1).a_caller_local_variable)`.

No command line history or completion is supported.

]===]

local ls = require 'luasnip'
local stepdebug = ls.stepdebug
local localbind = ls.localbind

do

  local cachesource = {}

  function getsource( level, pre, post )
    if not level then level = 1 end
    local info = debug.getinfo( level )
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
    local result = {}
    if not pre then pre = 1 end
    if not post then post = #s end
    if post < 0 then post = #s +1 -post end
    for l = cur-pre, cur+post do
      result[1+#result] = s[l]
    end
    return result, fil, cur
  end
end

stepdebug(function(b,e)
  L = localbind(b) -- global table to access local variables
  local pre, post = 5, 5
  local src, fil, lnn = getsource(b+1, pre, post)
  print('> '..b..' @ '..fil..' : '..lnn)
  print('+---------------------')
  for i, s in ipairs(src) do
    if i == pre+1 then
      print('>   '..s)
    else
      print('|   '..s)
    end
  end
  print('+---------------------')
  io.write('> ') io.flush()
  print(stepdebug(io.read("*l")))
end)

