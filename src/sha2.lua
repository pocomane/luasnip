--[===[DOC

= sha2

[source,lua]
----
function sha2( dataStr[, bitsizeInt[, specTab ]] ) --> rawhashStr
----

Calculate a SHA-2 cryptographic hash of the `dataStr` string. The result
`rawhashStr`  string contains the binary hash.

By default the SHA-256 is used, so the hash is an array of 8 integers. The
integers are stored as 32-bit big endian values. So the hash has a fixed length
of 32 bytes.

Message with incomplete byte can be processed passing the `bitsizeInt` bit
count as the second argument. The default is 8 times the `dataStr` string
length.

The optional `specTab` argument is used to specify any SHA-2 algorythm. It can
be one of the following integer that specify a standard SHA-2 hash algorythm:
256, 224, 512 or 384.

`specTab` can also be the an explicit table containing an array of integer. In
this way also non-standard SHA-2 hash can be generated. The integers have the
following meaning, in order:

- 12 Rotation constants: at each encription round the SHA-2 will rotate the
  previous value of a certain number of bits (e.g. for SHA-256: 7, 18, 17, 19, 3,
  10, 6, 11, 25, 2, 13, 22)
- Integer bit size. All the other variables will be 32 or 64 bit unsigned integers,
  based on the value of this variable
- Hash size (max 8) in integer size unit
- Chunk size in byte
- The 8 initial values for the hash
- Any number of round constants: for each of them a encryption round is generated

== Inspired by

This code is adapted from the pseudocode in the SHA-2 Wikipedia article:

* https://en.wikipedia.org/wiki/SHA-2

]===]

-- Note: Big-endian convention is used when parsing message block data from
-- bytes to words, for example, the first word of the input message "abc" after
-- padding is 0x61626380

-- For non-8-bit-multiple message:
-- It returns the pad description and the zero-padded odd bits
local function sub_byte_suffix(message, L)
  local fb = L % 8
  if fb == 0 then return 0x80 end

  fb = 7 - fb
  local val = message:byte(-1,-1)
  val = val >> fb
  val = val | 1
  val = val << fb
  return val
end

