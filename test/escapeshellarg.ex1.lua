
local escapeshellarg = require "escapeshellarg"
local t = require "testhelper"

local lua, argdumputil, outpath = t.argdumputil()
local p = lua..' '..argdumputil..' '
local d

d = [[Hello's world]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[use a " to mark]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[should escape \]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[special $PATH]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[special %PATH%]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[redirect>o.txt]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[redirect<i.txt]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[pipe|extcmd]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[<]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

d = [[>]]
os.execute( p..escapeshellarg( d ))
t( t.readfile(outpath), d )

t( escapeshellarg'-i', '-i' )

t()
