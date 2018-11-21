local toposort = require 'toposort'
local t = require 'testhelper'

t( toposort(), {}, t.deepsame )

t( toposort{a={'b'}}, {'b','a'}, t.deepsame )

t( toposort{a={'b','c'}}, {'b','a'}, t.itemorder )
t( toposort{a={'b','c'}}, {'c','a'}, t.itemorder )

t( toposort{a={'b'},b={'c'}}, {'b','a'}, t.itemorder )
t( toposort{a={'b'},b={'c'}}, {'c','b'}, t.itemorder )

t( toposort{a={'b','c'},b={'d'}}, {'b','a'}, t.itemorder )
t( toposort{a={'b','c'},b={'d'}}, {'c','a'}, t.itemorder )
t( toposort{a={'b','c'},b={'d'}}, {'d','b'}, t.itemorder )

t( toposort{a={'b','c'},c={'b'}}, {'b','a'}, t.itemorder )
t( toposort{a={'b','c'},c={'b'}}, {'c','a'}, t.itemorder )
t( toposort{a={'b','c'},c={'b'}}, {'b','c'}, t.itemorder )

t( toposort{a={'c','b'},b={'d'}}, {'c','a'}, t.itemorder )
t( toposort{a={'c','b'},b={'d'}}, {'b','a'}, t.itemorder )
t( toposort{a={'c','b'},b={'d'}}, {'d','b'}, t.itemorder )

t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'b','a'}, t.itemorder )
t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'c','a'}, t.itemorder )
t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'b','d'}, t.itemorder )
t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'c','d'}, t.itemorder )
t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'f','e'}, t.itemorder )
t( toposort{a={'b','c'},d={'b','c'},e={'f','g'}}, {'g','e'}, t.itemorder )

local _, err = toposort{a={'b'},b={'a'}}
t( err, 'cycle detected' )

t.test_embedded_example()

t()

