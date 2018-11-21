--[===[DOC

= subbytebase

[source,lua]
----
function subbytebase( bitInt , inStr [, mapTab] ) --> outStr
----

Convert the raw data in the `inStr` string to/from base-2-4-8-16-32-64-128
representation. 

`bitInt` is the number of bit of the representation. So you should use `Y` to
request `baseX` where `X=2^Y`, e.g. `1` means base2, `6` means base64, and so
on.  Positive value means conver to the representation (i.e. output will be
longer than the input), qhile negative value means convert from the
representation (i.e. output will be shorter than the input).

A custom alphabet can be bassed in the `mapTab` table; it must be a table
containing the alphabet to use into the first integer keys. For example, the
`{'O','I'}` in a base2 conversion will use 'O' instead of '0' and 'I' instead
of '1'.

If no alphabet is passed, the following defaults will be used:

- For base2, the two digit `0` and `1` will be use
- For base4, the degit between `0` and `3`  will be used
- For base8 (i.e. ocatal) the degit between `0` and `7`  will be used
- For base16 (i.e. hex) the standard, hex chars will be used, i.e.  degit
between `0` and `9` and letters between 'A' and 'F' will be used
- For base32, the Crockford alphabet will be used; it is an extension of the
base16 one, with the addition of only letters
- For base64, the standard alphabet will be used
- For base128, the ASCII subset will be used (higher bit always zero)

In base16 and base32 the letters are always uppercase.

== Example

[source,lua,example]
----
local subbytebase = require 'subbytebase'

assert( subbytebase(6,'aaaaaa' ) == 'YWFhYWFh' )
assert( subbytebase(-6, 'YWFhYWFh') == 'aaaaaa' )

assert( subbytebase(1, ' ') == '00100000' )
assert( subbytebase(1, ' ', {'x','Y'}) == 'xxYxxxxx' )
----

]===]

local bitpad = (function()
-- [SNIP:bitpad.lua[
local function bitpad( pad, bit, str, map, imap, off )
  if not bit then bit = 1 end
  if not pad then pad = 8 - (bit % 8) end
  local result = ''

  local removing = false
  if pad < 0 then
    pad = - pad
    removing = true
  end

  local out_count = 0
  local appending = false
  local procbit = pad
  if off then
    appending = true
    procbit = off
  end
  local store = 0
  local i = 0
  local inlast = 0
  local inbit = 0

  -- Bitloop
  while true do

    -- Get new input byte as needed
    if inbit <= 0 then
      i = i + 1
      inlast = str:byte(i)
      if not inlast then break end
      if imap then
        local x = imap[inlast+1]
        inlast = (x and x:byte()) or inlast
      end
      inbit = 8
    end

    -- Calculate number of appendable bits
    local appbit = procbit
    if appbit > inbit then appbit = inbit end
    if appbit + out_count > 8 then appbit = 8 - out_count end

    -- Make space into the output for the next bits
    if not removing or appending then
      store = (store << appbit) & 0xFF
      out_count = out_count + appbit
    end

    -- Copy the next bits from the input
    if appending then
      local mask = ((~0) << (8-appbit)) & 0xFF
      store = store | ((mask & inlast ) >> (8- appbit))
    end

    -- Discard from the input the bits that were already processed
    if removing or appending then
      inbit = inbit - appbit
      inlast = (inlast << appbit) & 0xFF
    end

    -- Select bit handle mode for the next iteration
    procbit = procbit - appbit
    if procbit <= 0 then
      if appending then
        appending = false
        procbit = pad
      else
        appending = true
        procbit = bit
      end
    end

    -- Generate output byte
    if out_count >= 8 then
        result = result .. (map and map[store+1] or string.char(store))
      store = 0
      out_count = 0
    end
  end

  -- Generate odd-bit byte
  local bitadd = 0
  if out_count > 0 then
    bitadd = 8 - out_count
    store = (store << bitadd) & 0xFF
    result = result .. (map and map[store+1] or string.char(store))
  end

  return result, bitadd
end

return bitpad
-- ]SNIP:bitpad.lua]
end)()

-- This can be used for base2-4-8-16 and crockford base32
local subbyte_multipurpose_alphabet = {
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
}

-- This can be used for standard base64
local subbyte_base64_alphabet = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
  'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
  'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
}

local subbyte_inverse_cache = {}

local function subbyte_alphabet_invert( map )
  if not map then return nil end
  local imap = {}

  -- cache standard inverse alphabets
  if map == subbyte_multipurpose_alphabet or map == subbyte_base64_alphabe then
    local s = subbyte_inverse_cache[map]
    if s then return s end
    subbyte_inverse_cache[map] = s
  end

  -- invert the alphabet
  for i=1,256 do for j=1,256 do
    if map[j]==string.char(i-1) then imap[i] = string.char(j-1) end
  end end
  return imap
end

local function subbytebase(bit, str, map)
  if bit == 8 then return str end
  if str == '' then return str end
  if bit == 0 then error() end
  local result = str

  local mode = 'encode'
  if bit < 0 then
    mode = 'decode'
    bit = - bit
  end

  if not map then
    if bit >= 1 and bit <= 5 then
      map = subbyte_multipurpose_alphabet
    elseif bit == 6 then
      map = subbyte_base64_alphabet
    end
  end

  local pad
  if mode == 'decode' then 

    -- handle '=' tail
    local hastail = ('=' == result:sub(-1,-1))
    result = result:gsub('%=*$', '')

    local imap = subbyte_alphabet_invert( map )
    result, pad = bitpad(bit-8,bit,result,nil,imap)

    -- handle '=' tail
    if hastail then result = result:sub(1, -2) end

  else -- mode == 'decode'

    result, pad = bitpad(8-bit,bit,result,map)

    -- handle '=' tail
    if pad ~= 0 then
      for p = 1, 8 do if (bit - pad + 8 * p) % bit == 0 then
        result = result .. (('='):rep(p))
        break
      end end
    end

  end

  return result
end

return subbytebase
