
local peg = require 'peg'
local pegcore = peg.pegcore

local peg_rule_str = [[
  toplevel <- expression

  expression <- term, (term_operator, term)?
  term <- factor, (factor_operator, factor)?
  factor <- number / sub_expression
  sub_expression <- '%(', expression, '%)'

  number <- '%-?[0-9]+'
  term_operator <- '%+' / '%-'
  factor_operator <- '%*' / '%/'
]]

local text = "2*(-3+5)"

return function()
  local a, b = pegcore(peg_rule_str,nil)
  local CURR, ast
  if a ~= #peg_rule_str then
    CURR, ast = a, nil, b
  else
    CURR, ast = a, b
  end
  local POS = CURR and CURR+1 or 1
  if not CURR or not ast or not ast.func then
    error("invalid rules")
  end
  local last = ast.func(text)
  if last ~= #text then
    error("invalid text")
  end
end

