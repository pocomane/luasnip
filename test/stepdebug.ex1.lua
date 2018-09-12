local stepdebug = require 'stepdebug'
local t = require 'testhelper'

-- Test setup
local input=''
local output={}
stepdebug(function()
  if input~=nil then
    output[1+#output] = stepdebug(input)
  end
  stepdebug'next'
end)

stepdebug'break'
input="1"
input='continue'

t( #output, 1 )
t( output[1], 1 )

output, input = {}, nil

stepdebug'break'
input="return 2"
input='continue'

t( #output, 1 )
t( output[1], 2 )

output, input = {}, nil

input='break'
input='1'
input='2'
stepdebug'break'
input='3'
input='4'
input='continue'
input='5'
input='6'

t( #output, 3 )
t( output[1], 2 )
t( output[2], 3 )
t( output[3], 4 )

output, input = {}, nil

stepdebug'break'
input='1'
input='2'
;(function()
  input='3'
  input='4'
end)()
input='5'
input='6'
input='continue'

t( #output, 6 )
t( output[1], 1 )
t( output[2], 2 )
t( output[3], 2 )
t( output[4], 4 )
t( output[5], 5 )
t( output[6], 6 )

output, input = {}, nil

stepdebug'break'
input='step'
input='1'
input='2'
;(function()
  input='3'
  input='4'
  ;(function()
    input='5'
    input='6'
  end)()
  input='7'
  input='8'
end)()
input='9'
input='10'
input='continue'

t( #output, 13 )
t( output[1], 1 )
t( output[2], 2 )
t( output[3], 2 )
t( output[4], 2 )
t( output[5], 3 )
t( output[6], 4 )
t( output[7], 4 )
t( output[8], 6 )
t( output[9], 7 )
t( output[10], 8 )
t( output[11], 8 )
t( output[12], 9 )
t( output[13], 10 )

output, input = {}, nil

stepdebug'break'
input='step'
input='1'
input='2'
;(function()
  input='3'
  input='4'
end)()
input='5'
input='6'
;(function()
  input='7'
  input='8'
end)()
input='9'
input='10'
input='continue'

t( #output, 13 )
t( output[1], 1 )
t( output[2], 2 )
t( output[3], 2 )
t( output[4], 2 )
t( output[5], 3 )
t( output[6], 4 )
t( output[7], 4 )
t( output[8], 5 )
t( output[9], 6 )
t( output[10], 6 )
t( output[11], 8 )
t( output[12], 9 )
t( output[13], 10 )

output, input = {}, nil

stepdebug'break'
input='step'
input='1'
input='2'
;(function()
  input='3'
  input='4'
  input='finish'
  input='5'
  input='6'
  input='7'
end)()
input='8'
input='9'
input='continue'

t( #output, 9 )
t( output[1], 1 )
t( output[2], 2 )
t( output[3], 2 )
t( output[4], 2 )
t( output[5], 3 )
t( output[6], 4 )
t( output[7], 7 )
t( output[8], 8 )
t( output[9], 9 )

output, input = {}, nil

function gupnam() -- must be global
  return debug.getinfo(6).name or ''
end

stepdebug'break'
input='step'
input='gupnam()'
function NL()
  input='gupnam()'
end
NL()
input='gupnam()'
input='continue'

t( #output, 7 )
t( output[4], 'NL' )
t( output[5], 'NL' )

t()

