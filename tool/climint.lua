
--[===[DOC

= Template expander

It is a command line template system. The template code is lua. For full
documentation, run without arguments. It will generate `out.html` containing
the manual.

It uses <<templua>> to expand the template and <<cliparse>> to parse the
command line arguments. With <<uniontab>> in your template, you can provide
default arguments.

]===]

local LS = require 'luasnip'

local template_cache = {}

local function template_cache_set( path, content )
  template_cache[path], err = LS.templua(content)
  if err then return error(err) end
end

local function sandbox_prepare( sandbox, arg )

  function sandbox.INCLUDE(path)
    local template = template_cache[path]
    if not template then
      local content, err = LS.readfile(path)
      if err then return error(err) end
      template_cache_set( path, content )
      template = template_cache[path]
    end
    local result, err = template(sandbox)
    if err then return error('ERROR loading file "'..path..'":\n'..err) end
    return result
  end

  local opt = LS.cliparse( arg, 'filelist' )
  opt = LS.uniontab( opt, {
    template = {''},
    exepath =  arg[0],
    felist =   {},
  })

  sandbox.filename = function(...) local _,f = LS.filenamesplit(...)  return f end
  for k, v in pairs(opt) do sandbox[k] = v end
  sandbox.clicheck = function( t ) return clicheck( sandbox, t ) end
  
  sandbox.luacommon = {'pairs', 'string', 'tonumber', 'tostring', 'type', 'math',
    'require', --[[ TODO : REMOVE ??? ]]
  }

  local env = _ENV
  if not _ENV then
    sandbox._ENV = sandbox
    env = getfenv()
  end
  for k, v in pairs(sandbox.luacommon) do sandbox[v] = env[v] end
end

local helptempl
local function main( )
  local sandbox = {}
  sandbox_prepare( sandbox, arg )
  local template_parser = sandbox.INCLUDE

  if sandbox.output then
    out = sandbox.output[1]
  else
    out = 'out.html'
  end

  local inp = sandbox.template[1]
  if inp == '' then
    template_cache_set( '', helptempl )
  end

  local result = template_parser(inp)

  LS.clearfile( out )
  LS.appendfile( out, result )

  print(out..' should be generated')
end

---------------------------------------------------------------------------

-- TODO : update the doc !!! specially: describe the 'INCLUDE' global !

helptempl = [[
<!doctype html>
<html>
<head>
  <title>climint manual</title>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>

html, body {
  width: 40em;
}

.code, .option {
  display: inline;
  font-style: italic;
}

.paragraph {
  margin: 0.7em 0; 
}

  </style>
</head>
<body>

<h1>
Description
</h1>

<div class="paragraph">
The <div class="code">@{filename(exepath)}</div> command let you to generate a document from a
template file.  The template will be read and some special expression will be
expanded.  Lua code can be written in these expression, and it will have access
to all the command line paramenter.
</div>

<h1>
Code expansion
</h1>

<div class="paragraph">
The followinx expression will be expanded in the template.
</div>

<div class="paragraph">
<div class='code'>@{"@"}{luaexp}</div> Will be substituted with the result of the Lua expression.
</div>

<div class="paragraph">
<div class='code'>@{"@"}{{luastm}}</div> Embeds the Lua statement. This allow to mix Lua code and verbatim
text.
</div>

<h1>
Command line parameters
</h1>

<div class="paragraph">
TODO : better explain parameter parsing and storing
</div>

<div class="paragraph">
The parameters will be parsed and stored in a lua table.
</div>

<div class="paragraph">
The only command line parameters that have a special meaning are "template" and
"output". With the former you can specify the template file (an internal one
will be used if missing). With the latter you can specify the output file
("out.html" will be used if missing).
</div>

<div class="paragraph">
Note: the parameter used for generating this manual are listed in the ""
Section. So you can use it to experiment with different command lines and see
how the parameters are handled.
</div>

<h1>
Lua code sandbox
</h1>

<div class="paragraph">
The following common lua functions are avaiable in the luacode: <div class='code'>
@{{
  for i = 1, #luacommon do
    if i~=1 then _o', ' end
    _o(luacommon[i])
  end
}}</div>. Moreover, the following utilities will be avaiable.
</div>

<div class="paragraph">
</div>

<div class="paragraph">
<div class='code'>_o(str)</div> it will emit the str in the output.  This is
useful to use in a big <div class="code">@{"@"}{{}}</div> lua code block. It
will be appended to the output exactly where the starting <div
class="code">@</div> was.
</div>

<div class="paragraph">
<div class='code'>filename(str)</div> extracts the name from a path-like string.
</div>

<div class="paragraph">
<div class='code'>clicheck(tab)</div> checks if the command line arguments described by the table tab are present. If not it will fill them with defaults. TODO : better explanation!.
</div>

<h1>
Command line parameter inspection
</h1>

<div class="paragraph">
The following option are passed (they may be defaults):
</div>

<div class='option'>
@{{
  for k, v in pairs(_ENV) do
    if 'string' == type(v) then
      _o"  " _o(k) _o" = " _o(v) _o", <br/>"
    elseif 'table' == type(v) then
      _o"  " _o(k) _o" = [ "
      for i = 1, #v do
        if 'string' == type(v[i]) then
          _o(v[i]) _o", "
        end
      end
      _o"], <br/>"
    end
  end
}}
</div>

</body>
</html>

]]

---------------------------------------------------------------------------

main()

