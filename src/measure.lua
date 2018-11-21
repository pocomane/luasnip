--[===[DOC

= measure

[source,lua]
----
function measure( partMea ) --> sampleFunc
----

This function generate a sample handling function `sampleFunc`. It can be used
to add repeted measurement of a quantity, and get the following sample statisitcs:

- Mean
- Standard deviation
- Skewness (i.e. sqrt(sample-number) * 3rd-momentum / 2nd-momentum^(3/2) )
- Kurtosis

If the `partMea` table is passed, it will be interpreted as a seqeunce of different
`sampleFunc`. The returned `sampleFunc` will be intialized as the union of all
the partial sets of measurements. A partition formula is used to merge the
measurements [1].

The `sampleFunc` can be used in two forms:

[source,lua]
----
function sampleFunc( valueNum ) --> nil
function sampleFunc( nil ) --> meanNum, deviationNum, SkewnessNum, kurtosisNum, sizeNum
----

In the first form, the `valueNum` number will be added to the measurements. This
causes the recalculation of the stored sample momentums.

In the second form, the statistics are calculated and returned.

== References

[1] Philippe Pébay. SANDIA REPORT SAND2008-6212 (2008) - https://prod.sandia.gov/techlib-noauth/access-control.cgi/2008/086212.pdf

== Example

[source,lua,example]
----
local measure = require 'measure'
local m

local a = measure()
a(2)
a(2)
m = a()
assert( m > 2 -1e-4 and m < 2 +1e04 )

local b = measure()
b(4)
b(8)
m = b()
assert( m > 6 -1e-4 and m < 6 +1e04 )

local c = measure{a, b}
m = {c()}

assert( m[1] > 4.0   -1e-4 and m[1] < 4.0   +1e04 )
assert( m[2] > 2.828 -1e-4 and m[2] < 2.828 +1e04 )
assert( m[3] > 0.816 -1e-4 and m[3] < 0.816 +1e04 )
assert( m[4] > 2.0   -1e-4 and m[4] < 2.0   +1e04 )
assert( m[5] > 4     -1e-4 and m[5] < 4     +1e04 )
assert( m[6] > 2     -1e-4 and m[6] < 2     +1e04 )
assert( m[7] > 8     -1e-4 and m[7] < 8     +1e04 )
----

]===]

local sqrt = math.sqrt

local aux_get_state = {}

local function measure( partMea ) -->

  -- init
  local M1 = 0
  local M2 = 0
  local M3 = 0
  local M4 = 0
  local n = 0
  local min = nil
  local max = nil

  local function import_set(M1F2, M2F2, M3F2, M4F2, n2, min2, max2)
    if n == 0 then
      M1, M2, M3, M4, n = M1F2, M2F2, M3F2, M4F2, n2
      min = min2
      max = max2
    else
      -- Formula: Philippe Pébay. SANDIA REPORT SAND2008-6212 (2008) - https://prod.sandia.gov/techlib-noauth/access-control.cgi/2008/086212.pdf
      local M1F1, M2F1, M3F1, M4F1, n1 = M1, M2, M3, M4, n
      local n1p2 = n1 + n2
      local nn = n1 * n2
      local n1sq = n1 * n1
      local n2sq = n2 * n2
      local D = (M1F2 - M1F1) / n1p2
      local DSQ = D * D
      M1 = M1F1 + n2 * D
      M2 = M2F1 + M2F2
           + nn * DSQ * n1p2
      M3 = M3F1 + M3F2
           + nn * (n1 - n2) * n1p2 * D * DSQ
           + 3 * (n1 * M2F2 - n2 * M2F1) * D
      M4 = M4F1 + M4F2
           + nn * (n1sq + n2sq - nn) * n1p2 * DSQ * DSQ
           + 6 * (n1sq * M2F2 + n2sq * M2F1) * DSQ
           + 4 * (n1 * M3F2 - n2 * M3F1) * D
      n = n1p2
      if min2 and min2<min then
        min = min2
      end
      if max2 and max2>max then
        max = max2
      end
    end
  end

  local function import_all( ml )
    for _, m in pairs( ml ) do
      import_set( m( aux_get_state ))
    end
  end

  local function get_measure( value )
    if value == aux_get_state then
      return M1, M2, M3, M4, n, min, max
    elseif value ~= nil then
      import_set(value, 0, 0, 0, 1, value, value)
    end
    local m, d, s, k = M1, 0, 0, 0
    if n > 1 then
      d = sqrt( M2 /( n - 1 ))
    end
    if n > 1 and d > 0 then
      -- s = M3 /( n * d * d * d ) -- wikipedia
      s = M3 * sqrt(n) /sqrt( M2 * M2 * M2 ) -- wolfram
    end
    if M2 > 0 then
      k = M4 * n /( M2 * M2 )
    end
    return m,d,s,k,n,min,max
  end

  if partMea then import_all(partMea) end
  return get_measure
end

return measure
