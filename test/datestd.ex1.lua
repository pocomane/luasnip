
local datestd = require 'datestd'
local t = require 'testhelper'

t( datestd{}, '' )
t( datestd{ year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=0}, '2018-01-21 14:32:10.100Z' )

t( datestd{ year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=1}, '2018-01-21 14:32:10.100+01:00' )
t( datestd{ year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=-1}, '2018-01-21 14:32:10.100-01:00' )

t( datestd{ year=2018, month=1, day=21, hour=14, min=32, sec=10.1}, '2018-01-21 14:32:10.100' )
t( datestd{ year=2018, month=1, day=21}, '2018-01-21' )
t( datestd{ hour=14, min=32, sec=10.1}, '14:32:10.100' )

-- t( datestd'', {}, t.deepsame )
t( datestd'2018-01-21 14:32:10.100Z', { year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=0}, t.deepsame )

t( datestd'2018-01-21 14:32:10.100+01:00', { year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=1}, t.deepsame )
t( datestd'2018-01-21 14:32:10.100-01:00', { year=2018, month=1, day=21, hour=14, min=32, sec=10.1, zone=-1}, t.deepsame )

t( datestd'2018-01-21 14:32:10.100', { year=2018, month=1, day=21, hour=14, min=32, sec=10.1}, t.deepsame )
t( datestd'14:32:10.100', { hour=14, min=32, sec=10.1}, t.deepsame )
t( datestd'2018-01-21', { year=2018, month=1, day=21}, t.deepsame )

-- TODO : test errors !

t.test_embedded_example()

t()

