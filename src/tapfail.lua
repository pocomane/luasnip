--[===[DOC

= tapfail

[source,lua]
----
local function tapfail( ) --> streamFunc( lineStr ) --> errorStr
----

With this function, a stream in the TAP format can be searched for errors (Test
Anything Protocol). Itself returns the `streamFunc` function that performs the
real analisys.

`streamFunc` must be called on each line of the TAP stream and it will return
`nil` if no error was found. Otherwise it will return the `errorStr` string
describint the error.

At the end of the stream, `streamFunc` should be called the last time, without
any argument, to perform the last checks (e.g. a proper summary line was
found).

When called without argument, `streamFunc` will always return the last found
error (in the current as in the previous calls).

]===]

local function ton( x )
  local _, x = pcall(function() return tonumber(x) end)
  if x < 0 then return nil end
  if x ~= math.modf(x) then return nil end
  return x
end

local function tapfail( ) --> streamFunc( lineStr ) --> errorStr
  local summary
  local summary_line
  local testcount = 0
  local l = 0

  local function check_line( line )
    if line == '' then
      return nil
    elseif line:match('^#') then
      return nil
    else

      local ok = line:match('^ok (%d*)')
      if ok then
        if summary_line and l > summary_line and summary_line ~= 1 then
          return 'line after summary'
        end
        ok = ton( ok )
        if not ok then ok = -9 end
        local deltacount = ok - testcount
        testcount = ok
        if deltacount ~= 1 then
          return 'invalid count sequence'
        end
      end

      local sum = line:match('^1%.%.(.*)')
      if sum == 'N' then
        sum = true
      elseif sum then
        sum = ton( sum )
      end
      if sum then
        summary = sum
        if not summary_line then
          summary_line = l
        else
          return 'summary already found at line '..summary_line
        end
      end

      if not ok and not diag and not summary then
        return 'no diagnostic or ok line'
      end

      if not result and summary and summary ~= true then
        if summary_line==l and l > 1 and summary ~= testcount then
          return 'invalid test count'
        elseif summary<testcount then
          return 'invalid count sequence'
        end
      end

      return nil
    end
  end
  
  local last_error

  local function tapchunk( line )
    if not line then
      if not summary then
        last_error = 'summary missing'
      elseif summary ~= true and summary > testcount then
        last_error = 'missing test'
      end
      return last_error
    end

    l = l + 1
    local result = check_line( line )

    if result then last_error = result end
    return result
  end

  return tapchunk
end

return tapfail
