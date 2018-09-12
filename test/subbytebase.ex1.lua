local subbytebase = require 'subbytebase'
local t = require 'testhelper'

t( subbytebase(6,''       ) , ''         , t.bytesame )
t( subbytebase(6,'a'      ) , 'YQ=='     , t.bytesame )
t( subbytebase(6,'aa'     ) , 'YWE='     , t.bytesame )
t( subbytebase(6,'aaa'    ) , 'YWFh'     , t.bytesame )
t( subbytebase(6,'aaaa'   ) , 'YWFhYQ==' , t.bytesame )
t( subbytebase(6,'aaaaa'  ) , 'YWFhYWE=' , t.bytesame )
t( subbytebase(6,'aaaaaa' ) , 'YWFhYWFh' , t.bytesame )

t( subbytebase(-6, ''        ) , ''       , t.bytesame )
t( subbytebase(-6, 'YQ=='    ) , 'a'      , t.bytesame )
t( subbytebase(-6, 'YWE='    ) , 'aa'     , t.bytesame )
t( subbytebase(-6, 'YWFh'    ) , 'aaa'    , t.bytesame )
t( subbytebase(-6, 'YWFhYQ==') , 'aaaa'   , t.bytesame )
t( subbytebase(-6, 'YWFhYWE=') , 'aaaaa'  , t.bytesame )
t( subbytebase(-6, 'YWFhYWFh') , 'aaaaaa' , t.bytesame )

t( subbytebase(1,  'hi' ),               '0110100001101001', t.bytesame )
t( subbytebase(-1, '0110100001101001' ), 'hi',               t.bytesame )

t( subbytebase(2,  'hi'   ),     '12201221', t.bytesame )
t( subbytebase(-2, '12201221' ), 'hi',   t.bytesame )

t( subbytebase(3,  'hi' ),      '320644=', t.bytesame )
t( subbytebase(-3, '320644=' ), 'hi',   t.bytesame )

t( subbytebase(4,  'hi' ),   '6869', t.bytesame )
t( subbytebase(-4, '6869' ), 'hi',   t.bytesame )

t( subbytebase(5,  'hi' ),      'D1MG===', t.bytesame )
t( subbytebase(-5, 'D1MG===' ), 'hi',   t.bytesame )

t( subbytebase(6,  'hi' ),   'aGk=', t.bytesame )
t( subbytebase(-6, 'aGk=' ), 'hi',   t.bytesame )

t( subbytebase(7,  '\xFF' ),           '\x7F\x40======', t.bytesame )
t( subbytebase(-7, '\x7F\x40======' ), '\xFF',   t.bytesame )

t( subbytebase(8,  'hi' ), 'hi', t.bytesame )
t( subbytebase(-8, 'hi' ), 'hi',   t.bytesame )

t()

