local lzw = require "lzw"
local t = require "testhelper"

local function e(str, def)
  local e = lzw(def)
  return e(str)..e()
end

local function d(str, def)
  local _, d = lzw(def)
  return d(str)
end

local a, x

t( "a", e"a" )
t( "aa\x00", e"aa" )
t( "aa\x00b\x00\x00\x01c\x00", e"aabaac" )
t( "aa\x00b\x00\x00\x01", e"aabaa" )

t( "a", d"a" )
t( "aa", d"aa\x00" )
t( "aabaac", d"aa\x00b\x00\x00\x01c\x00" )
t( "aabaa", d"aa\x00b\x00\x00\x01" )

t( "aa\x00b\x00c\x00\x00\x01\x01\x01\x02\x01\x03\x01", e"aabcaaabbcca" )
t( "aabcaaabbcca", d"aa\x00b\x00c\x00\x00\x01\x01\x01\x02\x01\x03\x01" )

-- nothing strange for compression
t( "ab\x00\x00\x01\x02\x01", e"abababa" )

-- special decompression case: "ababa" sequencies
-- a = single char, b = string, ab = alredy in dictionary, aba = not in dict
t( "abababa", d"ab\x00\x00\x01\x02\x01" )

t( "aa\x00b\x00c\x00\x00\x01\x01\x01\x02\x01\x63\x00\x61\x00\x78\x00", e("aabcaaabbccax", {dict_size=6}) )
t( "aabcaaabbccax", d("aa\x00b\x00c\x00\x00\x01\x01\x01\x02\x01\x63\x00\x61\x00\x78\x00", {dict_size=6}) )

t( "aa\x00b\x00", e("aabaac",{max_size=5}) )
t( "aa\x00", e("aabaac",{max_size=4}) )
t( "aa\x00b\x00", e("aabaacxxx",{max_size=5}) )
t( "aa\x00", e("aabaacxxx",{max_size=4}) )

-- reasonable compression factor WITHOUT ababa sequencies
local compressable = ""
for _, k in pairs{"A","B","A","C","A","D","A","E","A","F","A","G"} do
  compressable = compressable .. "-0-1-2-3-4-5-6-7-8-9-" .. k
end

x = e(compressable)
t(true, #compressable > #x+10)

-- random split in 2 pieces (with ababa sequences)
math.randomseed(os.time())
local ababa = "yaabcaaabbcca" .. ("x"):rep(40) -- the suffix is needed to bypass any possible low-compression rate protection
for i=1,10 do
  local str = ababa
  local e, d = lzw()

  local s = math.random(1,#str)
  str = e(str:sub(1,s))..e(str:sub(s+1))..e()

  s = math.random(1,#str-1)
  local b = d(str:sub(1,s))..d(str:sub(s+1))

  t( ababa, b )
end

t.test_embedded_example()

t()

