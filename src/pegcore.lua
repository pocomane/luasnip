--[===[DOC

= pegcore

-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! --
-- TODO : SYNC : doc and pegcore api
-- TODO : REMOVE grammar !!?
-- TODO : ADD comment in grammar ?
-- TODO : SYNC : doc and matchHandlerFunc api
-- TODO - FIX the grammar MATCH HANDLER !

[source,lua]
----
callable parser(inputStrStr, positionInt) -> sizeInt, extraObj
function PAT(patternStr) -> parser
function NOT(parser) -> parser
function SEQ{parser1, parser2, ...} -> parser
function ALT{parser1, parser2, ...} -> parser
function EMP() -> parser
function ZER(parser) -> parser
function ONE(parser) -> parser
function OPT(parser) -> parser
function CHE(parser) -> parser
function COM(parser, extraFunc) -> parser
----

This is a module to write parser though PEG.

A parser is a callable object (function or table) that works on the `inputStr`
string and returns nil if the string does not match a specific pattern. If it
does, the parser returns the `sizeInt` number. It represents the size of a
substring starting at beginning of `inputStr`. This substring does match the
pattern. An additional object can be returned by the parser, needed mainly for
extendability: the module try to be as transparent as possible about it (more
details in the dedicated section).

The `positionInt` integer is the position inside the input string where to start
to try the match.

== PEG basic

The returning `sizeInt` can be interpreted as the number of the character that
the parser "Consumes", if it matches. This analogy is usefull when reasoning on
composed pattern that can consume different part of the input (continue reading
for more details)

The `PAT` function return the basic PEG parser. In its base form it take a
string like `'\xXX'` as argument, where `XX` are two hex digit. These parsers
returns 1 if the first character of the `inputStr` is exactly the character
represented by the `XX` number. If the characeter to mach is not a digit ar a
letter or a whitespace, it can be used directly, e.g. `' '` is the same of
`'\x20'`.  A ' and a \ can be matched with `'\x27'` and `'\x5C'`.

PAT recognizes other syntax in the strings, but for now we consider only this
basic one, since all the other parser can be obtained by the previous one,
using the composition mechanisms described in the next section.

== Composition mechanisms

The function`NOT(x)` returns a parser that will fail when the `x` parser matches.
Otherwise it will match an empty strings. So it does never consumes anything in
the string.

The function `SEQ{x, y}` returns a parser that will match if `x` matches and if
`y` matches starting where `x` stopped. Otherwise it fails. When matching it
return the sum of the result of `x` and `y`. This is where the "Consumption"
analogy helps. for example when the parser `SEQ{PAT'a',PAT'b'}` is applied
to the string "abcd", "a" will be matched from the left part of the sequence
consuming one character. So the right part of the sequence will be applied to
the "bcd" sub-string, and will match returning 1.  The whole sequence will
match the string returning 2. Other item can be added to the sequence, e.g.
`SEQ{PAT'a',PAT'b',PAT'c'}`.

The function `ALT{x, y}` returns a parser that will try to match `x`. If it
mathes then its result will be returned by the whole alternation. Otherwise it
will try to match `y`. More than two alternation can be given, e.g.
`ALT{PAT'x',PAT'y',PAT'x'}`. If none of the alternatve match, the wole
alternation will fail.

The last composition mechanism is recursion, supported directly by lua. Please
note that to express a pair of mutually recursive paresers, you need to add a
level of indirection:

```
local r
local s = SEQ{PAT'y', function(...) return r(...) end}
r =       SEQ{PAT'x', s}
```

To avoid the long boilerplate, there is a workaround using the `COM()` function,
described described in the section about the extendability.

Please note that using recursive parsers can generate infinite loops.

== Other commons parser operators

Every parser can be composed from the basic ones with the shown mchanism,
however some other parser and operation are defined by default in `pegcore` to
make easier to write grammars.

The parser `PAT'abc'` is the same of `SEQ{PAT'a',PAT'b',PAT'c'}`; escapes can
be used as usual, e.g. `PAT'a\20b'`

Lua pattern parser can be passed to `PAT`, e.g. `PAT'a%wb'`. This can be used
instead of common PEG extensions, e.g. the any character parser `PAT'.'` or the
character sets like `PAT'[a-zA-Z]'`.

`EMP()` returns a parser equivalent to `ALT{NOT(PAT'a'),NOT(NOT(PAT'a'))}`. It
always matches the empty string i.e. it always returns 0. [1]

`y = ZER(x)` is the same of `y = COM() ; COM(y, SEQ{x,ALT{y,EMP()}})`. It
continues to match `z` until it fails. Then it retuns the whole match. If `x`
never matches, it matches the empty strings.

Similarly, `y = ONE(x)` returns all the repeated matches of `x`, but it fails if
no one is found.

The function `OPT(x)` returns a parser that is equivalent to `ALT{x,EMP()}`. It
matches `x` otherwise it match the empty string.

The function `CHE(x)` returns a parser equivalent to `NOT(NOT(x))`. It mathces the
empty string if `x` matches, otherwise it fails. It is similar to `x` but it
never consumes the input.

[1] Note an interesting sub-class of PEG is the one without the Not rule but
    with Empty defined as a basic parser. These kind of PEG expression can
    construct any parser that a fully featured PEG can construct, with the
    following exception: if the full-PEG parser match the empty string, the
    sub-PEG one will match any string.

== Extendability

// TODO : write this section

bla bla

== Example

[source,lua,example]
----
local peg = require 'pegcore'

local P, S, Z, COM = peg.PAT, peg.SEQ, peg.ZER, peg.COM
local whitespace = P'[ \t]*'
local name = P'[a-z]+'
local list = S{ whitespace, name, Z(S{
  whitespace, P',', whitespace, name
})}

COM(name, function(d, c, m, r)
  r = nil
  if m then r = d:sub(c,c+m-1) end
  return m, r
end)

local p, ast = list'horse, cat, duck, shark'
assert( p == 23 )
assert( ast[2] == 'horse' )
assert( ast[3][1][4] == 'cat' )
assert( ast[3][2][4] == 'duck' )
assert( ast[3][3][4] == 'shark' )

----

]===]

