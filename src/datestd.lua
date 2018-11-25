--[===[DOC

= datestd

[source,lua]
----
function datestd( dateStr ) --> dateTab
function datestd( dateTab ) --> dateStr
----

This function parsea or generates a superset of the rfc3339 date/time string. When
a 'dateStr' string is passed, it is parsed and a 'dateTab' table is generated.
When a 'dateTab' table is passed, it is encoded as a 'dateStr' string.

The 'dateStr' string is a rfc3339 date, or just its time or date part. The zone
part is optional. E.g.:
```
2018-01-21 14:32:10.100-01:00
2018-01-21 14:32:10.100
2018-01-21
14:32:10.100
```

The 'dateTab' contains the following fields (they can be missing): year, month,
day, hour, min, sec, zone.

== Example

[source,lua,example]
----
local datestd = require 'datestd'

assert( '2018-01-21 14:32:10.100Z' == datestd {
  year=2018,
  month=1,
  day=21,
  hour=14,
  min=32,
  sec=10.1,
  zone=0
})

assert( '14:32:10.100' == datestd {
  hour=14,
  min=32,
  sec=10.1,
})

local d = datestd'2018-01-21 14:32:10.100Z'
assert( d.year ==2018 )
assert( d.month ==1 )
assert( d.day ==21 )
assert( d.hour ==14 )
assert( d.min ==32 )
assert( d.sec ==10.1 )
assert( d.zone ==0 )
----

]===]

local pack, unpack = table.pack, table.unpack

local function validate_date( dateTab )
  -- TODO : implement !
  return dateTab
end

local function datestd_encode( dateTab ) --> dateStr

  local dateTab, e = validate_date( dateTab )
  if not dateTab then
    return nil, e
  end

  local dateStr = ''
  if dateTab.year then
    dateStr = dateStr .. string.format("%04d-%02d-%02d", dateTab.year, dateTab.month, dateTab.day)
  end
  if dateTab.hour then
    if dateTab.year then
      dateStr = dateStr .. ' '
    end
    dateStr = dateStr .. string.format("%02d:%02d:%.3f", dateTab.hour, dateTab.min, dateTab.sec)
  end
  if dateTab.zone then
    local zonestr = ''
    if dateTab.zone == 0 then
      zonestr = 'Z'
    end
    if dateTab.zone > 0 then
      zonestr = '+' .. string.format("%02d:00", dateTab.zone)
    end
    if dateTab.zone < 0 then
      zonestr = '-' .. string.format("%02d:00", -dateTab.zone)
    end
    dateStr = dateStr .. zonestr
  end
  return dateStr
end

local function datestd_decode( dateStr ) --> dateTab
  local dateTab = {}

  local cursor = 1

  local function check_pattern( pat )
    return dateStr:sub(cursor):match( '^'..pat )
  end

  local function match_pattern( pat )

    local result = pack(check_pattern( pat .. '()' ))
    if not result[1] then return nil end

    local n = result[#result]
    result[#result] = nil
    result.n = result.n - 1

    cursor = cursor + n - 1
    return unpack(result)
  end

  local function match_date()
    return match_pattern('(%d%d%d%d)%-([0-1][0-9])%-([0-3][0-9])')
  end
  
  local function match_separator()
    return match_pattern('([T ])')
  end

  local function match_time()
    return match_pattern('([0-2][0-9])%:([0-6][0-9])%:(%d+%.?%d*)')
  end

  local function match_utc_zone()
    return match_pattern('(Z)')
  end

  local function match_zone()
    return match_pattern('([%+%-])([0-9][0-9])%:([0-9][0-9])')
  end

	local function parse_date()
    local year, month, day = match_date()
    if not year then return nil, "Invalid date" end

    local hour, minute, second = '', '', '', ''

    local date_time_separator = false
    if match_separator() then
      date_time_separator = true
    end

    if date_time_separator then
      hour, minute, second, n = match_time()
      if not hour then return nil, "Invalid date" end
    end

    local zone
    if match_utc_zone() then
      zone = 0
    else
      local eastwest, offset = match_zone()
      if eastwest then
        zone = tonumber(eastwest..offset)
      end
    end

    local value = {
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = tonumber(hour),
      min = tonumber(minute),
      sec = tonumber(second),
      zone = zone,
    }

    local e
    value, e = validate_date(value)
    if not value then return nil, e end

    return value
  end

	local function parse_time()
		hour, minute, second, n = match_time()
		if not hour then return nil, "Invalid date" end

		local value = {
			hour = tonumber(hour),
			min = tonumber(minute),
			sec = tonumber(second),
		}

		local value, e = validate_date(value)
		if not value then return nil, e end

		return value
	end

  if check_pattern("%d%d%d") then
    return parse_date()
  elseif check_pattern("%d%d%:") then
    return parse_time()
  else
    return nil, "Invalid date formmat"
  end

  return dateTab
end

local function datestd( dateIn ) --> dateOut
  if type( dateIn ) == 'string' then
    return datestd_decode( dateIn )
  elseif type( dateIn ) == 'table' then
    return datestd_encode( dateIn )
  else
    return nil, "Argument #1 must be a string o ar table."
  end
end

return datestd
