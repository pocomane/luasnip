--[===[DOC

= escapeshellarg

[source,lua]
----
function escapeshellarg( str ) --> esc
----

Adds double quotes around the `str` string and quotes/escapes any existing
double quotes allowing you to pass the result `esc` string directly to a shell
function and having it be treated as a single safe argument.

This function should be used to escape individual arguments to shell functions
coming from user input.

== Example

[source,lua,example]
----
local escapeshellarg = require "escapeshellarg"

local esced = escapeshellarg(" '")

local lua = 'lua'
for a = 0, -99, -1 do
  if not arg[a] then break end
  lua = arg[a]
end

os.remove('tmp.tmp')
os.execute(lua..' -e "io.open([[tmp.tmp]],[[w]]):write(arg[0]);os.exit()" '..esced)

assert( " '" == io.open('tmp.tmp','r'):read('a') )

----

]===]

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
