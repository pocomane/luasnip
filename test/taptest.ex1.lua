local taptest = require "taptest"
local t = require "testhelper"
-- taptest is both the "Unit under test" (taptest) and the "Test framework" (t - testhelper)

-- To avoid confusion (as much as it is possible) t will be always used in its
-- easest form: it just checks that the two argument are equals.
-- Since taptest always returns what it print on stdout, the returned
-- value of taptest is checked

-- wrap the taptest to simplify line number checks
local fake_test_count = 1
local taptest_wrapped = taptest
local function taptest( ... )
   fake_test_count = fake_test_count + 2
   local result = taptest_wrapped( ... )
   return result -- avoid tail call
end

t( taptest( 1, 1 ), "ok 1" )

-- Note: since at each line two test will be done (one for taptest and one for tf)
-- the test counter step is 2, not 1
t( taptest( 1, 1 ), "ok 3" )

-- Additional infos when the test fails
t( taptest( 1, 2 ),
   "not ok 5 - taptest.ex1.lua:15. Expectation [2] does not match with [1]. " )

-- Custom infos on fail
t( taptest( 1, 2, "Not good!" ),
   "not ok 7 - taptest.ex1.lua:15. Expectation [2] does not match with [1]. Not good!" )

-- Custom compare function
t( taptest( 1, 2, function( a, b ) return a < b end ),
   "ok 9" )
t( taptest( 2, 1, function( a, b ) return a < b end ),
   "not ok 11 - taptest.ex1.lua:15. Expectation [1] does not match with [2]. " )

-- Custom compare function and message
t( taptest( 1, 1, function( a, b ) return a ~= b end, "Not good!" ),
   "not ok 13 - taptest.ex1.lua:15. Expectation [1] does not match with [1]. Not good!" )
t( taptest( 1, 1, "Not good!", function( a, b ) return a ~= b end ),
   "not ok 15 - taptest.ex1.lua:15. Expectation [1] does not match with [1]. Not good!" )

-- Single argument = Tap diagnostic
t( taptest( "new\nsuite" ), "# new\n# suite" )

-- Checker function can add useful information
t( taptest( 1, 1, function( a, b ) return a == b, "- additional info" end ),
   "ok 18 - additional info" )

t( taptest( 1, 2, function( a, b ) return a == b, "- additional info" end ),
   "not ok 20 - taptest.ex1.lua:15.  - additional info" )

-- No argument = Summary and final plan
t( taptest(), "# \n# 6 tests failed\n# \n1..21" )

local function taptest_masked(...)
  local taptest_blame_caller = true
  r = taptest_wrapped(...)
  return r -- no tail call
end

t( taptest_masked( 1, 2 ), "not ok 23 - taptest.ex1.lua:64. Expectation [2] does not match with [1]. " )

t( taptest( nil, nil ), "ok 25" )
t( taptest( nil, true, function(a,b) return a~=b end ), "ok 27" )
t( taptest( true, nil, function(a,b) return a~=b end ), "ok 29" )

t()

-- In case all the tests are successful, the line
-- # all is right
-- will be substitued to the '# 5 tests failed' one
