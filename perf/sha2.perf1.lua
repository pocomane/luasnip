local sha2 = require 'sha2'

local data = ('x'):rep(1024)

return function()
  return sha2( data )
end
