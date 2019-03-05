--[===[DOC

= Utility script

The main use for this script is to propagate all the change to a LuaSnip module
to any other module that depends on that. The same mechanism is also used to
update all the documentation or generate the amalgamation of all the modules,
that can be found in `tool\luasnip.lua`.

Moreover it can run the test suites.

When called without any arguments, all the utility will be run in an
appropriate order.

== Test suite

Each module came with one ore more test files named
`test/module.ex1.lua`, `test/module.ex2.lua` and so on. Moreover,
in the module documentation there are example tests.

The output of each test is in the TAP format. you can use the
`luasniputility.lua` with `test` argument to automatically run all the test and
count how many fails you get. This script uses the `modules.txt` to decide
hich test to run, or alternatively you can pass the name of a single module to
run all the tests of that module.

When making changes to a source file, make sure to run the
<<Injection utility>> before to re-run the tests. It will copy the changes
where they are needed.

If you pass the single argument `amalgam` to the script, then all the tests
will be run but using the single amalgamated `luasnip.lua` file generated by
the <<Injection utility>>.

== Injection utility

LuaSnip modules files do not need one each other. This could be obtained
removing any code dependency. However, when this is not possible, LuaSnip
policy is to copy the code of the dependency module wherever it is needed.

This is automatically done by `luasniputil` when passing the `generate` command
line option. If no other arguments are presetn it will propagate any change in
the sources and in the documentation.

Be careful, it update the source/documentation IN-PLACE, so it is recomanded to
take a backup of any changes before running it.

In the source of this utility there is a list of Luasnip modules. So, if for
example a module is added, a line must be added into the source.

In the source/documentation, the injected code is placed between two tags. When
this tool is run all the text between this tags are deleted and substituted
with the text into the referred file. So any change between two of this tags
are lost. The correct way to proceede is making the change into the referred
file.

The tags are like `[SNIP:module.lua[` and `]SNIP:module.lua]`, and
must be prepended with the comment line sequence, i.e. `--` for lua files and
`//` for asciidoc. For example in the source code you can find:

```
-- [SNIP:module.lua[

Referred Source Code for module named 'module'

-- ]SNIP:module.lua]
```

To add a new dependency in a module, just place the two tags without any content,
then run the inject utility. It will insert the referred code.

Note: this tools generate also the global `src/luasnip.lua`; in this case no
expansion is performed: it just overwrite all the contents with the new
generated code.

]===]

-----------------------------------------------

local exit_code = 0

local modules = [[
 module  ; appendfile ; fs
 module  ; argcheck ; type
 module  ; bitpad  ; parse
 module  ; clearfile  ; fs
 module  ; cliparse  ; cli
 module  ; combinetab  ; tab
 module  ; copyfile   ; fs
 module  ; countiter  ; iter
 module  ; csvish     ; parse
 module  ; csvishout  ; parse
 module  ; deepsame  ; tab
 module  ; differencetab  ; tab
 module  ; escapeshellarg ; cli
 module  ; filenamesplit  ; fs
 module  ; flatarray  ; tab
 module  ; hexdecode  ; parse
 module  ; hexencode  ; parse
 module  ; intern     ; type
 module  ; intersecationtab  ; tab
 module  ; iscallable ; type
 module  ; isreadable ; fs
 module  ; jsonish    ; parse
 module  ; jsonishout ; parse
 module  ; keysort ; iter
 module  ; lambda ; parse
 module  ; localbind  ; deb
 module  ; locktable  ; tab
 module  ; logline    ; deb
 module  ; pathpart  ; fs
 module  ; rawhtml  ; parse
 module  ; rawmark    ; parse
 module  ; readfile  ; fs
 module  ; searchluakeyword  ; str
 module  ; serialize  ; str
 module  ; sha2       ; str
 module  ; shellcommand  ; cli
 module  ; stepdebug  ; deb
 module  ; subbytebase  ; parse
 module  ; tapfail  ; deb
 module  ; taptest    ; deb
 module  ; templua    ; parse
 module  ; timeprof ; deb
 module  ; toposort  ; tab
 module  ; trimstring  ; str
 module  ; tuple      ; type
 module  ; uniontab  ; tab
 module  ; valueprint ; deb
 module  ; object ; type
 module  ; factory ; type
 module  ; measure ; math
 module  ; clone ; tab
 module  ; datestd ; parse
 module  ; lineposition ; str

 internal  ; testhelper.lua  ; test/
 
 tool  ; climint.lua ; tool
 tool  ; debugger_stdinout.lua ; tool
 tool  ; luasniputil.lua ; tool
 tool  ; playground.lua ; tool

 doc ; documentation
]]
 
