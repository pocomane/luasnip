local simplepath_c = require 'simplepath'
local t = require 'testhelper'

local sps = function(x) return x:gsub("/", package.config:sub(1,1)) end
local simplepath = function(x) return simplepath_c(sps(x)) end

t( simplepath'a/b/c./d/e', sps'a/b/c./d/e' )
t( simplepath'a/b/.c/d/e', sps'a/b/.c/d/e' )
t( simplepath'a/b./.c/d/e', sps'a/b./.c/d/e' )
t( simplepath'a/b/c../d/e', sps'a/b/c../d/e' )
t( simplepath'a/b/..c/d/e', sps'a/b/..c/d/e' )
t( simplepath'a/b../..c/d/e', sps'a/b../..c/d/e' )

t( simplepath'', '.' )

t( simplepath'./', sps'.' )
t( simplepath'./.', sps'.' )
t( simplepath'././', sps'.' )
t( simplepath'./././.', sps'.' )

t( simplepath'./asd', sps'asd' )
t( simplepath'./.asd', sps'.asd' )
t( simplepath'./asd/q', sps'asd/q' )

t( simplepath'./asd/.', sps'asd' )
t( simplepath'./asd/q/.', sps'asd/q' )

t( simplepath'/asd/q/./w', sps'/asd/q/w' )
t( simplepath'/asd/q/./w/./e', sps'/asd/q/w/e' )

t( simplepath'././asd', sps'asd' )

t( simplepath'../', sps'..' )
t( simplepath'../asd', sps'../asd' )
t( simplepath'../asd/q', sps'../asd/q' )

t( simplepath'a/b/..', sps'a' )
t( simplepath'a/b/c/..', sps'a/b' )

t( simplepath'a/b/../c', sps'a/c' )
t( simplepath'a/b/../c/d/..', sps'a/c' )

t( simplepath'a/b/c/../../d', sps'a/d' )
t( simplepath'a/b/c/d/../../../e', sps'a/e' )
t( simplepath'a/b/c/d/../../..', sps'a' )

t( simplepath'../../a/b/c', sps'../../a/b/c' )

t( simplepath'./..', sps'..' )
t( simplepath'../.', sps'..' )
t( simplepath'././../../a/b/././.././..', sps'../..' )

t.test_embedded_example()

t()
