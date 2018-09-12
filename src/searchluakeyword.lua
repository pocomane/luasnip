--[===[DOC

= searchluakeyword

[source,lua]
----
function searchluakeyword( luaStr [, optStr] ) --> keywordTab, countInt
----

Count the number of lua keywords in the `luaStr` code string. It ignores the
content of lua comments and strings. This function is ment to be run on valid
lua code, so the common `load` lua function should be used first to check if
the compilation successed.

The main use case is the check of the presence of some lua structures to decide
if run the code or not (e.g. for configuration files).

An optional `optStr` string may be povided; it describes which keyword search
for. It is a string, containing one of more of the following charactes, each
corresponding to a class of keywords:

- 'i': Keywords that may generate infinite loops e.g. "function" or any '::label::'
- 'l': Keywords found in a limited loop e.g. "for"
- 'v': Keywords that are value literal e.g. "nil"
- 'b': Keywords that generate branched execution e.g. "if"
- 'o': Keywords that are operators e.g. "and"
- 's': Sequences of symbols that have special meaning in lua, e.g. '[' or '<<'

When not provided, all the keywords will be searched except the symbols, i.e.
'ilvbo' is the default option string.

The result `keywordTab` table contains the found keywords. Each key is a
keyword, and its value is a sequence of integer. Each integer is a byte
position in the code where the begin of the keyword was found.

Also an additional `countInt` integer return value is provaided, containing the
the total number of keywords found.

]===]

local clear_bracket_string_end

local function clear_bracket_string_start( luaStr, init )
  local s, e = luaStr:find('%[=*%[', init)
  if not s then return luaStr end
  return clear_bracket_string_end( luaStr, e-s-1, e )
end

function clear_bracket_string_end( luaStr, c, e )
  local R = ']' .. ('='):rep(c) .. ']'
  local S, E = luaStr:find(R, e, 'plain')
  if not S then S, E = #luaStr, #luaStr end
  local L = R:gsub('%]','[')
  luaStr = luaStr:sub(1,e-c-2) .. L .. (' '):rep(S-e-1) .. R .. luaStr:sub(E+1)
  return clear_bracket_string_start( luaStr, E+1 )
end

local function mask_fake_keyword( luaStr )
  local function clear_middle_string( a, x, b ) return a..(' '):rep(#x)..b end
  luaStr = luaStr:gsub('(%-%-)([^\n]*)(\n?)', clear_middle_string)
  luaStr = luaStr:gsub([[(['"])(.-)(%1)]], clear_middle_string)
  return clear_bracket_string_start( luaStr, 1 )
end

local function first_capture_list( luaStr, p )
  local result = {}
  local count = 0
  for position in luaStr:gmatch(p) do
    result[1+#result] = position
    count = count + 1
  end
  if #result == 0 then return nil, 0 end
  return result, count
end

local lua_keyword = {
  i = { -- keywords that may generate infinite loops
    "goto", "while", "repeat", "until", "in", "function", '::label::', },
  l = { -- keywords found in a limited loop
    "for", "break", },
  v = { -- keywords that are value literal
    "nil", "false", "true", },
  b = { -- keywords that generate branched execution
    "do", "end", "if", "then", "elseif", "else", },
  o = { -- keywords that are operators
    "and", "or", "not", },
  s = { -- Special symbols
    ';','{','}', '[',']', ',','...','(',')', ':', '.',
    '=','+','-','*','/','//','^','%', '&','~','|','>>','<<', '..',
    '<','<=','>','>=','==','~=', '-','#', },
}

-- local load = load

local search_pattern

local function searchluakeyword( luaStr, optionStr--[[, chunknameStr, envTab]] ) --> keywordTab
  if not optionStr then optionStr = 'ilvbo' end
  local keywordTab = {}

  if not lua_keyword_ready then
    search_pattern = {}
    for t, m in pairs(lua_keyword) do
      for _, k in pairs(m) do
        if k:match('^%a') then
          search_pattern[k] = '()%f[%a%d_]'..k..'%f[^%a%d_]'
        elseif #k == 1 then
          search_pattern[k] = '()%f[=~<>%'..k..']'..k:gsub('(.)','%%%1')..'%f[^=~<>%'..k..']'
        else
          search_pattern[k] = '()%f[%'..k:sub(1,1)..']'..k:gsub('(.)','%%%1')..'%f[^%'..k:sub(-1,-1)..']'
        end
      end
    end
    search_pattern['::label::'] = '()%f[:]::%a-::%f[^:]'
  end

  -- local exec, err = load( luaStr, chunknameStr, 't', envTab )
  -- if not exec then exec = err end

  luaStr = mask_fake_keyword( luaStr )

  local count, c = 0, 0
  for t, m in pairs(lua_keyword) do
    if optionStr:find(t) then
      for _, k in pairs(m) do
        keywordTab[k], c = first_capture_list( luaStr, search_pattern[k] )
        count = count + c
      end
    end
  end

  return keywordTab, count --, exec
end

return searchluakeyword