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

From the code in the statement pattern, an utility function can be used to
produce the `template` output. The function is in the local variable `out`. If
you need to access a field of the passed environment that have the same name,
you can use '_ENV.out'.

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
   local function expr(e) return ' out('..e..')' end
  
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

   -- Compile the template expander in a empty environment
   local env = {}
   script = 'local out = _ENV.out; local _ENV = _ENV.env; ' .. script
   local generate, err = load( script, 'templua_script', 't', env )
   if err ~= nil then return report_error( err ) end

   -- Return a function that runs the expander with a custom environment
   return function( sandbox )

     -- Template environment and utility function
     local expstr = ''
     env.env = sandbox
     env.out = function( out ) expstr = expstr..tostring(out) end

     -- Run the template
     local ok, err = pcall(generate)
     if not ok then return report_error( err ) end
     return expstr
  end
end

return templua
