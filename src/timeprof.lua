--[===[DOC

= timeprof

[source,lua]
----
function timeprof( argTyp [, optTyp] ) --> timerObj
function timerObj.start( self ) -> nil
function timerObj.stop( self ) -> nil
function timerObj.reset( self ) -> nil
function timerObj.summary( self ) -> fulltimeNum, meantimeNum, errortimeNum
----

`timeprof` return an `timeObj` object that can be used to measure code execution time.If no argument is passed, a new timer is returned. Otherwise, on multiple invocation, same timers are returned when same arguments are passed.

The `timerObj` interface contains four function that must be called with the lua object-method syntax:

- `timerObj:start()` will start to measure the elapsed time
- `timerObj:stop()` will stop to measure the elapsed time
- `timerObj:reset()` will reset all the collected time measurements
- `timerObj:summary()` will return the time statistics

The returned statistic are the following three number:

- `fulltimeNum` is the sum of all the elapsed time between all the `start` and the consecutive `stop`
- `meantimeNum` is the mean of all the measurements
- `errortimeNum` is the statistical error of the mean

]===]

local clock, sqrt = os.clock, math.sqrt

local checkpoint = setmetatable({}, {mode="kv"})

local function timeprof_start(self)
  self.time_last = clock()
end

local function timeprof_stop(self)
  if self.time_last > 0 then
    local time_delta = clock() - self.time_last
    self.time_last = -1
    self.time_step = self.time_step + 1
    self.time_sum = self.time_sum + time_delta
    self.time_square_sum = self.time_square_sum + (time_delta * time_delta)
  end
end

local function timeprof_summary(self)
  local ts = self.time_sum
  local n = self.time_step
  if self.time_step < 2 then return ts, ts, 0 end
  return ts, ts/n, sqrt((self.time_square_sum - ts*ts/n)/(n-1))
end

local function timeprof_reset(self)
  self.time_sum = 0
  self.time_square_sum = 0
  self.time_step = 0
end

local function timeprof( checkpointVal ) --> resTyp
  local resTyp
  if checkpointVal then resTyp = checkpoint[ checkpointVal ] end
  if not checkpointVal or not resTyp then
    resTyp = {
      start = timeprof_start,
      stop = timeprof_stop,
      reset = timeprof_reset,
      summary = timeprof_summary,
    }
    resTyp:reset()
    if checkpointVal then
      checkpoint[ checkpointVal ] = resTyp
    else
      checkpoint[ resTyp ] = resTyp
    end
  end
  return resTyp
end

return timeprof
