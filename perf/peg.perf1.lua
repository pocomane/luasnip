
local peg = require 'peg'

local number = peg.PAT'%-?[0-9]+'

local factor_operator = peg.PAT'%*' / peg.PAT'/'
local term_operator =   peg.PAT'%+' / peg.PAT'%-'

local expression =      peg.COM()

local sub_expression =  peg.PAT'%(' + expression + peg.PAT'%)'
local factor =          number / sub_expression
local term =            factor + (factor_operator + factor) ^0

expression.EXT(         term + (term_operator + term)^0)

local toplevel =        expression

local base = "(1+2)*(-3-4)/50"
base = base .. '*(' .. base .. '*(' .. base .. '))'
base = base .. '+(' .. base .. '+(' .. base .. '))'
local good = '0+(' .. (base .. '+' .. base .. '*'):rep(10) .. base .. ')'
local bad = '(' .. good

return function()
  local last = toplevel(good)
  if last ~= #good then error("text not parsed") end
  local last = toplevel(bad)
  if last ~= nil then error("error not catched") end
end

