--[===[DOC

= peg

-- TODO : CLEAN UP ! -- THIS IS A DRAFT ! --
-- TODO : SYNC : doc and peg api
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
function REP(parser, minInt, maxInt) -> parser
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
however some other parser and operation are defined by default in `peg` to
make easier to write grammars.

The parser `PAT'abc'` is the same of `SEQ{PAT'a',PAT'b',PAT'c'}`; escapes can
be used as usual, e.g. `PAT'a\20b'`

Lua pattern parser can be passed to `PAT`, e.g. `PAT'a%wb'`. This can be used
instead of common PEG extensions, e.g. the any character parser `PAT'.'` or the
character sets like `PAT'[a-zA-Z]'`.

`EMP()` returns a parser equivalent to `ALT{NOT(PAT'a'),NOT(NOT(PAT'a'))}`. It
always matches the empty string i.e. it always returns 0. [1]

`y = REP(x)` is the same of `y = COM() ; COM(y, SEQ{x,ALT{y,EMP()}})`. It
continues to match `z` until it fails. Then it retuns the whole match. If `x`
never matches, it matches the empty strings.

You can sepcify a minimum and maximum number of repetition with `y = REP(x,
min, max)`.  If not enough items are found the parser will fail. If more of the
maximum are present, only a number equal to the maximum will be matched.  The
maximum can be omitted to accept all of them. Other common usages are: `REP(x,
0, 1)` to optionally accept a string, or `REP(x, 1)` to accept any number of
them, but at least one.

The function `CHE(x)` returns a parser equivalent to `NOT(NOT(x))`. It mathces the
empty string if `x` matches, otherwise it fails. It is similar to `x` but it
never consumes the input.

[1] Note an interesting sub-class of PEG is the one without the Not rule but
    with Empty defined as a basic parser. These kind of PEG expression can
    construct any parser that a fully featured PEG can construct, with the
    following exception: if the full-PEG parser match the empty string, the
    sub-PEG one will match any string.

== Math operation

Some of the parser operations seen before are mapped to classical mathematical
operator on the parser objects. The following equivalence list holds:

- `x / y` is the same of `ALT{x, y}`
- `x + y` is the same of `SEQ{x, y}`
- `-x` is the same of `NOT(x)`
- `x - y` is the same of `SEQ{x, NOT(y)}`
- `x ^N`, whre N is zero or a positive integer, is the same of `REP(x, N)`
- `x ^-N`, whre N is a positive integer, is the same of `REP(x, nil, N)`
- `~x`, is the same of `CHE(x)`
- `x ~ y` is the same of `SEQ{x, CHE(y)}`

== Extendability

// TODO : write this section

bla bla

== Example

[source,lua,example]
----
local peg = require 'peg'

local P, S, R, COM = peg.PAT, peg.SEQ, peg.REP, peg.COM
local whitespace = P'[ \t]*'
local name = P'[a-z]+'
local list = S{ whitespace, name, R(S{
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

local function peg_repetition( child_parser, min, max )
  for _, x in ipairs{ min, max} do
    local xt = type(x)
    if ('number' ~= xt and 'nil' ~= xt)
    or ('number' == xt and 0 > x)
    or ('number' == xt and 0 ~= select(2, math.modf(x)))
    then error('second and third parameter of repetition must be nil, zero or a positive integer', 3) end
  end
  return function( DATA, CURR )
    LOG('trying repetition at',DATA:sub(CURR or 1),'...')
    CURR = CURR or 1
    local OLD, ext, count = CURR, {}, 0
    while true do
      if max and max <= count then break end
      local m, r = child_parser( DATA, CURR )
      if not m then break end
      count = count + 1
      CURR = CURR + m
      ext[1+#ext] = r
    end
    if min and count < min then return nil, nil end
    return CURR-OLD, ext
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
local function peg_wrap( inner )
  return setmetatable({
    EXT = function(extra)
      local old = inner
      inner = not old and extra or function( d, c, ...)
        return extra( d, c, old( d, c, ...))
      end
    end
  },{
    __call = function( t, d, c, ...) return inner( d, c, ...) end,
    __add =  function(t,o) return peg_wrap( peg_sequence{ t, o }) end,
    __unm =  function(t)   return peg_wrap( peg_not( t )) end,
    __sub =  function(t,o) return peg_wrap( peg_sequence{t,peg_not(o)}) end,
    __div =  function(t,o) return peg_wrap( peg_alternation{t,o}) end,
    __bnot = function(t)   return peg_wrap( peg_check_no_consume(t)) end,
    __bxor = function(t,o) return peg_wrap( peg_sequence{t,peg_check_no_consume(o)}) end,
    __pow =  function(t,o)
      if 0 >  o then return peg_wrap( peg_repetition(t, 0, -o)) end
      if 0 <= o then return peg_wrap( peg_repetition(t, o, nil)) end
    end,
  })
end
local function peg_compose( base, extra )
  if '' == base then base = peg_wrap( peg_empty())
  elseif 'string' == type(base) then base = peg_wrap( peg_pattern_matcher(base))
  elseif nil == base then base = peg_wrap( extra)
  end
  if extra then
    base.EXT(extra)
  end
  return base
end

local function peg_operator_wrap( op )
  return function( ... ) return peg_wrap( op( ...)) end
end
return {
  COM = peg_compose, -- Only this is actually needed: the others can be generated with math operators
  EMP = peg_operator_wrap(peg_empty),
  PAT = peg_operator_wrap(peg_pattern_matcher),
  NOT = peg_operator_wrap(peg_not),
  SEQ = peg_operator_wrap(peg_sequence),
  ALT = peg_operator_wrap(peg_alternation),
  CHE = peg_operator_wrap(peg_check_no_consume),
  REP = peg_operator_wrap(peg_repetition),
}
