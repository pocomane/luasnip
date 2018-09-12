local sha2 = require 'sha2'
local t = require 'testhelper'

t( sha2( "Hello world!" ), "C0535E4BE2B79FFD93291305436BF889314E4A3FAEC05ECFFCBB7DF31AD9E51A", t.hexsame )

t( sha2( '' ), "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", t.hexsame )
t( sha2(( "a" ):rep( 1   )), "CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB", t.hexsame )
t( sha2(( "b" ):rep( 63  )), "94E419FABAC7F930810F9636354042F8C1426D2F834D4AB65C93DC1E69326B13", t.hexsame )
t( sha2(( "c" ):rep( 64  )), "52B6419D27BD7F547CEE3B92F8C17A908B8A49601ECBEC161E5030DE1DFE9E0A", t.hexsame )
t( sha2(( "d" ):rep( 65  )), "899987F295364060C6ABD752A7E895124B467FD7CF56B52CE22F4A684A5723F4", t.hexsame )
t( sha2(( "e" ):rep( 130 )), "C78A24F98CC9596CAFD6FC954A0664CA5CAD156AD406A8CC246B5E1F56864DB7", t.hexsame )

t( sha2(( "\xFF" ), 1), "B9DEBF7D52F36E6468A54817C1FA071166C3A63D384850E1575B42F702DC5AA1", t.hexsame )
t( sha2(( "\x00" ), 1), "BD4F9E98BEB68C6EAD3243B1B4C7FED75FA4FEAAB1F84795CBD8A98676A2A375", t.hexsame )
t( sha2(( "a" ):rep( 70 ), 69*8+1), "056ECB5B2DB796F0E49B5A7F3010C5DB3ECA6E87E03EB45F4E618F4867D002A9", t.hexsame )
t( sha2(( "a" ):rep( 70 ), 69*8+2), "0926C28F521555DB93892916F22414353234FCAB237AC5DC3AE6FA41A51BE15B", t.hexsame )
t( sha2(( "a" ):rep( 70 ), 69*8+7), "6759507E5A185A774D2C980067B4451671AA70705A35080779AAA6D3CEAA00FC", t.hexsame )

local function sha256(x,y) return sha2( x, y, 256 ) end
local function sha224(x,y) return sha2( x, y, 224 ) end
local function sha512(x,y) return sha2( x, y, 512 ) end
local function sha384(x,y) return sha2( x, y, 384 ) end

t( sha256( "Hello world!" ), "C0535E4BE2B79FFD93291305436BF889314E4A3FAEC05ECFFCBB7DF31AD9E51A", t.hexsame )
t( sha224( "Hello world!" ), "7E81EBE9E604A0C97FEF0E4CFE71F9BA0ECBA13332BDE953AD1C66E4", t.hexsame )
t( sha512( "Hello world!" ), "F6CDE2A0F819314CDDE55FC227D8D7DAE3D28CC556222A0A8AD66D91CCAD4AAD6094F517A2182360C9AACF6A3DC323162CB6FD8CDFFEDB0FE038F55E85FFB5B6", t.hexsame )
t( sha384( "Hello world!" ), "86255FA2C36E4B30969EAE17DC34C772CBEBDFC58B58403900BE87614EB1A34B8780263F255EB5E65CA9BBB8641CCCFE", t.hexsame )

t( sha256( '' ), "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", t.hexsame )
t( sha256(( "a" ):rep( 1   )), "CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB", t.hexsame )
t( sha256(( "b" ):rep( 63  )), "94E419FABAC7F930810F9636354042F8C1426D2F834D4AB65C93DC1E69326B13", t.hexsame )
t( sha256(( "c" ):rep( 64  )), "52B6419D27BD7F547CEE3B92F8C17A908B8A49601ECBEC161E5030DE1DFE9E0A", t.hexsame )
t( sha256(( "d" ):rep( 65  )), "899987F295364060C6ABD752A7E895124B467FD7CF56B52CE22F4A684A5723F4", t.hexsame )
t( sha256(( "e" ):rep( 130 )), "C78A24F98CC9596CAFD6FC954A0664CA5CAD156AD406A8CC246B5E1F56864DB7", t.hexsame )

t( sha512( '' ), "CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D0D13C5D85F2B0FF8318D2877EEC2F63B931BD47417A81A538327AF927DA3E", t.hexsame )
t( sha512(( "a" ):rep( 1   )), "1F40FC92DA241694750979EE6CF582F2D5D7D28E18335DE05ABC54D0560E0F5302860C652BF08D560252AA5E74210546F369FBBBCE8C12CFC7957B2652FE9A75", t.hexsame )
t( sha512(( "b" ):rep( 127 )), "1FB5054735807A95088312066BDD2ACEC2EB8F65454BF77873CDF93998F79C75FC0F229AB4A8FFE0BFD5310A3357272ADCECB378D1F310EE43ED4A0634C6E5B8", t.hexsame )
t( sha512(( "c" ):rep( 128 )), "1CADAE2171FD051AA72F31D7D11D232D867E9823E0DA1FAB3F40288C46C009ABA8A378454514FA6756D00C1037FFBC32B3716DF881569C545A2E190CE426C79B", t.hexsame )
t( sha512(( "d" ):rep( 129 )), "30E54405DCC986AE90F830E01FC144190FF756EFD6E7E9FE4BDF9D6416B54C63E5CE18BFCE172DC360436052DB834A37317D0E2085FAF11E3C69A59020CDD8FC", t.hexsame )
t( sha512(( "e" ):rep( 300 )), "C2202F2BC948039340224757BF24A0B59A24737A3083DF9A8DD062AB7A0717147E025FDAB38CFC5DED56B3E8AC8072D87457AFA143DBD4F26ACF4CB26BB35266", t.hexsame )

t()
