--[===[DOC

= pegcore

-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! -- 
-- TODO : ADD comment in grammar ?
-- TODO : SYNC : doc and pegcore api
-- TODO : SYNC : doc and matchHandlerFunc api
-- TODO - FIX THE MATCH HANDLER !

[source,lua]
----
function pegcore( grammarStr, matchHandlerFunc ) -> parserFunc
function parserFunc( inputStr, positionInt ) -> sizeInt, astTab
----

This is a module to write parser though PEG.

A parser is a `parserFunc` function that works on the `inputStr` string and
returns nil if the string does not match a specific pattern. If it does, the
parser returns the `sizeInt` number. It represents the size of a substring
starting at beginning of `inputStr`. This substring does match the pattern.

The `grammarStr` string describes the parser and so the pattern that it try to
match. The syntax and PEG sematic is desripted in the next character.

The `positionInt` integer is the position inside the input string where to start
to try the match.

The `astTab` table is a table representition of how the string was matched. It
is nil if the parser does not match. Otherwise it will contain recursively a
sub table for each basic pattern or rules that matched. The table generated by
a basic (or lua) pattern, contains the matched string. The sub-table
corresponding to a non-terminal rule will contain also a "tag" field with the
name of the non-terminal.

The `matchHandlerFunc` will be called each time a non-terminal matches. The
matched sub-table is passed to it, the same one that can be found in the
`astTab`. If it retusns nil, the parser will be considered to not match.
Otherwise, the result will be substitute to the sub-table inside the resulting
`astTab`, and the parser will be considered to match (as if no
`matchHandlerFunc` was provided)

== PEG basic

The returning `sizeInt` can be interpreted as the number of the character that
the parser "Consumes", if it matches. This analogy is usefull when reasoning on
composed pattern that can consume different part of the input (continue reading
for more details)

The `grammarStr` string describes the parser and so the pattern that it try to
match. The basic pattern strings are like `toplevel<-'%\XX'` where XX are two
hex digits. These parsers returns 1 if the first character of the `inputStr` is
exactly the character represented by the XX number. If the characeter to mach
is not a digit ar a letter or a whitespace, it can be used directly, e.g. `' '`
is the same of `'\20'`.  A ' and a \ can be matched with `'%\27'` and `'%\5C'`.

All the other parser can be obtained by the previous one, using the composition
mechanisms described in the next section.

== Composition mechanisms

A name can be assigned to a specific pattern to reuse it in other part of PEG.
We refert to this with "Non-terminal" or "Peg rule". The syntax is `x<-'a'
toplevel<-x` where `x` is the name assigned to the pattern `'a'`. Recursive
definition are allowed, but be aware that this can arise infinte-loop issues.
The full set of defined non-terminal can be seen as a set of rules defining a
parser and so a language.

The `toplevel` keyword used before is just an ordinay non-terminal definition.
The only special thing about `toplevel` is that it is the root non-terminal
that `parserFunc` will try to match. So a `toplevel` terminal must be defined,
otherwise `pegcore` will return nil.

The non-terminal name can be composed of letters, digits and underscore, and
they are case sensitive.  Such name will represent a previously defined
non-terminal in the following. However the following is valid also substituding
a basic parser to such names, as well as a sub-expression.

The subexpression `( ... )` can contain any basic parser, or other
sub-expression, or non-terminals, or one of the other composition operations.
It is used to group operations togeter and fix their the precedence order.

The not predicate `toplevel<-!x` will fail if `x` matches. Otherwise it will
match an empty strings. So it does never consumes anything in the string.

The parser sequence `toplevel<-x,y` will match if `x` matches and if `y`
matches starting where `x` stopped. It return the sum of the result of `x` and
`y`. This is where the "Consumption" analogy helps. for example when the parser
`toplevel<-'a','b'` is applied to the string "abcd", "a" will be matched from
the left part of the sequence consuming one character. So the right part of the
sequence will be applied to the "bcd" sub-string, and will match returning 1.
The whole sequence will match the string returning 2. Other item can be added
to the sequence, e.g. `toplevel<-a,b,c,d`.

The parser alternation `toplevel<-x/y` will try to match `x`. If it mathes then
its result will be returned by the whole alternation. Otherwise it will try to
match `y`. More than two alternation can be given, e.g. `toplevel<-w/x/y/z`. If
none of the alternatve match, the wole alternation will fail.

== Extended basic patterns

Every parser can be composed from the basic ones with the shown mchanism,
however some other parser and operation are defined by default in `pegcore` to
make easier to write grammars.

The basic parser sequence `'abc'` is the same of `('a','b','c')`; escapes can
be used as usual, e.g. `'a\20b'`

Lua pattern parser can be used in the parser sequence, e.g. `'a%wb'`. So,
actually anything between two ' is interepreted as a lua pattern, after the `\XX`
sequence expansion. This can be used instead of common PEG extensions, e.g. the
any character parser `'.'` or the character sets like `'[a-zA-Z]'`.

The empty `~` pattern is the same of `((!'a')/(!!'a'))`. It always matches
the empty string i.e. it always returns 0. [1]

The optional pattern `a?` is the same of `(a/~)`. It matches `a` otherwise it
match the empty string.

The zero-or-more pattern `a*` is the same of `R<-a toplevel<-a,(R/~)`. It
continues to match `a` until it fails. Then it retuns the whole matche. If `a`
never matches, `a*` matches the empty strings.

The one-or-more pattern `a+` is the same of `a+`. It behaves like `a*` except
it fails if `a` never matches.

The check-and-backtrack pattern `&a` is the same of `(!(!(a)))`. It mathces the
empty string if a matches, otherwise it failse. It is similar to `a` but it
never consumes the input.

[1] Note an interesting sub-class of PEG is the one without the Not rule but
    with Empty defined as a basic parser. These kind of PEG expression can
    construct any parser that a fully featured PEG can construct, with the
    following exception: if a parser match the empty string, it will match any
    string.

== Whole Peg grammar

The grammar of `grammarStr` is actually more flexible of the one described till
now. For example you can use spaces and newlines to format it. The whole
grammar, written itself with PEG, is the following:

```
toplevel <- rule*
rule <- identifier, ws, '<-', alternation, ws
alternation <- sequence, (ws, '/', sequence)*
sequence <- (ws, '[!&]'?, suffix)+
suffix <- primary, ws, '[*+?]'
primary <- expression / pattern / empty / (identifier, !'<-')
expression <- ws, '(', alternation, ws, ')'
pattern <- ws, '%\27', (!'%\27', '.')*, '%\27'
empty <- ws, '~'
identifier <- ws, '[a-zA-Z]', '[_0-9a-zA-Z]'+
ws <- '[ \0D\10\09]'
```

== Result analisys considerations

To analize the match, you can either parse the `astTab` or use a
`matchHandlerFunc`. However, usually, the former method has better performance
since the elaboration is performed only on the final result, while
`matchHandlerFunc` is called also on partial results that could be discarded in
a second time (due to non-matching super-rule). So we suggest to use that one.
The `matchHandlerFunc` is more usefull for adding some special parsing
condition thar are simpler to write in lua instead of PEG (or maybe to write
some small parser part that can not be even written with the sole PEG).

The `pegcore` parser itself is written using the same engine used to generate
the final parser. So `pegcore` also needs to analize the match results. To this
purpose it uses the `matchHandlerFunc` method because it is simpler, and
because the PEG rules are usually small. This method will not impact on the
performance of the resulting parser, only on the ones of the PEG expression
parser.

== Example

[source,lua,example]
----
local pegcore = require 'pegcore'

local grammar = [[
whitespace <- '[ \t]*'
name <- '[a-z]+'
toplevel <- whitespace, name, ( whitespace, ',', whitespace, name ) *
]]

local _, list_parse = pegcore(grammar)
local p, ast = list_parse.func 'horse, cat, duck, shark'

assert( ast[2].tag == 'name' )
assert( ast[2][1] == 'horse' )

assert( ast[3][1][4].tag == 'name' )
assert( ast[3][1][4][1] == 'cat' )

assert( ast[3][2][4].tag == 'name' )
assert( ast[3][2][4][1] == 'duck' )

assert( ast[3][3][4].tag == 'name' )
assert( ast[3][3][4][1] == 'shark' )

-- TODO - FIX THE MATCH HANDLER !

-- local result = {}
-- local function handle( m )
--   print(require'valueprint'(m))
--   if m.tag == 'name' then
--     result[1+#result] = m[1]
--   end
--   print('done')
-- end

-- local _, list_parse = pegcore(grammar, handle)
-- list_parse.func('horse, cat, duck, shark')

-- assert( result[1] == 'horse' )
-- assert( result[2] == 'cat' )
-- assert( result[3] == 'duck' )
-- assert( result[4] == 'shark' )

----

]===]

-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! -- 

local function peg_pattern_matcher( pattern )
  -- TODO : memo ?
  pattern = '^(' .. pattern .. ')'
  result = function( DATA, CURR )
    CURR = CURR or 1
    local d = DATA:sub( CURR )
    local ast = { d:match( pattern ) }
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
        r = { r, tag = "a"..tostring(p), selected = p }
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
    local OLD, ast = CURR, { tag = "s" }
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
    local ast = { tag = "n" }
    local X, r = child_parser( DATA, CURR )
    if nil == r then
      return 0, ast
    end
    return nil, nil
  end
end

local function peg_empty( )
  return function( DATA, CURR )
    local ast = { tag = "e" }
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
    if b and match_handler then
      b = match_handler( b )
      -- TODO : do not match if b == nil !!?
    end
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
    local OLD, ast = CURR, { tag = "z" }
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

    identifier =   SEQ{ REF'whitespace', PAT'[a-zA-Z][_0-9a-zA-Z]*', },
    pattern =      SEQ{ REF'whitespace', PAT"'[^']*'", },
    empty =        SEQ{ REF'whitespace', PAT'~', },
    expression =   SEQ{ REF'whitespace', PAT'%(', REF'alternation', REF'whitespace', PAT'%)', },

    primary =      ALT{  REF'expression', REF'pattern', REF'empty', REF'identifier', NOT( PAT'<%-' ), }, -- TODO : !<- should be in a sequence

    suffix =       SEQ{ REF'primary', REF'whitespace', PAT'[*+?]?', },
    prefix =       SEQ{ REF'whitespace', PAT'[&!]?', REF'suffix', },

    sequence =     SEQ{ REF'prefix',   ZER( SEQ{ REF'whitespace', PAT',', REF'sequence', }), },
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

  function  T.pattern( x )
    x = x[2][1]:sub( 2, -2 ):gsub( '\\%x%x', function( h )
      return string.char(tonumber( h:sub( 2 ), 16 ))
    end)
    return peg_pattern_matcher( x )
  end

  function T.identifier(x)   return REF( x[2][1] ) end
  function T.sequence(x)
    if 0 == #(x[2]) then return x[1].func end
    local seqa = x[1].seq
    if not seqa then seqa = { x[1].func } end
    local seqb = x[2][1][3].seq
    if not seqb then seqb = { x[2][1][3].func } end
    local seq = {}
    for _, v in ipairs(seqa) do seq[1+#seq] = v end
    for _, v in ipairs(seqb) do seq[1+#seq] = v end
    x.seq = seq
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
  function T.expression(x)   return x[3].func end

  function T.primary(x)   return x[1].func end
  
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
  -- NOTE : here the compiler is implemente as a matching-time handler.
  local compiler_callback = create_compiler( rule_handler )
  local meta_parser = create_core_parser( compiler_callback )
  return meta_parser( peg_rules, 1 )
end

return pegcore
