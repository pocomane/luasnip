--[===[DOC

= rawhtml

[source,lua]
----
function rawhtml( htmlStr ) --> rawmarkStr
----

This function, togheter with `rawmark`, allows the parsing of html-like data.

Infact, you can use this function to trasfrom the `htmlStr` string, containint
html data, into the `rawmarkStr` string. This result can be oarsed with the
<<rawmark>> module.

No html validation is performed and actually the syntax is more permissive than
the html one.

The attribute of each tag is not parsed, but stored verbatim in the first
sub-tag with the "attribute" type.

== Example

[source,lua,example]
----
local rawhtml = require 'rawhtml'

assert( rawhtml'<!--@{}--><div my-attr="hi">x< b  />y<div>bla</div></div>'
  == '@=comment={{=}{+}{-}}@div{@=attribute={my-attr="hi"}x@b{}y@div{bla}}' )
----

]===]

local function rawhtml( inStr ) --> outStr
  if inStr == '' then return '' end
  local outStr = inStr
  outStr = outStr:gsub('([{@}])',{['{']='{+}',['}']='{-}',['@']='{=}' })
  outStr = outStr:gsub('<!%-%-','@=comment={')
  outStr = outStr:gsub('%-%->','}')
  outStr = outStr:gsub('<(/?)([^>]-)(/?)>',function(p,a,s)
    a = a:gsub('^[ \t]*(.-)[ \t]*$','%1')
    local a, b = a:match('^([^ \t]*)(.*)$')
    if p == '/' then return '}' end
    if s == '/' then s = '}' end
    if b and b ~= '' then
      b = b:gsub('^[ \t]*(.-)[ \t]*$','%1')
      b = '@=attribute={'..b..'}'
    end
    return '@'..a..'{'..b..s

  end)
  return outStr
end

return rawhtml
