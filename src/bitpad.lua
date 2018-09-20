--[===[DOC

= bitpad

[source,lua]
----
function bitpad( padInt, bitInt, inStr [, outmapSeq] [, inmapSeq] [,offsetInt]) --> outStr, supbitInt
----

Add or remove padding from the byte sequence in the string `inStr`. `padInt` is the 
number of bit to add or remove, while `bitInt` it the number of bit after which
the insertion/removal is repeated. If `inStr` is positive the bits are added,
otherwise they are removed.

For example, `bitpad( 1, 2, ...` will add 1 padding bit each 2 input bit,
while `bitpad( -1, 2, ...` will remove one bit each 2 input bit.

The `offsetInt` argument specify the first bit that must be added or
removed. The very first bit is used by default.

All the added bit will be set to `0`, while bit of any value can be removed.

The tow optional parameter `outmapSeq` and `inmapSeq` are two maps that will be
applied to each byte, before any processing (`inmapSeq`) or after all the
processing (`outMapSeq`)

The ouput will be returned in the `outStr` string. If the last bit do not fill
a byte, the appropriate number of `0` will be added at end of the data. The
number of added `0` is returned as the last returned value `supbitInt`.

]===]

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
