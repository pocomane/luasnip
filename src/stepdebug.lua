--[===[DOC

= stepdebug

[source,lua]
----
function stepdebug( handleFunc ) --> nil
function stepdebug( commandStr ) --> nil | scriptResult
----

== Description

This function implements a debugger flow control like the common ones found in
tools like gdb or some IDE. An handler function can be defined to be called at
every step when the the debug mode is active.

It works differently based on the type of the argument: if the `handleFunc`
function is passed it will be installed as handler; if the `commandStr` string
is passed, it will parse it as a standard debugger command; if the `commandStr`
string is not a valid debugger command, it will parsed as a lua chunk to be
executed in the current call stack position.

For example, we suppose to install an header that read from standard input and
pass the data to `stepdebugger` itself. When the application hits a
`stepdebugger'break'`, the `break` command will be executed. It will stop the
execution enabling the debug mode. So the handler will be called and the
application will wait for an input on the standard input. Any lua code you
write into will be parsed as it was called just after the break i.e. with the
same call stack. After the code execution, the application will be stopped
again, waiting again for an input (i.e. the handler is called again). The
execution is not moved, you are still just after the `stepdebugger'break'`
line. You can input 'next<enter>' to move to the next line of code, or
'continue<enter>' to resume the execution (i.e. do not call the handler
anymore) until the next break.

When called, two parameters will be passed to the handler:

- The stack level at which the break was; you should use this index in all the
call to the lua debug API
- The event type that caused the handler to be called; it is the same argument
passet do an hook set by the lua API function `debug.sethook`

The supported debugger commands are:

- 'quit' - will quit the application
- 'break' - pass to the debug mode; the handler will be called from now on
- 'continue'or 'c' - turn off the debug mode; the handler will not be called until the next `break`
- 'step' or 's' - do not call the handler anymore until the next line of execution
- 'next' or 'n' - do not call the handler anymore until the next line of execution of the current block
- 'finish' or 'f' - do not call the handler anymore until the end of the current block

Please note that if you want to access the locals values of the block calling
`stepdebugger'break'`, you have to use the `debug.getlocal` API. This could be
a bit unconfortable, so a wrapper is strongly suggested, e.g. the `localbind`
function of LuaSnip. For a complete command line debugger implementation based
on `stepdebug` and `localbind`, see the LuaSnip tool `debugger_stdinout`.

]===]

local function stackbottom()
  local result = 1
  while debug.getinfo(result) do
    result = result + 1
  end
  return result
end

local onstep = function() end
local stack_level = 0
local deb_enabled = false
local stack_level_change = nil

local next_line

local this_source
local function deb_hook(event)
  if stack_level_change then
    stack_level = stack_level + stack_level_change
    stack_level_change = nil
  end
  if not deb_enabled then return end
  if not this_source then
    this_source = debug.getinfo(1).source
  end
  local b = stackbottom()
  if b > stack_level then return end
  local f = debug.getinfo(2)
  if f.source == this_source then return end
  if f.source:sub(1,1) ~= '@' then return end
  if event == 'return' then stack_level = b-1 end
  if event ~= 'line' then return end
  local result = onstep(3,event)
  if next_line then
    next_line = nil
    return result
  end
  return deb_hook(event) --> tail call
end

local function deb_next_line()
  next_line = true
  return nil
end

local function deb_break()
  stack_level = stackbottom()
  deb_enabled = true
  debug.sethook(deb_hook,'clr')
end

local function deb_continue()
  deb_enabled = false -- currently redundant
  debug.sethook() -- currently redundant
end

local function deb_target( level )
  stack_level_change = level
end

local function deb_chunk_exec( code )
  local exec, err = load('return '..code, '(*iteractive)', 't')
  if not exec or err then
    exec, err = load(code, '(*iteractive)', 't')
  end
  if not exec or err then
    print(err)
  else
    local ok, result = pcall(function() return exec() end)
    if not ok then print(result) end
    return result
  end
end

local function stepdebug( op )
  if 'function' == type(op) then
    onstep = op
    return
  end

  local cmd = op:lower():gsub('^[ \t]*(.-)[ \t]*$','%1')

  if '' == op then return
  elseif 'n' == op or 'next' == op then return deb_next_line()
  elseif 's' == op or 'step' == op then deb_target(1)
  elseif 'f' == op or 'finish' == op then deb_target(-1)
  elseif 'c' == op or 'continue' == op then deb_continue()
  elseif 'quit' == op then os.exit()

  elseif 'break' == op then
    deb_break()
    stack_level = stack_level -1

  else
    return deb_chunk_exec(op)
  end
end

return stepdebug