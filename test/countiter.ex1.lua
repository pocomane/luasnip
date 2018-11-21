local countiter = require 'countiter'
local t = require 'testhelper'

t( countiter(), 0 )
t( countiter( pairs{}), 0 )
t( countiter( pairs{ 1, 2, c='2' }), 3 )
t( countiter( ipairs{ 1, 2, c='2' }), 2 )

t.test_embedded_example()

t()
