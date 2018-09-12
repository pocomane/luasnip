--[===[DOC

= templua

[source,lua]
----
function templua( template [, ename] ) --> ( sandbox ) --> expstr, err
----

Expand the Lua code contained in the `template` string and generates a
function.  The returned function, when called, will execute the lua code in the
`template` and it will return the template `expstr` result string.

The code in the `template` can be specified with the following patterns:

`@{luaexp}`::
Will be substituted with the result of the Lua expression.

`@{{luastm}}`::
Embeds the Lua statement. This allow to mix Lua code and verbatim text.

From the code in the statement pattern, the `_o` function can be used to
produce the `template` output. This name can be changed using the optional
`ename` string parameter.

Moreover, the content of the `sandbox` table is injected into the environment
of the Lua code (both expressions and statements). This allows you to pass
parameters to the template.

]===]

local function templua( template, ename ) --> ( sandbox ) --> expstr, err
   if not ename then ename = '_o' end
   local function expr(e) return ' '..ename..'('..e..')' end
  
   -- Generate a script that expands the template
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

   -- The generator must be run only if at least one @{} was found
   local run_generator = ( script ~= template )

   -- Return a function that executes the script with a custom environment
   return function( sandbox )
    if not run_generator then return script end
    local expstr = ''
    if 'table' ~= type( sandbox ) then
      return nil, "templua generator requires a sandbox"
    end
    local oldout = sandbox[ ename ]
    sandbox[ ename ] = function( out ) expstr = expstr..tostring(out) end
    local generate, err = load( script, 'mint_script', 't', sandbox )
    if not generate or err then
        sandbox[ ename ] = oldout
       return nil, err..'\nTemplate script: [[\n'..script..'\n]]'
    end
    local ok, err = pcall(generate)
    sandbox[ ename ] = oldout
    if not ok or err then
       return nil, err..'\nTemplate script: [[\n'..script..'\n]]'
    end
    return expstr
  end
end

return templua