-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! --

local deb_verbose = false
LOG = function(...)
  if not deb_verbose then return end
  io.write("#")
  local vp = require'valueprint'
  for k = 1, select('#',...) do
    local s = select(k, ...)
    io.write(" ",vp(s):gsub('\n','\n# '),'')
  end
  io.write("\n")
end

local function peg_pattern_matcher( pattern )
  pattern = '^(' .. pattern .. ')'
  result = function( DATA, CURR )
    LOG('trying pattern ', pattern, ' at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local d = DATA:sub( CURR )
    local m = d:match( pattern )
    if not m then return nil end
    return #m, {} -- TODO : do not return {} ???
  end

  return result
end

local function peg_alternation( alternatives )
  local np = #alternatives
  for p = 1, np do local P = alternatives[p] end
  return function( DATA, CURR )
    LOG('trying alternation at',DATA:sub(CURR or 1),'...')
    for p = 1, np do
      local m, r = alternatives[p]( DATA, CURR )
      if m then return m, { p, r } end
    end
    return nil, nil
  end
end

local function peg_sequence( sequence )
  local np = #sequence
  for p = 1, np do local P = sequence[p] end
  return function( DATA, CURR )
    LOG('trying sequence at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local OLD, ext = CURR, {}
    for p = 1, np do
      local m, r = sequence[p]( DATA, CURR )
      if not m then return nil, nil end
      CURR = CURR + m
      ext[1+#ext] = r
    end
    return CURR-OLD, ext
  end
end

local function peg_not( child_parser )
  return function( DATA, CURR )
    LOG('trying not-operator at',DATA:sub(CURR or 1),'...')
    local m, r = child_parser( DATA, CURR )
    if not m then return 0, {} end -- TODO : do not return {} ???
    return nil
  end
end

local function peg_empty( )
  return function( DATA, CURR )
    LOG('trying empty at',DATA:sub(CURR or 1),'...')
    return 0
  end
end

local function peg_zero_or_more( child_parser )
  return function( DATA, CURR )
    LOG('trying zero-or-more at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local OLD = CURR
    local ext = {}
    while true do
      local m, r = child_parser( DATA, CURR )
      if not m then break end
      CURR = CURR + m
      ext[1+#ext] = r
    end
    return CURR-OLD, ext
  end
end

local function peg_one_or_more( child_parser )
  local p = peg_zero_or_more( child_parser )
  return function( DATA, CURR )
    LOG('trying one-or-more at',DATA:sub(CURR or 1),'...')
    local m, r = p( DATA, CURR )
    if 0 == m then return nil, nil end
    return m, r
  end
end

local function peg_optional( child_parser )
  return function( DATA, CURR )
    LOG('trying optional at',DATA:sub(CURR or 1),'...')
    local m, r = child_parser( DATA, CURR )
    if not m then return 0, {} end -- TODO : do not return {} ???
    return m, r
  end
end

local function peg_check_no_consume( child_parser )
  return function( DATA, CURR )
    LOG('trying optional at',DATA:sub(CURR or 1),'...')
    local m, r = child_parser( DATA, CURR )
    if m then m = 0 end
    return m, r
  end
end

-- usability wrapper
local function peg_wrap( wrapper, extra )
  if '' == wrapper then return peg_wrap(nil, peg_empty()) end
  if 'string' == type(wrapper) then return peg_wrap(nil, peg_pattern_matcher(wrapper)) end
  if wrapper then
    wrapper.EXT(extra)
  else
    local inner = extra
    wrapper = setmetatable({
      EXT = function(extra)
        local old = inner
        inner = not old and extra or function( d, c, ...)
          return extra( d, c, old( d, c, ...))
        end
      end
    },{
      __call = function( t, d, c, ...) return inner( d, c, ...) end,
      __add =  function(t,o) return peg_wrap( nil, peg_sequence{ t, o }) end,
      __unm =  function(t)   return peg_wrap( nil, peg_not( t )) end,
      __sub =  function(t,o) return peg_wrap( nil, peg_sequence{t,peg_not(o)}) end,
      __div =  function(t,o) return peg_wrap( nil, peg_alternation{t,o}) end,
      __bnot = function(t)   return peg_wrap( nil, peg_check_no_consume(t)) end,
      __bxor = function(t,o) return peg_wrap( nil, peg_sequence{t,peg_check_no_consume(o)}) end,
      __pow =  function(t,o)
        -- TODO : better and more generic definition !
        if 0 == o then  return peg_wrap( nil, peg_zero_or_more(t)) end
        if 1 == o then  return peg_wrap( nil, peg_one_or_more(t)) end
        if -1 == o then return peg_wrap( nil, peg_optional(t)) end
      end,
    })
  end
  return wrapper
end
local function peg_operator_wrap( op )
  return function( ... ) return peg_wrap( nil,  op( ...)) end
end

local _M = {
  COM = peg_wrap, -- Only this is actually needed: the others can be generated in other ways
  CHE = peg_operator_wrap(peg_check_no_consume),
  OPT = peg_operator_wrap(peg_optional),
  ONE = peg_operator_wrap(peg_one_or_more),
  ZER = peg_operator_wrap(peg_zero_or_more),
  EMP = peg_operator_wrap(peg_empty),
  NOT = peg_operator_wrap(peg_not),
  SEQ = peg_operator_wrap(peg_sequence),
  ALT = peg_operator_wrap(peg_alternation),
  PAT = peg_operator_wrap(peg_pattern_matcher),
}

--------------------------------------------------------7
-- TODO : move the next section somewhere else ! (maybe remove ?)

local function astwrap(op, aster)
  return function(...)
    local result = op(...)
    _M.COM(result, aster)
    return result
  end
end

local function create_core_parser( match_handler )
  local COM = _M.COM
  local EMP = astwrap(_M.EMP, function(_, _, r, _) return r, r and { tag = 'e' } or nil end)
  local PAT = astwrap(_M.PAT, function(d, c, r, _) return r, r and { d:sub( c, c+r-1 ) } or nil end)
  local NOT = astwrap(_M.NOT, function(_, _, r, _) return  r, r and { tag = 'n' } or nil end)
  local ALT = astwrap(_M.ALT, function(_, _, r, x) return r, r and { x[2], tag = "a"..tostring(x[1]), selected = x[1] } or nil end)
  local SEQ = astwrap(_M.SEQ, function(_, _, r, x)
    if nil == r then return nil, nil end
    x.tag = 's'
    return r, x
  end)
  local ZER = astwrap(_M.ZER, function(_, _, r, x)
    if nil == r then return nil, nil end
    x.tag = 'z'
    return r, x
  end)

  local whitespace =   PAT'[ \t\n\r]*'

  local identifier =   SEQ{ whitespace, PAT'[a-zA-Z][_0-9a-zA-Z]*', }
  local pattern =      SEQ{ whitespace, PAT"'[^']*'", }
  local empty =        SEQ{ whitespace, PAT'~', }
  local alternation =  COM()
  local expression =   SEQ{ whitespace, PAT'%(', alternation, whitespace, PAT'%)', }
  local capture =      SEQ{ PAT':', identifier, }

  local primary =      ALT{  expression, pattern, empty, capture, identifier, NOT( PAT'<%-' ), } -- TODO : !<- should be in a sequence

  local suffix =       SEQ{ primary, whitespace, PAT'[*+?]?', }
  local prefix =       SEQ{ whitespace, PAT'[&!]?', suffix, }

  local sequence =     COM()
  COM(  sequence,      SEQ{ prefix,   ZER( SEQ{ whitespace, PAT',', sequence, }), })
  COM(  alternation,   SEQ{ sequence, ZER( SEQ{ whitespace, PAT'/', alternation, }), })

  local rule =         SEQ{ identifier, whitespace, PAT'<%-', alternation, whitespace, }
  local toplevel =     ZER( rule )

  local parsed_grammar = {} -- parsed rules
  local captured_grammar = {}

  -- TODO : capture-group experimetatuon - SIMPLIFY !!! !
  local parsed_ref = function( rule, return_cather )
    local capture = captured_grammar[rule]
    if not capture then
      capture = {}
      captured_grammar[rule] = capture
    end

    local function define( data, curr )
      LOG('trying non-terminal', rule, 'at',data:sub(curr or 1),'...')
      local p
      if 'function' == type(parsed_grammar) then
        p = parsed_grammar(rule)
      else
        p = parsed_grammar[rule]
      end
      curr = curr or 1
      local a,b = p( data, curr )
      if b then b.tag = rule end
      if b and rule_handler then
        b = rule_handler( b )
        -- TODO : do not match if b == nil !!?
      end

      if a ~= nil then
        curr = curr or 1
        capture[1] = curr
        capture[2] = curr + a -1
      end

      return a,b
    end

    local function refer( DATA, CURR )
      CURR = CURR or 1
      LOG('trying captured at', DATA:sub(CURR), '...')
      local cap = capture
      if not capture[1] then return EMP()( DATA, CURR ) end
      cap = DATA:sub( capture[1], capture[2] )
      local siz = #cap
      local cur = DATA:sub( CURR, CURR + siz -1 )
      if cap ~= cur then return nil, nil end
      return siz, { cap, tag = 'c', }
    end

    if not return_cather then return define end
    return define, refer
  end

  COM(identifier, function(_, _, c, x)
    if c and c >= 0 then
      local name = x[2][1]
      x.func = parsed_ref( name )
    end
    return c, x
  end)

  COM(pattern, function(_, _, c, x)
    if c and c >= 0 then
      local y = x
      y = y[2][1]:sub( 2, -2 ):gsub( '\\%x%x', function( h )
        return string.char(tonumber( h:sub( 2 ), 16 ))
      end)
      x.func = PAT( y )
    end
    return c, x
  end)

  COM(empty, function(_, _, c, x)
    if c and c >= 0 then
      x.func = EMP()
    end
    return c, x
  end)

  COM(expression, function(_, _, c, x)
    if c and c >= 0 then
      x.func = x[3].func
    end
    return c, x
  end)

  COM(capture, function(_, _, c, x)
    if c and c >= 0 then
      local _, f = parsed_ref( x[2][2][1], true )
      x.func = f
    end
    return c, x
  end)

  COM(primary, function(_, _, c, x)
    if c and c >= 0 then
      x.func = x[1].func
    end
    return c, x
  end)

  COM(suffix, function(_, _, c, x)
    if c and c >= 0 then
      local o = x[3][1]
      if     o == '*' then x.func = ZER( x[1].func )
      elseif o == '?' then x.func = ALT{ x[1].func, EMP() }
      elseif o == ''  then x.func = x[1].func
      elseif o == '+' then x.func = function(...)
          local y, z = (SEQ{ x[1].func, ZER( x[1].func ) })(...)
          if not z then return y, z end
          local w = {}
          w.tag = 'o'
          w[1] = z[1]
          for _, k in ipairs(z[2]) do
            w[1+#w] = k
          end
          return y, w
        end
      end
    end
    return c, x
  end)

  COM(prefix, function(_, _, c, x)
    if c and c >= 0 then
      local o = x[2][1]
      if     o == '!' then x.func = NOT( x[3].func )
      elseif o == '&' then x.func = NOT( NOT( x[3].func ))
      elseif o == ''  then x.func = x[3].func
      end
    end
    return c, x
  end)

  COM(sequence, function(_, _, c, x)
    if c and c >= 0 then
      if 0 == #(x[2]) then
        x.func = x[1].func
        return c, x
      end
      local seqa = x[1].seq
      if not seqa then seqa = { x[1].func } end
      local seqb = x[2][1][3].seq
      if not seqb then seqb = { x[2][1][3].func } end
      local seq = {}
      for _, v in ipairs(seqa) do seq[1+#seq] = v end
      for _, v in ipairs(seqb) do seq[1+#seq] = v end
      x.seq = seq
      x.func = SEQ(seq)
    end
    return c, x
  end)

  COM(alternation, function(_, _, c, x)
    if c and c >= 0 then
      if 0 == #(x[2]) then
        x.func = x[1].func
        return c, x
      end
      local alta = x[1].alt
      if not alta then alta = { x[1].func } end
      local altb = x[2][1][3].alt
      if not altb then altb = { x[2][1][3].func } end
      local alt = {}
      for _, v in ipairs(alta) do alt[1+#alt] = v end
      for _, v in ipairs(altb) do alt[1+#alt] = v end
      x.alt = alt
      x.func = ALT(alt)
    end
    return c, x
  end)

  COM(rule, function(_, _, c, x)
    if c and c >= 0 then
      local tag = x[1][2][1]
      local func = x[4].func
      parsed_grammar[tag] = func
    end
    return c, x
  end)

  COM(toplevel, function(_, _, c, x)
    if c and c >= 0 then
      x.func = parsed_grammar.toplevel and parsed_ref'toplevel'
    end
    return c, x
  end)

  return toplevel
end

local function pegcore( peg_rules, rule_handler )
  -- NOTE : here the compiler is implemente as a matching-time handler.
  local meta_parser = create_core_parser( rule_handler )
  return meta_parser( peg_rules, 1 )
end

-- TODO : move the previous section somewhere else ! (maybe remove ?)
--------------------------------------------------------7

_M.pegcore = pegcore
return _M
