--[===[DOC

= templua

[source,lua]
----
function templua( template ) --> ( sandbox ) --> expstr, err
----

Expand the Lua code contained in the `template` string and generates a
function.  The returned function, when called, will execute the lua code in the
`template` and it will return the template `expstr` result string.

The code in the `template` can be specified with the following patterns:

`@{luaexp}`::
Will be substituted with the result of the Lua expression.

`@{{luastm}}`::
Embeds the Lua statement. This allow to mix Lua code and verbatim text.

From the code in the statement pattern, the a global function can be used to
produce the `template` output. The function is in `_ENV[_ENv]`. If you need to
use it several times, you can consider to place on the top of the template
somethink like '${{ O = _ENV[_ENV] }}'.

The `sandbox` table is used as the  environment of the Lua code (both
expressions and statements). This allows you to pass parameters to the
template.

To escape the template sequencies, `@` can be substituded with `@{"@"}`, e.g.
`@{"@"}{error()}` can be used to insert `@{error()}` in the document without
expanding it.

== Example

[source,lua,example]
----
local templua = require( "templua" )

assert( templua( "Hello @{W}!" )({ W = "world" }) == "Hello world!")

local exp = templua( "Hello @{upper(W)}!" )
assert( exp{ W = "Anne", upper = string.upper } == "Hello ANNE!")
assert( exp{ W = "Bob", upper = string.upper } == "Hello BOB!")

assert( templua( "@{{for i=1,3 do}}Hello All! @{{end}}" )({})
  == 'Hello All! Hello All! Hello All! ' )
----

]===]

local setmetatable, load = setmetatable, load
local fmt, tostring = string.format, tostring
local error = error

local function templua( template ) --> ( sandbox ) --> expstr, err
   local function expr(e) return ' _ENV[_ENV]('..e..')' end
  
   -- Generate a script that expands the template
   local script = template:gsub( '(.-)@(%b{})([^@]*)',
     function( prefix, code, suffix )
        prefix = expr( fmt( '%q', prefix ) )
        suffix = expr( fmt( '%q', suffix ) )
        code = code:sub( 2, #code-1 )

        if code:match( '^{.*}$' ) then
           return prefix .. code:sub( 2, #code-1 ) .. suffix
        else
           return prefix .. expr( code ) .. suffix
        end
     end
   )

   -- Utility to append the script to the error string
   local function report_error( err )
     return nil, err..'\nTemplate script: [[\n'..script..'\n]]'
   end

   -- Special case when no template tag is found
   if script == template then
     return function() return script end
   end

   -- Template expander basic environmnent
   local expstr = ''
   local metaenv = {}
   local env = setmetatable( {}, metaenv )
   env[env] = function( out ) expstr = expstr..tostring(out) end

   -- Compile the template expander
   local generate, err = load( script, 'templua_script', 't', env )
   if err ~= nil then return report_error( err ) end

   -- Return a function that runs the expander with a custom environment
   return function( sandbox )
     expstr = ''
     if sandbox then
       metaenv.__index = sandbox
       metaenv.__newindex = sandbox
     else
       metaenv.__index = nil
       metaenv.__newindex = nil
     end
     local ok, err = pcall(generate)
     if not ok then return report_error( err ) end
     return expstr
  end
end

return templua