-----------------------------------------------

local LUA = 'lua'

local lsfolder
local min, max = 0, 0
for a = 0, #arg do
  local x = arg[a]:find('luasniputil%.lua$')
  if x then
    lsfolder = arg[a]:sub(1, x-1)
    if lsfolder == '' or lsfolder == './' or not lsfolder:match('[^/\\]') then
      lsfolder = '..'
      break
    end
    lsfolder = lsfolder:gsub('[^/\\]*[/\\]*$', '')
    if lsfolder == '' then
      lsfolder = '.'
    end
    break
  end
end

if not lsfolder then
  error('can not extract luasnip directory from the command line')
end

local function lspath( name )
  return lsfolder .. '/' .. name
end

local function toolpath( name )
  return lspath( 'tool/' .. name )
end

local function sourcepath( name )
  return lspath( 'src/' .. name )
end

local function examplepath( name )
  return lspath( 'test/' .. name )
end

local function docpath( name )
  return lspath( name )
end

-----------------------------------------------

local tablemove = table.move
if not tablemove then
  tablemove = function(a1, f, e, t, a2)
    if not a2 then a2 = a1 end
    for i = f, e do
      a2[t+i-f] = a1[i]
    end
  end
end

local function tablemerge(...)
  local toret = {}
  for t = 1, select('#', ...) do
    local tab = select(t, ...)
    tablemove(tab, 1, #tab, #toret+1, toret)
  end
  return toret
end

local function tablesub(t,s,e)
  local toret = {}
  tablemove(t,s,e,1,toret)
  return toret
end

local function trimstring(str)
  str = str:gsub('^[ \t\n\r]*','')
  str = str:gsub('[ \t\n\r]*$','')
  return str
end

local function snipsplit(str, tag_prefix, tag_suffix)

  tag_prefix = tag_prefix or ''
  tag_suffix = tag_suffix or ''
  local tag_pattern = ''
    .. '(' .. tag_prefix .. '%[SNIP:)([%a%d/%._]*)(%[' .. tag_suffix .. ')'
    .. '(.-)'
    .. '(' .. tag_prefix .. '%]SNIP:)%2(%]' .. tag_suffix .. ')'

  local result = {}
  local offset = 1
  while true do
      local s, e, Ta, t, Tb, d, Tc, Td = str:find(tag_pattern, offset)
      if s == nil then
          if #str > 0 then result[1+#result] = str:sub(offset) end
          break
      else
          if s > offset then result[1+#result] = str:sub(offset,s-1) end
          result[1+#result] = {tag=t, Ta..t..Tb, d, Tc..t..Td}
      end
      offset = e+1
  end
  return result
end

---------------------------------------------------------------------

-- simple static generator

local cache_new = {{name='bootstrap'}}
local cache = {}

local function in_cache(name, data)

  local c = cache[name] or cache_new[name]
  if c then
    if data == nil then return c end
    if data ~= c then
      error("A different data is already cached as '"..name.."'", 2)
    end
  end
  if data == nil then data = {} end

  data.name = name
  cache_new[1+#cache_new] = data
  cache_new[name] = data

  return data
end

local function update_cache()
  for _, data in ipairs(cache_new) do
    cache[1+#cache] = data
    cache[data.name] = data
  end
  cache_new = {}
end

local function apply(f)
  update_cache()
  local ents = cache
  while true do
    local postpone = {}
    local npp = #ents
    for _, v in ipairs(ents) do
      local status = f(v)
      if status == 'postpone' then
        postpone[1+#postpone] = v
      end
    end
    if #postpone == 0 then break end
    if #postpone == npp then
      local err = ''
      for _, v in ipairs(postpone) do
        err = v.name .. '\n'
      end
      error("Processing loop detected\n"..err,2)
    end
    ents = postpone
  end 
end

---------------------------------------------------------------------

local function load_file_content(ent)
  if ent.onfile then
    local path = ent.name
    if type(ent.onfile) == 'string' then
      path = ent.onfile
    end
    ent.content = (io.open(path, 'r')):read('*a')
  end
end

local function cut_lua_documentation(ent)
  if not ent.content then return end 
  local name = ent.name
  local content = ent.content
  local docstart, docend = content:find('^[\n\r\t ]*%-%-%[(=*)%[DOC.-]%1]')
  if docstart then
    ent.documentation = trimstring(content:sub(docstart,docend))
    ent.content = '\n'..trimstring(content:sub(docend+1))..'\n'
  end
end

local function split_content_pieces(ent)
  local c = ent.content
  if c and not ent.content_pieces then
    if ent.tolink then
      ent.content_pieces = snipsplit(c, ent.tag_prefix)
    else
      ent.content_pieces = {c}
    end
  end
end

local function extract_module_core(ent)
  if ent.content_pieces then
    ent.content_core = ''
    for _, v in pairs(ent.content_pieces) do
      if type(v) ~= 'table' then
        ent.content_core = ent.content_core .. v
      end
    end
    ent.content_core = ent.content_core:gsub('local%s-[^%s]-%s-=%s-%(%s-function%s-%(%s-%)%s-%s-end%s-%)%s-%(%s-%)','')
  end
end

local function generate_collection(ent)
  if ent.in_collection then
    local c = in_cache('collection_'..ent.in_collection)
    if not c.collection then c.collection = {} end
    c.collection[1+#c.collection] = ent
  end
end

local function generate_section_link(ent)
  if ent.collection then
    local secname = ''
    local n = ent.name:match('^collection_function_(%a*)$')
    if n then
      secname = 'function_index_section_'..n
    else
      secname = 'tool_index_section'
      n = ent.name:match('^collection_tool$')
    end
    if n then
      local newent = {}
      newent.content_pieces = {'\n'}
      table.sort(ent.collection,function(a,b)return a.name<b.name end)
      local first = true
      for _, i in ipairs(ent.collection) do
        if first then
          first = false
        else
          newent.content_pieces[1+#newent.content_pieces] = ', '
        end
        local link = i.name:gsub('%..*','')
        newent.content_pieces[1+#newent.content_pieces] = '<<' .. link ..','..i.documentation:match('[\n\r]=([^\n\r]*)') .. '>>'
      end
      newent.content_pieces[1+#newent.content_pieces] = '\n'
      in_cache(secname, newent)
    end
  end
end
  
local function generate_documentation(ent)
  -- Generate module and tool documentation
  local col = ent.in_collection
  if ent.onfile and col and (col == 'tool' or col:match('^function_.*')) then -- TODO : better check ?
    local n = 'function_reference'
    if ent.in_collection == 'tool' then
      n = 'tool_reference'
    end
    local d = in_cache(n)

    local _, cd = '', ''
    if ent.documentation then
      _, cd = ent.documentation:match('^[\n\r\t ]*%-%-%[(=*)%[DOC(.-)]%1]')
      cd = cd:gsub('([\n\r])(=[^\n\r])','%1==%2')
      cd = trimstring(cd)
    end

    local title, content = cd:match('^([^\n\r]*)(.*)$')
    title = trimstring(title)
    content = trimstring(content)

    local link
    if ent.in_collection == 'tool' then
      link = 'Return to <<tool_rendez_vous,tool>>' -- TODO : do not hard-code !!!
    else
      link = 'Return to <<reference_rendez_vous,Module index>>' -- TODO : do not hard-code !!!
    end

    local c = d.content_pieces

    c[1+#c] = '\n\n[#'.. ent.name:gsub('%..*','') ..']\n'
    c[1+#c] = link .. '\n'
    c[1+#c] = '\n' .. title .. '\n'
    c[1+#c] = '\n'..content..'\n'
    if ent.in_collection ~= 'tool' then
      c[1+#c] = '\n==== Code\n\n[source,lua]'
      c[1+#c] = '\n------------'
      c[1+#c] = {tag=ent.name, '', '', ''}
      ent.skip_tag = true -- TODO : avoid the skip_tag trick !!!
      c[1+#c] = '\n------------\n'
    end
  end
end

local function snippet_link(ent)
  if not ent.content_pieces then return end
  local linked = {}
  for k, v in ipairs(ent.content_pieces) do
    if type(v) ~= 'table' then
      linked[1+#linked] = v
    else
      linked[1+#linked] = v[1]
      local d = in_cache(v.tag)
      if not d then error("Can not find entity '"..v.tag.."'",1) end
      for _, k in pairs(d.content_pieces) do -- postpone if dependency not linked yet
        if type(k) == 'table' then
          return 'postpone'
        end
      end
      local si = 1+#linked
      for _, l in ipairs(d.content_pieces) do
        linked[1+#linked] = l
      end
      linked[1+#linked] = v[3]
    end
  end
  ent.content_pieces = linked
end


local function merge_content_pieces(ent)
  -- TODO : remove ? use ent.content both as single piece or multiple chunks
  if ent.content_pieces then
    ent.content = table.concat(ent.content_pieces)
  end
end

local function generate_amalgamation(ent)
  local amalgamation = in_cache('luasnip_embed')
  if amalgamation.body == nil then
    amalgamation.content = ''
    amalgamation.body = ''
    amalgamation.tail = ''
    local h = ''
    h=h.. '--[===[ LuaSnip - License\n\n'
    h=h.. (in_cache('COPYING.txt').content or '')
    h=h.. '\n\n]===]\n\n'
    amalgamation.head = h
  end
  if not ent.toamalgam then return end
  local piece = ent.content_core
  if not piece then return end
  local id = ent.name:gsub('%..*$','')
  local full = amalgamation.body
  full = full .. '\n' .. id .. ' = (function()\n\n' .. piece .. '\n\nend)()\n'
  amalgamation.body = full
  amalgamation.head = amalgamation.head .. 'local ' .. id .. ';\n'
  amalgamation.tail = amalgamation.tail .. '  ' .. id .. ' = ' .. id .. ',\n'
  amalgamation.content = amalgamation.head .. amalgamation.body .. '\nreturn {\n' .. amalgamation.tail .. '}'
end

local function save_content(ent)
  if ent.onfile and not ent.readonly then
    local path = ent.name
    if type(ent.onfile) == 'string' then
      path = ent.onfile
    end
    print('GENERATING '..path)
    local f = io.open(path,'wb')
    if ent.documentation then f:write(ent.documentation,'\n') end
    f:write(ent.content or '')
    f:close()
  end
end
  
local function generate_main()

  -- TODO : remove extension from entity names

  -- Generate initial entry list
  apply(function(ent)
    if ent.name == 'bootstrap' then
      for l in modules:gmatch('[^\n\r][^\n\r]*') do
        local rec = {}
        for k in l:gmatch('([^ \t\n;]*)') do if k ~= '' then
          rec[1+#rec] = k
        end end
        local t, n = rec[1], rec[2]
        if t and n then 
          local newent = {}
          if t == 'info' then
            n = n
            newent.onfile = lspath(n)
            newent.readonly = true
          end
          if t == 'doc' then
            n = n..'.adoc'
            newent.onfile = docpath(n)
            newent.tolink = true
            newent.tag_prefix = '// '
          end
          if t == 'tool' then
            newent.in_collection = 'tool'
            newent.onfile = toolpath(n)
            newent.readonly = true
          end
          if t == 'internal' then
            newent.tolink = true
            newent.onfile = lspath(rec[3]..'/'..n)
            --newent.readonly = true
            newent.tag_prefix = '%-%- '
          end
          if t == 'module' then
            n = n..'.lua'
            newent.in_collection = 'function_' .. rec[3]
            newent.onfile = sourcepath(n)
            newent.tolink = true
            newent.toamalgam = true
            newent.searchexample = true
            newent.tag_prefix = '%-%- '
          end
          in_cache(n, newent)
        end
      end
    end
  end)

  -- TODO : put in the module description string
  in_cache('luasnip_embed',{onfile=toolpath('luasnip.lua'),tag_prefix='%-%- ',skip_tag=true})
  in_cache('htmltool',{onfile = toolpath('playground.html'),tolink=true,tag_prefix='-- '})

  apply(load_file_content)
  apply(cut_lua_documentation)
  apply(split_content_pieces)
  apply(extract_module_core)

  -- Temporary empty references for the documentation
  in_cache('function_reference',{content='\n',content_pieces={'\n'}})
  in_cache('tool_reference',{content='\n',content_pieces={'\n'}})

  apply(generate_collection)
  apply(generate_section_link)
  apply(generate_documentation)
  apply(snippet_link)
  apply(merge_content_pieces)
  apply(generate_amalgamation)
  apply(save_content)

end

------------------------------------------------------------------------

-- TODO : CLEAN UP THE REST. IT IS A MESS !!!

local function trimstring(str)
  str = str:gsub('^[ \t\n\r]*','')
  str = str:gsub('[ \t\n\r]*$','')
  return str
end

local function load_module_list()
  local parsed = {}
  for l in modules:gmatch('[^\n\r][^\n\r]*')  do

    local i = 0
    local p = {}
    for k in l:gmatch('([^ \t\n;]*)') do if k ~= '' then
      i = i + 1
      k = k:gsub('[^%g ]','')
      k = trimstring(k)
      if     1 == i then p.type = k
      elseif 2 == i then p.name = k
      elseif 3 == i then p.tag = {k}
      else p.tag[1+#(p.tag)] = k
      end
    end end
    if i > 0 and p.type == 'module' then parsed[1+#parsed] = p.name end
  end
  return parsed
end

local function load_example_list(module)
  local result = {}
  for _,m in pairs(module) do
    local i = 0
    while true do
      i = i + 1
      local testfile = lspath('test/'..m..'.ex'..i..'.lua')
      local f, err = io.open( testfile, 'rb' )
      if not f or err then break end
      f:close()
      result[1+#result] = testfile
    end
    if i < 2 then error('No test files found for the module "'..m..'"') end
  end
  return result
end

local module
local failed = false

local function tapfail(line, inf)
  if not failed then
    failed = {}
  end
  failed[1+#failed] = inf .. ' >> ' .. line
  print('===> FAILED '..inf)
end

local function tapvalid(path)
  local f, err = io.open( path, 'rb' )
  if not f or err then error() end
  local last
  while true do
    local line = f:read('*l')
    if not line then break end

    print(line)

    if last then
      tapfail(line, '[line after summary]')
      goto CONTINUE
    end

    local ok = line:match('^ok')
    local diag = line:match('^#')
    last = line:match('^1%.%.')

    if not ok and not diag and not last then
      tapfail(line, '[no diagnostic or ok line]')
      goto CONTINUE
    end

    ::CONTINUE::
  end

  if not last then
    tapfail(line, '[summary missing]')
  end

  f:close()
end

local function test_main( arg )

  local pre_lua = ''
  if #arg > 0 and arg[1] == 'amalgam' then
    pre_lua = ' -e "package.path=package.path..[[;'..toolpath('')..'/?.lua]] local x=require[[luasnip]] for k,v in pairs(x)do package.loaded[k]=v end;" '
    module = load_module_list()
  elseif #arg > 0 then
    module = { arg[1] }
  else
    module = load_module_list()
  end

  local example = load_example_list(module)

  local suite_count = 0
  for _,e in pairs(example) do
    suite_count = suite_count + 1
    print("-----------------------------------")
    print(e)
    print("-----------------------------------")
    os.execute( LUA .. ' ' .. pre_lua .. ' ' .. e .. ' > tmp_out.txt 2>&1 ')
    tapvalid('tmp_out.txt')
    print("-----------------------------------")
  end

  print('==========================')
  print(suite_count..' test suites were run')
  print('==========================')
  if not failed then
    print("ALL IS RIGHT")
  else
    print("SOME TEST FAILED")
  end
end

---------------------------------------------------------------------------

local function main()

  LUA = [[ -e "package.path=package.path.. ';test/?.lua;src/?.lua;'" ]]

  do
    local i = 0
    while true do
      if arg[i] == nil then break end
      i = i - 1
    end
    LUA = arg[i+1] .. LUA
  end

  local util = arg[1]
  local ARG = {}
  for i=2,#arg do ARG[1+#ARG] = arg[i] end
  arg = nil
  if util == 'generate' then
    generate_main( ARG )
  elseif util == 'test' then
    test_main( ARG )
  else
    generate_main( {'generate'} )
    test_main( {} )
    local f = failed
    test_main( {'amalgam'} )
    if not failed and not f then
      print("ALL IS RIGHT")
    else
      for _,l in ipairs(f) do
        print("Failure in single module: "..l)
      end
      if f then print("single module failed") end
      if failed then print("amalgamation failed") end
      print("SOME TEST FAILED")
      exit_code = -1
    end
  end
end

main()
os.exit(exit_code)

