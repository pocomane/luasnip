
local bitpad = require 'bitpad'
local t = require 'testhelper'

t( bitpad(0, 0, ''), '', t.bytesame )

t( bitpad(8, 8, '\x0F\x0F\x0F'), '\0\x0F\0\x0F\0\x0F', t.bytesame )

t( bitpad(7, 1, '\x0F'), '\x00\x00\x00\x00\x01\x01\x01\x01', t.bytesame )
t( bitpad(15, 1, '\x0F'), '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x01\x00\x01\x00\x01', t.bytesame )

t( bitpad(6, 2, '\x0F'), '\x00\x00\x03\x03', t.bytesame )
t( bitpad(4, 4, '\x0F'), '\x00\x0F', t.bytesame )

t( bitpad(5, 3, '\x0F'), '\x00\x03\x06', t.bytesame )
t( bitpad(5, 3, '\x0F\x0F'), '\x00\x03\x06\x00\x07\x04', t.bytesame )
t( bitpad(5, 3, '\x0F\x81'), '\x00\x03\x07\x00\x00\x04', t.bytesame )

t( bitpad(12, 4, '\xFF'), '\x00\x0F\x00\x0F', t.bytesame )

t( bitpad(2, 2, '\xFF'), '\x33\x33', t.bytesame )

t( bitpad(3, 3, '\xFF'), '\x1C\x71\x80', t.bytesame )
t( bitpad(3, 3, '\xFF\xFF'), '\x1C\x71\xC7\x1C\x40', t.bytesame )

t( bitpad(-1, 1, '\xFF'), '\xF0', t.bytesame )
t( bitpad(-1, 1, '\xFF\xFF'), '\xFF', t.bytesame )
t( bitpad(-1, 1, '\xFF\xFF\xFF'), '\xFF\xF0', t.bytesame )

t( bitpad(-2, 1, '\xFF'), '\xC0', t.bytesame )
t( bitpad(-2, 1, '\xFF\xFF'), '\xF8', t.bytesame )
t( bitpad(-2, 1, '\xFF\xFF\xFF'), '\xFF', t.bytesame )

t( bitpad(-7, 1, '\x01\x01\x01\x01\x01\x01\x01\x01'), '\xFF', t.bytesame )

t( bitpad(-4, 4, '\xFF'), '\xF0', t.bytesame )
t( bitpad(-4, 4, '\xFF\xFF'), '\xFF', t.bytesame )
t( bitpad(-4, 4, '\xFF\xFF\xFF'), '\xFF\xF0', t.bytesame )

t( bitpad(-4, 4, (bitpad(4, 4, '\x13'))), '\x13', t.bytesame )
t( bitpad(-2, 3, (bitpad(2, 3, '\x13'))), '\x13\x00', t.bytesame ) -- additional padding

t( bitpad(4, 4, '\x01\x00'), '\x00\x01\x00\x00', t.bytesame )
t( bitpad(4, 4, '\x01\x00', {'\xFF'}), '\xFF\x01\xFF\xFF', t.bytesame )
t( bitpad(4, 4, '\x01\x00', {'\xFF','\xF0'}), '\xFF\xF0\xFF\xFF', t.bytesame )

t( bitpad(-4, 4, '\x00\x01'), '\x01', t.bytesame )
t( bitpad(-4, 4, '\x00\x01', {'\x00','\xFF'}), '\xFF', t.bytesame )

t( bitpad(4, 4, '\x01\x00'), '\x00\x01\x00\x00', t.bytesame )
t( bitpad(4, 4, '\x01\x00', nil, {'\x02',}), '\x00\x01\x00\x02', t.bytesame )
t( bitpad(4, 4, '\x01\x00', nil, {'\x02','\xFF'}), '\x0F\x0F\x00\x02', t.bytesame )

t( bitpad(-4, 4, '\x01\x00'), '\x10', t.bytesame )
t( bitpad(-4, 4, '\x01\x00', nil, {'\x02','\x01'}), '\x12', t.bytesame )

t( bitpad(16, 8, '\x01\x01'), '\x00\x00\x01\x00\x00\x01', t.bytesame )
t( bitpad(-16, 8, '\xFF\xFF\x00\xFF\xFF\x00'), '\x00\x00', t.bytesame )

t( bitpad(4, 12, '\xFF\xFF\xFF'), '\x0F\xFF\x0F\xFF', t.bytesame )
t( bitpad(-4, 12, '\x0F\xFF\x0F'), '\xFF\xFF', t.bytesame )

local _,b 

_, b = bitpad(1, 8, '\x00') t( b, 7 )
_, b = bitpad(1, 8, '\x00\x00') t( b, 6 )
_, b = bitpad(1, 8, '\x00\x00\0\0\0\0\0') t( b, 1 )
_, b = bitpad(1, 8, '\x00\x00\0\0\0\0\0\0') t( b, 0 )

_, b = bitpad(-1, 8, '\x00') t( b, 1 )
_, b = bitpad(-1, 8, '\x00\x00') t( b, 2 )
_, b = bitpad(-1, 8, '\x00\x00\0\0\0\0\0') t( b, 7 )
_, b = bitpad(-1, 8, '\x00\x00\0\0\0\0\0\0') t( b, 0 )

t( bitpad(4, 4, '\xFF\xFF\xFF'), '\x0F\x0F\x0F\x0F\x0F\x0F', t.bytesame )
t( bitpad(4, 4, '\xFF\xFF\xFF',nil,nil,4), '\xF0\xF0\xF0\xF0\xF0\xF0', t.bytesame )
t( bitpad(4, 4, '\xFF\xFF\xFF',nil,nil,2), '\xC3\xC3\xC3\xC3\xC3\xC3', t.bytesame )
t( bitpad(4, 4, '\xFF\xFF\xFF',nil,nil,3), '\xE1\xE1\xE1\xE1\xE1\xE1', t.bytesame )
t( bitpad(-4, 4, '\x0F\x0F\x0F\x0F\x0F\x0F'), '\xFF\xFF\xFF', t.bytesame )
t( bitpad(-4, 4, '\xF0\xF0\xF0\xF0\xF0\xF0',nil,nil,4), '\xFF\xFF\xFF', t.bytesame )
t( bitpad(-4, 4, '\xC3\xC3\xC3\xC3\xC3\xC3',nil,nil,2), '\xFF\xFF\xFF', t.bytesame )
t( bitpad(-4, 4, '\xE1\xE1\xE1\xE1\xE1\xE1',nil,nil,3), '\xFF\xFF\xFF', t.bytesame )

t.test_embedded_example()

t()

