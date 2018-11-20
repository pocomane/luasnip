--[===[DOC

= appendfile

[source,lua]
----
function appendfile( path, data [, prefix [, suffix]] ) --> res, err
----

This function will append the datas to a file.

The file path is specified by the `path` string, while the `data` can be passed
as a single string or an array of strings i.e. multiple chunks to be appended.

Two strings can be optionally passed: `prefix` and `suffix`. They will be
written before and after each chunk of data. 

This function will return `true` if it successed, otherwise it will return `nil`
plus an error message.

== Example

[source,lua,example]
----
local appendfile = require "appendfile"

os.remove( "appendfile.txt" )

appendfile( "appendfile.txt", "123" )
assert( "123" == io.open("appendfile.txt"):read("a") )

appendfile( "appendfile.txt", {"a","b"}, "<", ">" )
assert( "123<a><b>" == io.open("appendfile.txt"):read("a") )

----

]===]

local function appendfile( path, data, prefix, suffix ) --> res, err

   local function writeorclose( f, data )
      local res, err = f:write( data )
      if err then f:close() end
      return res, err
   end

   local d, derr = io.open( path, "a+b" )
   if derr then
      return nil, "Can not create or open destination file. "..derr
   end

   local ok, err = d:seek( "end" )
   if err then
      d:close()
      return nil, err
   end

   if "string" == type( data ) then
      data = { data }
   end

   -- Output loop
   for i = 1, #data do

      if prefix then
         ok, err = writeorclose( d, prefix )
         if err then return ok, err end
      end

      ok, err = writeorclose( d, data[ i ] )
      if err then return ok, err end

      if suffix then
         ok, err = writeorclose( d, suffix )
         if err then return ok, err end
      end
   end

   return d:close()
end

return appendfile
