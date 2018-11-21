--[===[DOC

= taptest

[source,lua]
----
function taptest( actual, expect [, compare [, message ]] ) --> msg
function taptest( diagnostic ) --> msg
function taptest() --> msg
----

This function behaves differently based on the number of arguments.

* It can check actual values versus expected ones.
* It can print diagnostic.
* Or it can print tests summary when called without arguments.

All the output is done in the Test Anything Protocol (TAP) format.
In case of failure some information are appended, like source position, actual
value, etc.

`actual` is actual value got from the code under test.

`expect` is the expected value

`compare` is the compare function.  If it is given as 3-rd or 4-th argument,
this function will be called with _actual, expected_ as argument.  If it return
true the test will be assumed to success, otherwise it will be assumed to be
failed.  If no compare function is given, the _==_ operator will be used as
default.

`message` is a message string is given as 3-rd or 4-th argument, it will be
appended to the TAP formatted line, only in case of failing test.  This is ment
as a way to give additional information about the failure.

When called with just one string argument `diagnostic`, a TAP diagnostic block
will be printed.  A '#' will be prepended to each line of the diagnostic
message.

This function returns the `msg` string containing the same message written to
the stdout.  This message is a TAP check line or a sequence of TAP diagnostic
lines.

A function calling taptest can mask a possible fail, and blame the function
upper in the stack, by setting at 'true' a local variable called
'taptest_blame_caller'.

== Inspired by

https://testanything.org/
https://github.com/telemachus/tapered

== Example

[source,lua,example]
----
local taptest = require "taptest"

assert( taptest( 1, 1 ):match("^ok %d+$") )
assert( taptest( 'xxx' ) == '# xxx' )

assert( taptest( 1, 2 ):match("^not ok %d+ %- .*%. Mismatch: %[1%] VS %[2%]%. $") )

local summary = taptest()
assert( summary:match("%d+ tests failed") )
assert( summary:match("1..%d+$") )
----

]===]

local test_count = 0
local fail_count = 0

local function taptest( ... ) --> msg

   local function diagnostic( desc )
      local msg = "# "..desc:gsub( "\n", "\n# " )
      return msg
   end

   local function print_summary()
      local msg = '\n' .. tostring(fail_count) .. " tests failed\n"
      if fail_count == 0 then msg = '\nall is right\n' end
      msg = diagnostic(msg)
      local plan = "1.."..test_count
      return msg..'\n'..plan
   end

   local function get_report_position()
     local result
     local stackup = 2
     local testpoint = false
     while not testpoint do
       stackup = stackup + 1
       result = debug.getinfo(stackup)
       if not result then
         return debug.getinfo(3)
       end
       local j = 0
       testpoint = true
       while true do
         j = j + 1
         local k, v = debug.getlocal(stackup, j)
         if k == nil then break end
         if v and k == 'taptest_blame_caller' then
           testpoint = false
           break
         end
       end
       if testpoint then return result end
     end
   end

   local function do_check(got, expected, a, b)

      -- Extra arg parse and defaults
      local checker, err
      if "string" == type(a) then err = a end
      if "string" == type(b) then err = b end
      if not err then err = "" end
      if "function" == type(a) then checker = a end
      if "function" == type(b) then checker = b end
      if not checker then checker = function( e, g ) return e == g end end

      -- Check the condition
      test_count = test_count + 1
      local ok, info = checker( got, expected )

      -- Generate TAP line
      local msg = ""
      if ok then
         msg = msg.."ok "..test_count
      else
         fail_count = fail_count + 1
         local i = get_report_position()

         msg = msg
               .."not ok " .. test_count .. " - "
               ..i.source:match( "([^@/\\]*)$" )..":"..i.currentline..". "
      end

      -- Append automatic info
      if not ok and not info then
        msg = msg
          .. "Mismatch: ["..tostring( got ).."] "
          .. "VS ["..tostring( expected ).."]. "
      end

      -- Append user-provided info
      if info then
        msg = msg.." "..info
      end

      if not ok then
        msg = msg..err
      end

      return msg
   end

   local narg = select( "#", ... )
   if     0 == narg then return print_summary()
   elseif 1 == narg then return diagnostic( select( 1, ... ) )
   elseif 4 >= narg then return do_check( ... )
   end

   return nil, "Too many arguments"
end

return taptest
