--[===[DOC

= copyfile

[source,lua]
----
function copyfile( src, dst ) --> res, err
----

This function copy the file at the path specified by the `src` string to to the
file at the
path specified by the `dst` string.

It will return `true` if the copy successes, otherwise `nil` plus an error string.

== Example

[source,lua,example]
----
local copyfile = require "copyfile"

local data = tostring(math.random()*os.time())

os.remove('s.txt')
local s = io.open('s.txt','w')
s:write(data)
s:close()

os.remove('d.txt')
copyfile( 's.txt', 'd.txt')

local d = io.open('d.txt','r')
local copied = d:read('a')
d:close()

assert( data == copied )

----

]===]

local function copyfile( src, dst ) --> ok, err

   local function checkerror( ... )
      local msg = ""
      for m = 1, select( "#", ... ) do
         local p = select( m, ... )
         if p ~= nil then
         msg = msg..p..". "
         end
      end
      if msg == "" then return true end
      return nil, msg
   end

   local s, serr = io.open( src, "rb" )
   if serr then
      return checkerror( "Can not open source file", serr )
   end
 
   local d, derr = io.open( dst, "wb" )
   if not d then
      s, serr = s:close()
      return checkerror( "Can not create destination file" , derr, serr )
   end

   -- Copy loop
   while true do
      buf, serr = s:read( 1024 )
      if serr or not buf then break end
      ok, derr = d:write( buf )
      if derr then break end
   end
   if serr or derr then
      return checkerror( "Error while copying", serr, derr )
   end

   s, serr = s:close()
   d, derr = d:close()
   return checkerror( serr, derr )
end

return copyfile
