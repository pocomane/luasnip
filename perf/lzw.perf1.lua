local lzw = require 'lzw'

local s = {}
for k = 1, 20000 do
  s[1+#s] = string.char(math.random(0, 255))
end
for k = 1, 100000-#s do
  s[1+#s] = string.char(k%256)
end
s = table.concat(s)

return function()
  local enc, dec = lzw()
  local x = enc(s)..enc()
end
