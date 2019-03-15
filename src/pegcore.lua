--[===[DOC

= pegcore

THIS IS A DRAFT ! -- TODO : CLEAN UP !

-- TODO : ADD comment in grammar ?

[source,lua]
----
function pegcore( grammarStr, matchHandlerFunc ) -> parserFunc
function parserFunc( inputStr, positionInt ) -> sizeInt, astTab
----

This module let you to write parser though PEG.

A parser is a 'parserFunc' function that works on the 'inputStr' string and returns
nil if the string does not match a specific pattern. If it does, the parser returns the 'sizeInt' number. It represents the size of a substring starting at beginning of 'inputStr'. This substring does match the pattern.

The 'grammarStr' string describes the parser and so the pattern that it try
to match. The basic patter that this string can describe are like "
toplevel<-'%\XX' " where XX are two hex digits. These parsers returns 1 if
the first character of the 'inputStr' is exactly the character represented by
the XX number. If the characeter is not ' and \, it can be used directly,
e.g. ' ' is the same of '\20'. The ' and \ can be matched with '%\27' and
'%\5C'.

All the other parser can be obtained by the previous one, using four
composition mechanisms.

The not predicate looks like " toplevel<-!'x' ". ...

The parser sequence looks like "toplevel<-'x','y'". ...

The parser alternation looks like "toplevel<-'x'/'y'". ...

A non terminal parser looks like "x<-'a' toplevel<-x". ...

We note that the 'toplevel' keyword used before is just an ordinay non terminal
definition. The only special thing about 'toplevel' is that it is the
non-terminal that will try to match the resulting parser. So a 'toplevel'
terminal MUST be defined, otherwise 'pegcore' will return nil.

Every parser can be composed from the basic ones, using the prevous operation. However
some other parser and operation are defined in 'pegcore' to make easier to write grammars.
- Basic parser sequence - ...
- Lua pattern parser - Anything in a between two ' is interepreted as a lua
  pattern (after the \XX sequence expansion). ... . This can be used instead of
  common PEG extensions, e.g. the any character parser '.' or the character
  sets like '[a-zA-Z]'. ...
- Empty " toplevel<-~ " - it always match, and always returns 0 (empty
  substring). It can be sintesized as (!'a')/(!!'a'). [1]
- Optional - ...
- Zero or more - ...
- One or more - ...
- Check and backtrack - ...

[1] Nota una sottoclasse interessqnte e' peg
  senza not ma con Empty definito come parser base. Queste peg speciali fare
  tutto quello che fa una peg normale eccetto accettare una stringa vuota (o
  perlomeno possono accettarla, ma a quel punto devono accettare qualsiasi
  stringa).

Actuallym the grammar of 'grammarStr' is more flexible of the one described till now. For example you can use spaces and newlines to format it. The whole grammar, written itself with PEG, is the following:

(THERE ARE SOME DIFFERENCES !!! -- TODO : WRITE HERE THE REAL ONE !!!):
  grammar <- (nonterminal ’<-’ sp pattern)+
  pattern <- alternative (’/’ sp alternative)*
  alternative <- ([!&]? sp suffix)+
  suffix <- primary ([*+?] sp)*
  primary <- ’(’ sp pattern ’)’ sp / ’.’ sp / literal / charclass / nonterminal !’<-’
  literal <- [’] (![’] .)* [’] sp
  charclass <- ’[’ (!’]’ (. ’-’ . / .))* ’]’ sp
  nonterminal <- [a-zA-Z]+ sp

It follows a description of the other arguments and parameters used with 'pegcore' and 'parserFunc'.

'matchHandlerFunc' ...

'positionInt' ...

'astTab' ...

== Example

[source,lua,example]
----
local pathpart = require 'pathpart'

-- TODO - write some example
assert( x == nil )

----

]===]

local function peg_pattern_matcher( pattern )
  -- TODO : memo ?
  pattern = '^(' .. pattern .. ')'
  result = function( DATA, CURR )
    CURR = CURR or 1
    local d = DATA:sub( CURR )
    local ast = {tag='peg_pattern', d:match( pattern )}
    if #ast == 0 then
      return nil, nil
    end
    local size = 0
    for i = 1, #ast do
      size = size + #(ast[i]) -- strlen(ast[i])
    end
    CURR = CURR + size
    return size, ast
  end

  return result
end

local function peg_alternation( alternatives )
  local np = #alternatives
  for p = 1, np do local P = alternatives[p] end
  return function( DATA, CURR )
    for p = 1, np do
      local X, r = alternatives[p]( DATA, CURR )
      if nil ~= r then
        r = { r, selected = p, tag = 'peg_alternation'}
        return X, r
      end
    end
    return nil, nil
  end
end

