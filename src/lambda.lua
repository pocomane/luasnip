--[===[DOC

= lambda

[source,lua]
----
function lambda( def ) --> func, err
----

Allows to define functions using a compact lambda-like syntax. It parse the
`def` string and returns the lua function `func` that execute the input code.
In case of error it return `nil` plus the `err` error string.

This function internally works by expanding the following patterns into a
standard lua function definition.
Then it is parsed by the common Lua _load_/_loadstring_ function.

The fundamental expanded pattern is 'prologue|statement;expression'.

It generate a function that has 'prologue' as nominal arguments.
It can be a comma separated list, like in 'x,y,z|statement;expression'.

Then the 'statement' will be injected as the function body.
It must be a sequence of lua statements like in
'prologue|for k = 1,10 do print(k) end print("ok");expression'.

At end of the function the 'expression' will be returned.
So it must be a valid Lua expression like in 'prologue|statement;math.random(2)'.

When the 'prologue' is missing, a default one will be used consisting of the
first 6 alphabet letters.
'expression' must always be given but the 'statement' and the separation ';' can
be missing.
Indeed, in the main use case, prologue and statement will be missing and only
the expression will be given.

== Example

[source,lua,example]
----
local lambda = require "lambda"

local inc = lambda'a+1'
local dup = lambda"x| x=x*2; x"
local dup2 = lambda"x| x=x*2; x"

assert( inc ~= dup2 )
assert( dup == dup2 )

assert( inc(7) == 8 )
assert( dup(3) == 6 )
----

]===]

local load = load
local memo = setmetatable( {}, { __mode = "kv" } )

local function lambda( def ) --> func, err

   -- Check cache
   local result = memo[def]
   if result then return result end

   -- Find the body and symbolic arguments
   local symb, body = def:match( "^(.-)|(.*)$" )
   if not arg or not body then
      symb = "a,b,c,d,e,f,..."
      body = def
   end

   -- Split statements from the last expression
   local stat, expr = body:match( "^(.*;)([^;]*)$" )

   -- Generate standard lua function definition
   local func = "return( function( "..symb..")"
   if not expr or expr == "" then
      func = func.."return "..body
   else
      func = func..stat.."return "..expr
   end
   func = func.." end )( ... )"

   -- Generate the function
   local result, err = load( func, "lambda", "t" )
   if result and not err then
     memo[def] = result
   end
   return result, err
end

return lambda