-- calc the hash of a L-bits message
local function sha2core(message, L, algospec)

  -- Cache some values for speed
  local o = 23
  local r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12,
    intsiz, hashtrunc, chunksize,
    h0, h1, h2, h3, h4, h5, h6, h7,
    k =
      table.unpack(algospec)
  local roundnum = #algospec - o
  local sb = {}
  for i = 1, 12 do sb[i] = 8 * intsiz - algospec[i] end
  local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12 = table.unpack(sb)
  local summask = (( ~0 ) << ( 8 * intsiz )) ~ ( ~0 ) -- intsiz=4 -> summask=0xffffffff
  local packspec = ">" .. ( 'I' .. intsiz ):rep( 16 ) -- intsiz=4 -> packspec=>I4I4... 16 times

  -- Pre-processing: make the length a multiple of the chunk size; the original
  -- lenght will be written in the last bytes
  local addchar = sub_byte_suffix(message, L)
  if 0x80 ~= addchar then message = message:sub(1,-2) end
  message = message 
    .. string.char(addchar)
    .. ('\0'):rep(chunksize - ((#message + 1 + 2*intsiz) % chunksize))
    .. string.pack('>I'..(2*intsiz), L)

  -- Process the message in successive fixed-lenght chunks:
  for pos = 1, #message, chunksize do
      local w = {string.unpack(packspec, message, pos)}

      -- Extend the first 16 words into the remaining words, one for each round
      for i = 17, roundnum do

          local a = w[i-15]
          local aR7  = (a >> r1) | (a << l1) -- Right-Rotate a >> r1
          local aR18 = (a >> r2) | (a << l2) -- Right-Rotate a >> r2
          local b = w[i-2]
          local bR17 = (b >> r3) | (b << l3) -- Right-Rotate b >> r3
          local bR19 = (b >> r4) | (b << l4) -- Right-Rotate b >> r4

          local s0 = aR7 ~ aR18 ~ (a >> r5)
          local s1 = bR17 ~ bR19 ~ (b >> r6)
          w[i] = (w[i-16] + s0 + w[i-7] + s1 ) & summask
      end

      -- Initialize working variables to current hash value:
      local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7

      -- Compression function main loop:
      for i = 1, roundnum do
          local eR6  = (e >> r7)  | (e << l7) -- Right-Rotate e >> r7
          local eR11 = (e >> r8)  | (e << l8) -- Right-Rotate e >> r8
          local eR25 = (e >> r9)  | (e << l9) -- Right-Rotate e >> r9
          local aR2  = (a >> r10) | (a << l10) -- Right-Rotate a >> r10
          local aR13 = (a >> r11) | (a << l11) -- Right-Rotate a >> r11
          local aR22 = (a >> r12) | (a << l12) -- Right-Rotate a >> r12

          local S1 = eR6 ~ eR11 ~ eR25
          local ch = (e & f) ~ ((~ e) & g)
          local temp1 = h + S1 + ch + algospec[o+i] + w[i]
          local S0 = aR2 ~ aR13 ~ aR22 
          local maj = (a & b) ~ (a & c) ~ (b & c)
          local temp2 = S0 + maj
   
          h = g
          g = f
          f = e
          e = (d + temp1) & summask
          d = c
          c = b
          b = a
          a = (temp1 + temp2) & summask
      end

      -- Add the compressed chunk to the current hash value:
      h0 = (h0 + a) & summask
      h1 = (h1 + b) & summask
      h2 = (h2 + c) & summask
      h3 = (h3 + d) & summask
      h4 = (h4 + e) & summask
      h5 = (h5 + f) & summask
      h6 = (h6 + g) & summask
      h7 = (h7 + h) & summask
  end

  return string.pack( ">" .. ( 'I' .. intsiz ):rep( hashtrunc ),
    h0, h1, h2, h3, h4, h5, h6, h7 )
end

local sha256_spec = {

  -- Rotation constants
  7, 18, 17, 19,
  3, 10,
  6, 11, 25,
  2, 13, 22,

  -- Integer bit size. All variables are 32 bit unsigned integers. The appended
  -- message lengt is 32 bit. The additions are calculated modulo 2^32.
  4,

  -- Hash size (max 8) -- Integer size unit
  8,

  -- Chunk size -- byte
  64,

  -- Initial hash values:
  -- (first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
  0x6a09e667,
  0xbb67ae85,
  0x3c6ef372,
  0xa54ff53a,
  0x510e527f,
  0x9b05688c,
  0x1f83d9ab,
  0x5be0cd19,

  -- Round constants:
  -- (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local sha224_spec = {

  -- Rotation constants
  7, 18, 17, 19,
  3, 10,
  6, 11, 25,
  2, 13, 22,

  -- Integer bit size. All variables are 32 bit unsigned integers. The appended
  -- message lengt is 32 bit. The additions are calculated modulo 2^32.
  4,

  -- Hash size (max 8) -- Integer size unit
  7,

  -- Chunk size -- byte
  64,

  -- Initial hash values:
  -- (The second 32 bits of the fractional parts of the square roots of the 9th through 16th primes 23..53)
  0xc1059ed8,
  0x367cd507,
  0x3070dd17,
  0xf70e5939,
  0xffc00b31,
  0x68581511,
  0x64f98fa7,
  0xbefa4fa4,

  -- Round constants:
  -- (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local sha512_spec = {

  -- Rotation constants
  1, 8, 19, 61,
  7, 6,
  14, 18, 41,
  28, 34, 39,

  -- Integer bit size. All variables are 64 bit unsigned integers. The appended
  -- message lengt is 64 bit. The additions are calculated modulo 2^64.
  8,

  -- Hash size (max 8) -- Integer size unit
  8,

  -- Chunk size -- byte
  128,
  
  -- Initial hash values:
  -- (first 64 bits of the fractional parts of the square roots of the 9th-16th primes):
  0x6a09e667f3bcc908,
  0xbb67ae8584caa73b,
  0x3c6ef372fe94f82b,
  0xa54ff53a5f1d36f1,
  0x510e527fade682d1,
  0x9b05688c2b3e6c1f,
  0x1f83d9abfb41bd6b,
  0x5be0cd19137e2179,

  -- Round constants:
  -- (first 64 bits of the fractional parts of the cube roots of the first 80 primes 2..409):
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 
    0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe, 
    0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab, 
    0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 
    0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b, 
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 
    0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 
    0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c, 
    0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 
    0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
}

local sha384_spec = {

  -- Rotation constants
  1, 8, 19, 61,
  7, 6,
  14, 18, 41,
  28, 34, 39,

  -- Integer bit size. All variables are 64 bit unsigned integers. The appended
  -- message lengt is 64 bit. The additions are calculated modulo 2^64.
  8,

  -- Hash size (max 8) -- Integer size unit
  6,

  -- Chunk size -- byte
  128,
  
  -- Initial hash values:
  -- (first 64 bits of the fractional parts of the square roots of the 9th-16th primes):
  0xcbbb9d5dc1059ed8,
  0x629a292a367cd507,
  0x9159015a3070dd17,
  0x152fecd8f70e5939,
  0x67332667ffc00b31,
  0x8eb44a8768581511,
  0xdb0c2e0d64f98fa7,
  0x47b5481dbefa4fa4,

  -- Round constants:
  -- (first 64 bits of the fractional parts of the cube roots of the first 80 primes 2..409):
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 
    0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe, 
    0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab, 
    0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 
    0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b, 
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 
    0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 
    0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c, 
    0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 
    0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
}

local function sha2( message, L, algo )
  if not L then L = 8 * #message end
  local algospec = sha256_spec
  if 'table' ~= type(algo) then
    if algo == 256 then algospec = sha256_spec end
    if algo == 224 then algospec = sha224_spec end
    if algo == 512 then algospec = sha512_spec end
    if algo == 384 then algospec = sha384_spec end
  end
  return sha2core(message, L, algospec)
end

return sha2