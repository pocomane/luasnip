--[===[DOC

= logline

[source,lua]
----
function logline( level [, ...] ) --> line, err
----

This function adds common useful information to the data that you want to
output.

When called with the single 'level' argument, it will set the global verbosity
level.  When called with additional arguments it will generate the log string
`line`.  However the string will be generated only if the first argument, the
line log level, is smaller than the global verbosity level.  In this way you
can dinamically enable or disable log messages in critical part of the code.

The verbosity level can be given in two way: as an integer or as a string
representing the verbosity class.

The allowed verbosity classes are:

- *ERROR* <==> 25
- *DEBUG* <==> 50
- *INFO* <==> 75
- *VERBOSE* <==> 99

Each class will be considered to cantain any integer level just below it, e.g.
26, 30 and 50 all belongs to the *DEBUG* class.
When specifying the verbosity level as a class name, the higher belonging
integer will be used.

All the other vararg are appended to the generated log line.

The data included in the log are:

- Date/time in a format such as the string order is the same of time order
- _os.clock()_ result
- Verbosity level of the log line (both number and class name)
- Source position of function call
- Additional info in the arguments

Note 1: if the caller is a tail call or a function with a name that starts or
ends with _log_, the position used will be the one of the caller of the caller
(and so on).

Note 2: in case of error `nil` will be returned, plus the `err` error string

== Example

[source,lua,example]
----
local logline = require "logline"

logline( 30 )
assert( logline( 29, "test" ) ~= nil)
assert( logline( 30, "test" ) ~= nil)
assert( logline( 31, "test" ) == nil)
assert( logline( "error", "test" ) ~= nil)
assert( logline( "debug", "test" ) == nil)
assert( logline( "info", "test" ) == nil)
assert( logline( "verbose", "test" ) == nil)

logline( 50 )
assert( logline( 26, "test" ) ~= nil)
assert( logline( 50, "test" ) ~= nil)
assert( logline( 51, "test" ) == nil)
assert( logline( "error", "test" ) ~= nil)
assert( logline( "debug", "test" ) ~= nil)
assert( logline( "info", "test" ) == nil)
assert( logline( "verbose", "test" ) == nil)
----

]===]

local skip_lower_level = 25

local level_list =  {
   { 25, "ERROR" },
   { 50, "DEBUG" },
   { 75, "INFO"} ,
   { 99, "VERBOSE" }
}

local level_map
local function update_level_map()
   level_map = {}
   for k,v in ipairs( level_list ) do
      level_map[ v[ 2 ] ] = v
   end
end

update_level_map()

local function logline( level, ... ) --> line
   -- Classify log level
   local level_class
   if "string" == type( level ) then
      level_class = level_map[ level:upper() ]
      if level_class then level = level_class[ 1 ] end
   elseif "number" == type( level ) then
      local level_num = #level_list
      for k = 1, level_num do
         if k == level_num or level <= level_list[k][1] then
            level_class = level_list[k] 
            break
         end
      end
   else
      return nil, "Invalid type for argument #1"
   end
   
   if not level_class then
      return nil, "Invalid symbolic log level"
   end

   local n = select( "#", ... )
   --  Single argument mode: set log level
   if n == 0 then
      skip_lower_level = level
      return
   end

   -- Multiple argument mode: generate log line

   -- Skip if the current log level is too small
   if skip_lower_level < level then
      return
   end

   -- Get info about the function in the correct stack position
   local d = debug.getinfo( 2 )
   local td = d
   local stackup = 2
   while true do
      local n = td.name
      if not n then break end
      n = n:lower()
      if  not n:match( "log$" )
      and not n:match( "^log" )
      and n ~= "" then
         break
      end
      stackup = stackup + 1
      td = debug.getinfo(stackup)
   end
   if td then d = td end

   -- Log line common part
   local line = os.date( "%Y/%m/%d %H:%M:%S" ).." "..os.clock().." "
                ..level_class[ 1 ].."."..level_class[ 2 ].." "
                ..d.short_src:match( "([^/\\]*)$" )..":"..d.currentline.." | "

   -- Append additional log info from arguments
   for m = 1,n do
      line = line..tostring( select( m, ... ) ).." | "
   end

   return line
end

return logline
