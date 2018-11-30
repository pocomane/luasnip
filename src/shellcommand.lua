--[===[DOC

= shellcommand

[source,lua]
----
function shellcommand( commandTab ) --> commandStr
----

Construct the shell command string `commandStr`, suitable to be executed by
`os.execute`. The input is the array of strings `commandTab`, the first being
the external command path, the other being all the arguments.

Command path and argument strings can contain characters that have special
meaning for the shell: they will be quoted.

The `commandTab` argument can contain also the following key, that have a
special meaning:

- `input`: the generated command will instruct the shell to get the standard
console input of the command from a file; the path to this file is the one
containied in this table field
- `output`: the generated command will instruct the shell to put the standard
console ouput and error of the command into a file; the path to this file is
the one containied in this table field
- `append`: if true and the `output` field is also set, the ouput will be
appended to the file instead of overwrite previous data

== Example

[source,lua,example]
----
local shellcommand = require 'shellcommand'

local lua = 'lua'
for a = 0, -99, -1 do
  if not arg[a] then break end
  lua = arg[a]
end

local cmd = shellcommand{lua, '-e', 'io.open([[tmp.tmp]],[[w]]):write(arg[0]);os.exit()', " '"}

os.remove('tmp.tmp')
os.execute(cmd)

assert( " '" == io.open('tmp.tmp','r'):read('a') )
----

]===]

local escapeshellarg = (function()
-- [SNIP:escapeshellarg.lua[
local quote_function

local function escapeshellarg( str ) --> esc

  local function posix_quote_argument(str)
    if not str:match('[^%a%d%.%-%+=/,:]') then
      return str
    else
      str = str:gsub( "[$`\"\\]", "\\%1" )
      return '"' .. str .. '"'
    end
  end

  local function windows_quote_argument(str)
    str = str:gsub('[%%&\\^<>|]', '^%1')
    str = str:gsub('"', "\\%1")
    str = str:gsub('[ \t][ \t]*', '"%1"')
    return str
  end

  if not quote_function then
    quote_function = windows_quote_argument
    local shell = os.getenv('SHELL')
    if shell then
      if '/' == shell:sub(1,1) and 'sh' == shell:sub(-2, -1) then
        quote_function = posix_quote_argument
      end
    end
  end

  return quote_function(str)
end

return escapeshellarg
-- ]SNIP:escapeshellarg.lua]
end)()

local function shellcommand( commandTab ) --> commandStr
  if not commandTab then return '' end
  local commandStr = ''
  for _, v in ipairs(commandTab) do
    commandStr = commandStr .. ' ' .. escapeshellarg(v)
  end
  local ri = ' < '
  local ro = ' > '
  local re = ' 2> '
  local moe = ''
  if commandTab.append then
    ro = ' >> '
    re = ' 2>> '
  end
  if commandTab.output == commandTab.error then
    commandTab.error = nil
    moe = ' 2>&1'
  end
  if commandTab.input then
    commandStr = commandStr .. ri .. escapeshellarg(commandTab.input) .. moe
  end
  if commandTab.output then
    commandStr = commandStr .. ro .. escapeshellarg(commandTab.output) .. moe
  end
  if commandTab.error then
    commandStr = commandStr .. re .. escapeshellarg(commandTab.error) .. moe
  end
  return commandStr
end

return shellcommand
