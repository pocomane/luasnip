--[===[DOC

= lzw

[source,lua]
----
function lzw( optionTab ) --> encoderFunc, decoderFunc
----

Compression/decompression with a "Byte-based" variant of the Lempel–Ziv–Welch
algorithm (LZW). "Byte-bases" here means that it starts with single byte key
and every time the size must be increased, it will do by exactly one byte.

The `lzw` function return two functions, the first will encode data while the
second will decode it. The `optionTab` table can specify some option for the
alogrithm:

- optionTab.dict_size - When the internal dict reaches the specified number of
keys, it is reset. The rest of the stream is encoded as a new compressed block,
starting with an empty dictionary. By default, the dictionary is never reset:
depending on the input data, this can lead to poor compression rate. A decoder
and an encoder with different values of this property are incompatible.

- optionTab.max_size - This will instruct the encoder to stop processing the
data when the output overflows the specified size. This property does not
change the behaviour of the decoder in any way. It is usefull when dealing with
big in-memory strings. When the output reaches a certain threshold (e.g. the
size of the input data), you do not generally want to continue to spend time
encoding the rest of the string. Instead you can try another compression
algorithm or handle the data without compression.

[source,lua]
----
function encoderFunc( dataStr ) --> encodedStr
----

This function will encode the `dataStr` using LZW. Every time it is called with
a new string, it will process it as a new chunk of the same input data (i.e.
the status of the encoder is stored between calls). At end of the stream it
should be called without arguments to get the last pieces of encoded data.
After that the function can be called again: it will continue to encode the
rest of the stream as if it was never called without parameters.

[source,lua]
----
function decoderFunc( dataStr ) --> decodedStr
----

This will decode the dataStr. The state is kept between calls so you can split
the input in any place and pass one piece after onother to the `decoderFunc`.
At each call it will return the decoded chunk. All the returned chunk from
multiple calls are intended to be concatenate together to form the whole
decoded stream.

== Example

[source,lua,example]
----
local lzw = require "lzw"

local enc = lzw()

local a = enc"xxx"
local b = a .. enc()

local _, dec = lzw()
assert( "xxx" == dec(b) )

local b = a
b = b .. enc"yyy"
b = b .. enc()

local _, dec = lzw()
assert( "xxxyyy" == dec(b) )

local _, dec = lzw()
assert( "xxxyyy" == dec(b:sub(1,3)) .. dec(b:sub(4)) )

----

]===]

local char = string.char
local merge = table.concat

local function clean_pad(str)
  str = str:gsub('\00*$','')
  if str == '' then str = '\00' end
  return str
end

local function re_pad(str, siz)
  str = clean_pad(str)
  str = str..(('\00'):rep(siz-#str))
  return str
end

local last_base_index = 255
local last_base_key = char(255)
local function new_dict()
  local dict = {}
  -- for single byte key, return the key itself. Any en/de-coder dict is
  -- assumed to contain the identity for the single byte keys.
  for k = 0, last_base_index do
    local b = char(k)
    dict[b] = b
  end
  return dict
end

-- Generate next coded sequence
local function next_index_string(prev)

  local key = {}

  local carry = 1
  for k = 1, #prev do
    if carry == 0 then
      key[k] = prev:sub(k,k)
    end
    local nc = prev:sub(k,k):byte() + carry
    if nc < 256 then
      key[k] = char(nc)
      carry = 0
    else
      key[k] = "\x00"
      if k == #prev then
        key[k+1] = "\x01"
      end
    end
  end

  return merge(key), #key
end

local function first_index_string()
  return next_index_string(last_base_key)
end

local function lzw(def)

  -- Option parse
  local dict_size = def and def.dict_size
  local enc_size = def and def.max_size

  -- ENCODER
  local lzw_encoder
  do
    -- initialization
    local dict = new_dict()
    local len = #last_base_key
    local encoded = first_index_string()
    local resultlen = 0
    local carry = ''
    local sequence = ''
    local dictcount = 0

    function lzw_encoder(input)

      if enc_size and enc_size < resultlen then
        return ''
      end

      -- calculate the tail (needed only if this is the last chunk)
      if input == nil then
        local write = dict[carry]
        return re_pad(write, len)
      end

      local result = {}

      -- process next part of input
      for i = 1, #input do

        -- read new chars and search for the shortest sequence non already in the dict ...
        local c = input:sub(i, i)
        sequence = carry..c
        if dict[sequence] then
            carry = sequence
        else
          -- ... found!

          -- get the coded sequence matching the read one
          local write = dict[carry]
          if not write then error('this should never happend') end
          write = re_pad(write, len)

          -- stop if the "Compressed string" is longer than the size guard
          resultlen = resultlen + #write
          if enc_size and enc_size < resultlen then
            break
          end

          -- emit the sequence
          result[#result+1] = write

          -- start a new compression block if the dict threshold was reached
          if dict_size then
            if dictcount >= dict_size then
              dictcount = 0
              dict = new_dict()
            end
            dictcount = dictcount + 1
          end

          -- generate a new dict entry with the new sequence, i.e. the shortest not already in the dict
          dict[sequence] = encoded
          len = #encoded
          encoded = next_index_string(encoded)

          -- the new char is the begin of the next sequence
          carry = c
        end
      end

      -- end
      return merge(result)
    end
  end

  -- DECODER
  local lzw_decoder
  do
    -- initialization
    local prev = ''
    local dict = new_dict()
    local len = #last_base_key
    local encoded = first_index_string()
    local carry = ''
    local dictcount = 0

    function lzw_decoder(input)
      local result = {}

      input = carry .. input -- TODO : avoid this ?

      local i = 1
      while i <= #input do

        -- read a number the byte indicated by the dict handler i.e. the dimension of the last created key
        local code = input:sub(i, i+len-1)
        i = i + len

        -- store partial key for the next input step
        carry = ''
        if #code < len then
          carry = code
          break
        end

        -- decode the read sequence
        code = clean_pad(code)
        local decoded = dict[code]
        local add_to_dict
        if decoded then
          add_to_dict = prev..decoded:sub(1, 1)
        else

          -- special case: this can happen only for encoded "ababa" sequencies
          -- a = single char, b = string, ab = alredy in dictionary, aba = not in dict
          add_to_dict = prev..prev:sub(1, 1)
          decoded = add_to_dict
        end
        result[#result+1] = decoded

        -- start a new decompression block if the dict threshold was reached
        if dict_size then
          if dictcount >= dict_size then
            dictcount = 0
            dict = new_dict()
          end
          dictcount = dictcount + 1
        end

        -- generate a new dict entry; skip the first time since the string is already in the base dict
        if prev ~= '' then
          dict[clean_pad(encoded)] = add_to_dict
          encoded = next_index_string(encoded)
        end
        len = #encoded

        prev = decoded or dict[code]
        if not prev then
          return nil, "invalid compressed data"
        end
      end
      return merge(result)
    end
  end

  return lzw_encoder, lzw_decoder
end

return lzw