local function peg_sequence( sequence )
  local np = #sequence
  for p = 1, np do local P = sequence[p] end
  return function( DATA, CURR )
    CURR = CURR or 1
    local OLD, ast = CURR, {tag='peg_sequence'}
    for p = 1, np do
      local X, r = sequence[p]( DATA, CURR )
      if nil == r then
        return nil, nil
      end
      CURR = CURR + X
      ast[1+#ast] = r
    end
    return CURR-OLD, ast
  end
end

local function peg_not( child_parser )
  return function( DATA, CURR )
    local ast = { tag = 'peg_not' }
    local X, r = child_parser( DATA, CURR )
    if nil == r then
      return 0, ast
    end
    return nil, nil
  end
end

local function peg_empty( )
  return function( DATA, CURR )
    local ast = { tag = 'peg_empty' }
    return 0, ast
  end
end

local function peg_non_terminal( match_handler, grammar, rule )
  -- TODO : memo
  return function( data, curr )
    local p
    if 'function' == type(grammar) then
      p = grammar(rule)
    else
      p = grammar[rule]
    end
    local a,b = p( data, curr )
    if b then b.tag = rule end
    if b and match_handler then b = match_handler( b ) end
    return a,b
  end
end

local function peg_reference( match_handler , parser_getter )
  return function( rule )
    return peg_non_terminal( match_handler, parser_getter, rule )
  end
end

local function peg_zero_or_more( child_parser )
--   local rec
--   local function REC(...) return rec(...) end
--   rec = peg_alternation({peg_sequence({x,REC}),peg_empty()})
--   return rec
  return function( DATA, CURR )
    CURR = CURR or 1
    local OLD, ast = CURR, { tag = 'peg_zero_or_more' }
    while true do
      local X, r = child_parser( DATA, CURR )
      if nil == r then break end
      CURR = CURR + X
      ast[1+#ast] = r
    end
    return CURR-OLD, ast
  end
end

--------------------------------------------------------

local function create_core_parser( match_handler )
  local rules
  local REF = peg_reference( match_handler, function( r ) return rules[r] end )

  local EMP, PAT, ALT, SEQ = peg_empty, peg_pattern_matcher, peg_alternation, peg_sequence
  local NOT, ZER = peg_not, peg_zero_or_more

  rules = {
    whitespace =   PAT'[ \t\n\r]*',

    identifier =   SEQ{ REF'whitespace', PAT'[a-zA-Z]+[%-_0-9a-zA-Z]*', },
    verbatim =     SEQ{ REF'whitespace', PAT"'[^'][^']-'", },
    empty =        SEQ{ REF'whitespace', PAT'~', },
    subexpr =      SEQ{ REF'whitespace', PAT'%(', REF'alternation', REF'whitespace', PAT'%)', },

    primary =      ALT{ REF'identifier', REF'verbatim', REF'empty', REF'subexpr', NOT( PAT'<%-' ), },

    prefix =       SEQ{ REF'whitespace', PAT'[&!]?', REF'primary', },
    suffix =       SEQ{ REF'prefix', REF'whitespace', PAT'[*+?]?', },

    sequence =     SEQ{ REF'suffix',   ZER( SEQ{ REF'whitespace', PAT',', REF'sequence', }), },
    alternation =  SEQ{ REF'sequence', ZER( SEQ{ REF'whitespace', PAT'/', REF'alternation', }), },

    rule =         SEQ{ REF'identifier', REF'whitespace', PAT'<%-', REF'alternation', REF'whitespace', },
    toplevel =     ZER( REF'rule' ),
  }

  return REF'toplevel' -- forcing call to reference handler
end

local function create_compiler( match_handler )
  local R = {} -- parsed rules
  local REF = peg_reference( match_handler, R )

  local T = {} -- sub-transformer

  function  T.verbatim( x )
    x = x[2][1]:sub( 2, -2 ):gsub( '\\%x%x', function( h )
      return string.char(tonumber( h:sub( 2 ), 16 ))
    end)
    return peg_pattern_matcher( x )
  end

  function T.identifier(x)   return REF( x[2][1] ) end
  function T.peg_alternation(x)   return x[1].func end
  function T.sequence(x)
    if 0 == #(x[2]) then return x[1].func end
    local seq = {x[1].func}
    for _, v in ipairs(x[2]) do
      seq[1+#seq] = v[3].func
    end
    return peg_sequence(seq)
  end
  function T.alternation(x)
    if 0 == #(x[2]) then return x[1].func end
    local alts = {x[1].func}
    for _, v in ipairs(x[2]) do
      alts[1+#alts] = v[3].func
    end
    return peg_alternation(alts)
  end
  function T.prefix(x)
    local o = x[2][1]
    if     o == '!' then return peg_not( x[3].func )
    elseif o == '&' then return peg_not( peg_not( x[3].func ))
    elseif o == ''  then return x[3].func
    end
  end
  function T.suffix(x)
    local o = x[3][1]
    if     o == '*' then return peg_zero_or_more( x[1].func )
    elseif o == '+' then return peg_sequence{ x[1].func, peg_zero_or_more( x[1].func ) }
    elseif o == '?' then return peg_alternation{ x[1].func, peg_empty() }
    elseif o == ''  then return x[1].func
    end
  end
  function T.empty(x)        return peg_empty() end
  function T.subexpr(x)      return x[3].func end

  -- TODO : add somehow the automatic fallback ??!
  T.primary = T.peg_alternation
  
  function T.rule( x )
    local tag = x[1][2][1]
    local func = x[4].func
    R[tag] = func
  end
  function T.toplevel( x )
    -- force to call the reference handler
    return R.toplevel and REF'toplevel'
  end

  return function( ast )
    if T[ast.tag] then ast.func = T[ast.tag]( ast ) end
    return ast
  end
end

local function pegcore( peg_rules, rule_handler )
  -- NOTE : here the compiler is implemente as a matching-time handler. For the
  -- user defined languages, it could be more efficicient to operate on the
  -- final abstract-tree instead.
  local compiler_callback = create_compiler( rule_handler )
  local meta_parser = create_core_parser( compiler_callback )
  return meta_parser( peg_rules, 1 )
end

return pegcore
