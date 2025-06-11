-- local deflate = require("LibDeflate")

-- This is a minified version of LibDeflate.lua from https://github.com/SafeteeWoW/LibDeflate/tree/main
-- Some world of warcraft specific parts were also removed before minimizing
-- Minifier used: https://luaobfuscator.com
local deflate, err = load([=======[
local v0;do v0={};v0._VERSION=_VERSION;v0._MAJOR=_MAJOR;v0._MINOR=_MINOR;v0._COPYRIGHT=_COPYRIGHT;end local v1=assert;local v2=error;local v3=pairs;local v4=string.byte;local v5=string.char;local v6=string.find;local v7=string.gsub;local v8=string.sub;local v9=table.concat;local v10=table.sort;local v11=tostring;local v12=type;local v13={};local v14={};local v15={};local v16={};local v17={};local v18={};local v19={};local v20={};local v21={};local v22={3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258};local v23={0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0};local v24={[0]=1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577};local v25={[0]=0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13};local v26={16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15};local v27;local v28;local v29;local v30;local v31;local v32;local v33;local v34;for v86=0,255 do v14[v86]=v5(v86);end do local v88=1;for v508=0,32 do v13[v508]=v88;v88=v88 * 2 ;end end for v89=1,9 do v15[v89]={};for v510=0,v13[v89 + 1 ] -1  do local v511=0;local v512=v510;for v664=1,v89 do v511=(v511-(v511%2)) + (((((v511%2)==1) or ((v512%2)==1)) and 1) or 0) ;v512=(v512-(v512%2))/2 ;v511=v511 * 2 ;end v15[v89][v510]=(v511-(v511%2))/2 ;end end do local v91=18;local v92=16;local v93=265;local v94=1;for v514=3,258 do if (v514<=10) then v16[v514]=v514 + 254 ;v18[v514]=0;elseif (v514==258) then v16[v514]=285;v18[v514]=0;else if (v514>v91) then v91=v91 + v92 ;v92=v92 * 2 ;v93=v93 + 4 ;v94=v94 + 1 ;end local v790=((v514-v91) -1) + (v92/2) ;v16[v514]=((v790-(v790%(v92/8)))/(v92/8)) + v93 ;v18[v514]=v94;v17[v514]=v790%(v92/8) ;end end end do v19[1]=0;v19[2]=1;v21[1]=0;v21[2]=0;local v99=3;local v100=4;local v101=2;local v102=0;for v515=3,256 do if (v515>v100) then v99=v99 * 2 ;v100=v100 * 2 ;v101=v101 + 2 ;v102=v102 + 1 ;end v19[v515]=((v515<=v99) and v101) or (v101 + 1) ;v21[v515]=((v102<0) and 0) or v102 ;if (v100>=8) then v20[v515]=((v515-(v100/2)) -1)%(v100/4) ;end end end v0.Adler32=function(v103,v104) if (v12(v104)~="string") then v2(("Usage: LibDeflate:Adler32(str):"   .. " 'str' - string expected got '%s'."):format(v12(v104)),2);end local v105= #v104;local v106=1;local v107=1;local v108=0;while v106<=(v105-15)  do local v518,v519,v520,v521,v522,v523,v524,v525,v526,v527,v528,v529,v530,v531,v532,v533=v4(v104,v106,v106 + 15 );v108=(v108 + (16 * v107) + (16 * v518) + (15 * v519) + (14 * v520) + (13 * v521) + (12 * v522) + (11 * v523) + (10 * v524) + (9 * v525) + (8 * v526) + (7 * v527) + (6 * v528) + (5 * v529) + (4 * v530) + (3 * v531) + (2 * v532) + v533)%65521 ;v107=(v107 + v518 + v519 + v520 + v521 + v522 + v523 + v524 + v525 + v526 + v527 + v528 + v529 + v530 + v531 + v532 + v533)%65521 ;v106=v106 + 16 ;end while v106<=v105  do local v534=v4(v104,v106,v106);v107=(v107 + v534)%65521 ;v108=(v108 + v107)%65521 ;v106=v106 + 1 ;end return ((v108 * 65536) + v107)%4294967296 ;end;local function v36(v109,v110) return (v109%4294967296)==(v110%4294967296) ;end v0.CreateDictionary=function(v111,v112,v113,v114) if (v12(v112)~="string") then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'str' - string expected got '%s'."):format(v12(v112)),2);end if (v12(v113)~="number") then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'strlen' - number expected got '%s'."):format(v12(v113)),2);end if (v12(v114)~="number") then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'adler32' - number expected got '%s'."):format(v12(v114)),2);end if (v113~= #v112) then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'strlen' does not match the actual length of 'str'."   .. " 'strlen': %u, '#str': %u ."   .. " Please check if 'str' is modified unintentionally."):format(v113, #v112));end if (v113==0) then v2("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'str' - Empty string is not allowed." ,2);end if (v113>32768) then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'str' - string longer than 32768 bytes is not allowed."   .. " Got %d bytes."):format(v113),2);end local v115=v111:Adler32(v112);if  not v36(v114,v115) then v2(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"   .. " 'adler32' does not match the actual adler32 of 'str'."   .. " 'adler32': %u, 'Adler32(str)': %u ."   .. " Please check if 'str' is modified unintentionally."):format(v114,v115));end local v116={};v116.adler32=v114;v116.hash_tables={};v116.string_table={};v116.strlen=v113;local v121=v116.string_table;local v122=v116.hash_tables;v121[1]=v4(v112,1,1);v121[2]=v4(v112,2,2);if (v113>=3) then local v665=1;local v666=(v121[1] * 256) + v121[2] ;while v665<=((v113-2) -3)  do local v700,v701,v702,v703=v4(v112,v665 + 2 ,v665 + 5 );v121[v665 + 2 ]=v700;v121[v665 + 3 ]=v701;v121[v665 + 4 ]=v702;v121[v665 + 5 ]=v703;v666=((v666 * 256) + v700)%16777216 ;local v708=v122[v666];if  not v708 then v708={};v122[v666]=v708;end v708[ #v708 + 1 ]=v665-v113 ;v665=v665 + 1 ;v666=((v666 * 256) + v701)%16777216 ;v708=v122[v666];if  not v708 then v708={};v122[v666]=v708;end v708[ #v708 + 1 ]=v665-v113 ;v665=v665 + 1 ;v666=((v666 * 256) + v702)%16777216 ;v708=v122[v666];if  not v708 then v708={};v122[v666]=v708;end v708[ #v708 + 1 ]=v665-v113 ;v665=v665 + 1 ;v666=((v666 * 256) + v703)%16777216 ;v708=v122[v666];if  not v708 then v708={};v122[v666]=v708;end v708[ #v708 + 1 ]=v665-v113 ;v665=v665 + 1 ;end while v665<=(v113-2)  do local v711=v4(v112,v665 + 2 );v121[v665 + 2 ]=v711;v666=((v666 * 256) + v711)%16777216 ;local v713=v122[v666];if  not v713 then v713={};v122[v666]=v713;end v713[ #v713 + 1 ]=v665-v113 ;v665=v665 + 1 ;end end return v116;end;local function v38(v125) if (v12(v125)~="table") then return false,("'dictionary' - table expected got '%s'."):format(v12(v125));end if ((v12(v125.adler32)~="number") or (v12(v125.string_table)~="table") or (v12(v125.strlen)~="number") or (v125.strlen<=0) or (v125.strlen>32768) or (v125.strlen~= #v125.string_table) or (v12(v125.hash_tables)~="table")) then return false,("'dictionary' - corrupted dictionary."):format(v12(v125));end return true,"";end local v39={[0]={false,nil,0,0,0},[1]={false,nil,4,8,4},[2]={false,nil,5,18,8},[3]={false,nil,6,32,32},[4]={true,4,4,16,16},[5]={true,8,16,32,32},[6]={true,8,16,128,128},[7]={true,8,32,128,256},[8]={true,32,128,258,1024},[9]={true,32,258,258,4096}};local function v40(v126,v127,v128,v129,v130) if (v12(v126)~="string") then return false,("'str' - string expected got '%s'."):format(v12(v126));end if v127 then local v667,v668=v38(v128);if  not v667 then return false,v668;end end if v129 then local v669=v12(v130);if ((v669~="nil") and (v669~="table")) then return false,("'configs' - nil or table expected got '%s'."):format(v12(v130));end if (v669=="table") then for v799,v800 in v3(v130) do if ((v799~="level") and (v799~="strategy")) then return false,("'configs' - unsupported table key in the configs: '%s'."):format(v799);elseif ((v799=="level") and  not v39[v800]) then return false,("'configs' - unsupported 'level': %s."):format(v11(v800));elseif ((v799=="strategy") and (v800~="fixed") and (v800~="huffman_only") and (v800~="dynamic")) then return false,("'configs' - unsupported 'strategy': '%s'."):format(v11(v800));end end end end return true,"";end local v41=0;local v42=1;local v43=2;local v44=3;local function v45() local v131=0;local v132=0;local v133=0;local v134=0;local v135={};local v136={};local function v137(v535,v536) v132=v132 + (v535 * v13[v133]) ;v133=v133 + v536 ;v134=v134 + v536 ;if (v133>=32) then v131=v131 + 1 ;v135[v131]=v14[v132%256 ]   .. v14[((v132-(v132%256))/256)%256 ]   .. v14[((v132-(v132%65536))/65536)%256 ]   .. v14[((v132-(v132%16777216))/16777216)%256 ] ;local v716=v13[(32 -v133) + v536 ];v132=(v535-(v535%v716))/v716 ;v133=v133-32 ;end end local function v138(v537) for v670=1,v133,8 do v131=v131 + 1 ;v135[v131]=v5(v132%256 );v132=(v132-(v132%256))/256 ;end v133=0;v131=v131 + 1 ;v135[v131]=v537;v134=v134 + ( #v537 * 8) ;end local function v139(v539) if (v539==v44) then return v134;end if ((v539==v42) or (v539==v43)) then local v717=(8 -(v133%8))%8 ;if (v133>0) then v132=(v132-v13[v133]) + v13[v133 + v717 ] ;for v861=1,v133,8 do v131=v131 + 1 ;v135[v131]=v14[v132%256 ];v132=(v132-(v132%256))/256 ;end v132=0;v133=0;end if (v539==v43) then v134=v134 + v717 ;return v134;end end local v540=v9(v135);v135={};v131=0;v136[ #v136 + 1 ]=v540;if (v539==v41) then return v134;else return v134,v9(v136);end end return v137,v138,v139;end local function v46(v140,v141,v142) v142=v142 + 1 ;v140[v142]=v141;local v144=v141[1];local v145=v142;local v146=(v145-(v145%2))/2 ;while (v146>=1) and (v140[v146][1]>v144)  do local v542=v140[v146];v140[v146]=v141;v140[v145]=v542;v145=v146;v146=(v146-(v146%2))/2 ;end end local function v47(v147,v148) local v149=v147[1];local v150=v147[v148];local v151=v150[1];v147[1]=v150;v147[v148]=v149;v148=v148-1 ;local v154=1;local v155=v154 * 2 ;local v156=v155 + 1 ;while v155<=v148  do local v545=v147[v155];if ((v156<=v148) and (v147[v156][1]<v545[1])) then local v718=v147[v156];if (v718[1]<v151) then v147[v156]=v150;v147[v154]=v718;v154=v156;v155=v154 * 2 ;v156=v155 + 1 ;else break;end elseif (v545[1]<v151) then v147[v155]=v150;v147[v154]=v545;v154=v155;v155=v154 * 2 ;v156=v155 + 1 ;else break;end end return v149;end local function v48(v157,v158,v159,v160) local v161=0;local v162={};local v163={};for v546=1,v160 do v161=(v161 + (v157[v546-1 ] or 0)) * 2 ;v162[v546]=v161;end for v548=0,v159 do local v549=v158[v548];if v549 then v161=v162[v549];v162[v549]=v161 + 1 ;if (v549<=9) then v163[v548]=v15[v549][v161];else local v807=0;for v864=1,v549 do v807=(v807-(v807%2)) + (((((v807%2)==1) or ((v161%2)==1)) and 1) or 0) ;v161=(v161-(v161%2))/2 ;v807=v807 * 2 ;end v163[v548]=(v807-(v807%2))/2 ;end end end return v163;end local function v49(v164,v165) return (v164[1]<v165[1]) or ((v164[1]==v165[1]) and (v164[2]<v165[2])) ;end local function v50(v166,v167,v168) local v169;local v170= -1;local v171={};local v172={};local v173={};local v174={};local v175={};local v176=0;for v550,v551 in v3(v166) do v176=v176 + 1 ;v171[v176]={v551,v550};end if (v176==0) then return {},{}, -1;elseif (v176==1) then local v763=v171[1][2];v173[v763]=1;v174[v763]=0;return v173,v174,v763;else v10(v171,v49);v169=v176;for v809=1,v169 do v172[v809]=v171[v809];end while v169>1  do local v812=v47(v172,v169);v169=v169-1 ;local v813=v47(v172,v169);v169=v169-1 ;local v814={v812[1] + v813[1] , -1,v812,v813};v46(v172,v814,v169);v169=v169 + 1 ;end local v766=0;local v767={v172[1],0,0,0};local v768=1;local v769=1;v172[1][1]=0;while v769<=v768  do local v815=v767[v769];local v816=v815[1];local v817=v815[2];local v818=v815[3];local v819=v815[4];if v818 then v768=v768 + 1 ;v767[v768]=v818;v818[1]=v816 + 1 ;end if v819 then v768=v768 + 1 ;v767[v768]=v819;v819[1]=v816 + 1 ;end v769=v769 + 1 ;if (v816>v167) then v766=v766 + 1 ;v816=v167;end if (v817>=0) then v173[v817]=v816;v170=((v817>v170) and v817) or v170 ;v175[v816]=(v175[v816] or 0) + 1 ;end end if (v766>0) then repeat local v885=v167-1 ;while (v175[v885] or 0)==0  do v885=v885-1 ;end v175[v885]=v175[v885] -1 ;v175[v885 + 1 ]=(v175[v885 + 1 ] or 0) + 2 ;v175[v167]=v175[v167] -1 ;v766=v766-2 ;until v766<=0  v769=1;for v889=v167,1, -1 do local v890=v175[v889] or 0 ;while v890>0  do local v901=v171[v769][2];v173[v901]=v889;v890=v890-1 ;v769=v769 + 1 ;end end end v174=v48(v175,v173,v168,v167);return v173,v174,v170;end end local function v51(v177,v178,v179,v180) local v181=0;local v182={};local v183={};local v184=0;local v185={};local v186=nil;local v187=0;v180=((v180<0) and 0) or v180 ;local v188=v178 + v180 + 1 ;for v553=0,v188 + 1  do local v554=((v553<=v178) and (v177[v553] or 0)) or ((v553<=v188) and (v179[(v553-v178) -1 ] or 0)) or nil ;if (v554==v186) then v187=v187 + 1 ;if ((v554~=0) and (v187==6)) then v181=v181 + 1 ;v182[v181]=16;v184=v184 + 1 ;v185[v184]=3;v183[16]=(v183[16] or 0) + 1 ;v187=0;elseif ((v554==0) and (v187==138)) then v181=v181 + 1 ;v182[v181]=18;v184=v184 + 1 ;v185[v184]=127;v183[18]=(v183[18] or 0) + 1 ;v187=0;end else if (v187==1) then v181=v181 + 1 ;v182[v181]=v186;v183[v186]=(v183[v186] or 0) + 1 ;elseif (v187==2) then v181=v181 + 1 ;v182[v181]=v186;v181=v181 + 1 ;v182[v181]=v186;v183[v186]=(v183[v186] or 0) + 2 ;elseif (v187>=3) then v181=v181 + 1 ;local v912=((v186~=0) and 16) or ((v187<=10) and 17) or 18 ;v182[v181]=v912;v183[v912]=(v183[v912] or 0) + 1 ;v184=v184 + 1 ;v185[v184]=((v187<=10) and (v187-3)) or (v187-11) ;end v186=v554;if (v554 and (v554~=0)) then v181=v181 + 1 ;v182[v181]=v554;v183[v554]=(v183[v554] or 0) + 1 ;v187=0;else v187=1;end end end return v182,v185,v183;end local function v52(v189,v190,v191,v192,v193) local v194=v191-v193 ;while v194<=((v192-15) -v193)  do v190[v194],v190[v194 + 1 ],v190[v194 + 2 ],v190[v194 + 3 ],v190[v194 + 4 ],v190[v194 + 5 ],v190[v194 + 6 ],v190[v194 + 7 ],v190[v194 + 8 ],v190[v194 + 9 ],v190[v194 + 10 ],v190[v194 + 11 ],v190[v194 + 12 ],v190[v194 + 13 ],v190[v194 + 14 ],v190[v194 + 15 ]=v4(v189,v194 + v193 ,v194 + 15 + v193 );v194=v194 + 16 ;end while v194<=(v192-v193)  do v190[v194]=v4(v189,v194 + v193 ,v194 + v193 );v194=v194 + 1 ;end return v190;end local function v53(v195,v196,v197,v198,v199,v200,v201) local v202=v39[v195];local v203,v204,v205,v206,v207=v202[1],v202[2],v202[3],v202[4],v202[5];local v208=( not v203 and v205) or 2147483646 ;local v209=v207-((v207%4)/4) ;local v210;local v211;local v212;local v213=0;if v201 then v211=v201.hash_tables;v212=v201.string_table;v213=v201.strlen;v1(v198==1 );if ((v199>=v198) and (v213>=2)) then v210=(v212[v213-1 ] * 65536) + (v212[v213] * 256) + v196[1] ;local v771=v197[v210];if  not v771 then v771={};v197[v210]=v771;end v771[ #v771 + 1 ]= -1;end if ((v199>=(v198 + 1)) and (v213>=1)) then v210=(v212[v213] * 65536) + (v196[1] * 256) + v196[2] ;local v773=v197[v210];if  not v773 then v773={};v197[v210]=v773;end v773[ #v773 + 1 ]=0;end end local v214=v213 + 3 ;v210=((v196[v198-v200 ] or 0) * 256) + (v196[(v198 + 1) -v200 ] or 0) ;local v215={};local v216=0;local v217={};local v218={};local v219=0;local v220={};local v221={};local v222=0;local v223={};local v224=0;local v225=false;local v226;local v227;local v228=0;local v229=0;local v230=v198;local v231=v199 + ((v203 and 1) or 0) ;while v230<=v231  do local v572=v230-v200 ;local v573=v200-3 ;v226=v228;v227=v229;v228=0;v210=((v210 * 256) + (v196[v572 + 2 ] or 0))%16777216 ;local v574;local v575;local v576=v197[v210];local v577;if  not v576 then v577=0;v576={};v197[v210]=v576;if v211 then v575=v211[v210];v574=(v575 and  #v575) or 0 ;else v574=0;end else v577= #v576;v575=v576;v574=v577;end if (v230<=v199) then v576[v577 + 1 ]=v230;end if ((v574>0) and ((v230 + 2)<=v199) and ( not v203 or (v226<v205))) then local v722=(v203 and (v226>=v204) and v209) or v207 ;local v723=v199-v230 ;v723=((v723>=257) and 257) or v723 ;v723=v723 + v572 ;local v724=v572 + 3 ;while (v574>=1) and (v722>0)  do local v775=v575[v574];if ((v230-v775)>32768) then break;end if (v775<v230) then local v867=v724;if (v775>= -257) then local v903=v775-v573 ;while (v867<=v723) and (v196[v903]==v196[v867])  do v867=v867 + 1 ;v903=v903 + 1 ;end else local v904=v214 + v775 ;while (v867<=v723) and (v212[v904]==v196[v867])  do v867=v867 + 1 ;v904=v904 + 1 ;end end local v868=v867-v572 ;if (v868>v228) then v228=v868;v229=v230-v775 ;end if (v228>=v206) then break;end end v574=v574-1 ;v722=v722-1 ;if ((v574==0) and (v775>0) and v211) then v575=v211[v210];v574=(v575 and  #v575) or 0 ;end end end if  not v203 then v226,v227=v228,v229;end if (( not v203 or v225) and ((v226>3) or ((v226==3) and (v227<4096))) and (v228<=v226)) then local v725=v16[v226];local v726=v18[v226];local v727,v728,v729;if (v227<=256) then v727=v19[v227];v729=v20[v227];v728=v21[v227];else v727=16;v728=7;local v831=384;local v832=512;while true do if (v227<=v831) then v729=((v227-(v832/2)) -1)%(v832/4) ;break;elseif (v227<=v832) then v729=((v227-(v832/2)) -1)%(v832/4) ;v727=v727 + 1 ;break;else v727=v727 + 2 ;v728=v728 + 1 ;v831=v831 * 2 ;v832=v832 * 2 ;end end end v216=v216 + 1 ;v215[v216]=v725;v217[v725]=(v217[v725] or 0) + 1 ;v219=v219 + 1 ;v218[v219]=v727;v220[v727]=(v220[v727] or 0) + 1 ;if (v726>0) then local v833=v17[v226];v222=v222 + 1 ;v221[v222]=v833;end if (v728>0) then v224=v224 + 1 ;v223[v224]=v729;end for v776=v230 + 1 ,(v230 + v226) -((v203 and 2) or 1)  do v210=((v210 * 256) + (v196[(v776-v200) + 2 ] or 0))%16777216 ;if (v226<=v208) then v576=v197[v210];if  not v576 then v576={};v197[v210]=v576;end v576[ #v576 + 1 ]=v776;end end v230=(v230 + v226) -((v203 and 1) or 0) ;v225=false;elseif ( not v203 or v225) then local v836=v196[(v203 and (v572-1)) or v572 ];v216=v216 + 1 ;v215[v216]=v836;v217[v836]=(v217[v836] or 0) + 1 ;v230=v230 + 1 ;else v225=true;v230=v230 + 1 ;end end v216=v216 + 1 ;v215[v216]=256;v217[256]=(v217[256] or 0) + 1 ;return v215,v221,v217,v218,v223,v220;end local function v54(v234,v235) local v236,v237,v238=v50(v234,15,285);local v239,v240,v241=v50(v235,15,29);local v242,v243,v244=v51(v236,v238,v239,v241);local v245,v246=v50(v244,7,18);local v247=0;for v578=1,19 do local v579=v26[v578];local v580=v245[v579] or 0 ;if (v580~=0) then v247=v578;end end v247=v247-4 ;local v248=(v238 + 1) -257 ;local v249=(v241 + 1) -1 ;if (v249<0) then v249=0;end return v248,v249,v247,v245,v246,v242,v243,v236,v237,v239,v240;end local function v55(v250,v251,v252,v253,v254,v255,v256) local v257=17;v257=v257 + ((v252 + 4) * 3) ;for v581=1, #v254 do local v582=v254[v581];v257=v257 + v253[v582] ;if (v582>=16) then v257=v257 + (((v582==16) and 2) or ((v582==17) and 3) or 7) ;end end local v258=0;for v583=1, #v250 do local v584=v250[v583];local v585=v255[v584];v257=v257 + v585 ;if (v584>256) then v258=v258 + 1 ;if ((v584>264) and (v584<285)) then local v839=v23[v584-256 ];v257=v257 + v839 ;end local v734=v251[v258];local v735=v256[v734];v257=v257 + v735 ;if (v734>3) then local v840=((v734-(v734%2))/2) -1 ;v257=v257 + v840 ;end end end return v257;end local function v56(v259,v260,v261,v262,v263,v264,v265,v266,v267,v268,v269,v270,v271,v272,v273,v274,v275) v259((v260 and 1) or 0 ,1);v259(2,2);v259(v265,5);v259(v266,5);v259(v267,4);for v586=1,v267 + 4  do local v587=v26[v586];local v588=v268[v587] or 0 ;v259(v588,3);end local v276=1;for v589=1, #v270 do local v590=v270[v589];v259(v269[v590],v268[v590]);if (v590>=16) then local v736=v271[v276];v259(v736,((v590==16) and 2) or ((v590==17) and 3) or 7 );v276=v276 + 1 ;end end local v277=0;local v278=0;local v279=0;for v591=1, #v261 do local v592=v261[v591];local v593=v273[v592];local v594=v272[v592];v259(v593,v594);if (v592>256) then v277=v277 + 1 ;if ((v592>264) and (v592<285)) then v278=v278 + 1 ;local v841=v262[v278];local v842=v23[v592-256 ];v259(v841,v842);end local v737=v263[v277];local v738=v275[v737];local v739=v274[v737];v259(v738,v739);if (v737>3) then v279=v279 + 1 ;local v843=v264[v279];local v844=((v737-(v737%2))/2) -1 ;v259(v843,v844);end end end end local function v57(v280,v281) local v282=3;local v283=0;for v595=1, #v280 do local v596=v280[v595];local v597=v29[v596];v282=v282 + v597 ;if (v596>256) then v283=v283 + 1 ;if ((v596>264) and (v596<285)) then local v845=v23[v596-256 ];v282=v282 + v845 ;end local v740=v281[v283];v282=v282 + 5 ;if (v740>3) then local v846=((v740-(v740%2))/2) -1 ;v282=v282 + v846 ;end end end return v282;end local function v58(v284,v285,v286,v287,v288,v289) v284((v285 and 1) or 0 ,1);v284(1,2);local v290=0;local v291=0;local v292=0;for v598=1, #v286 do local v599=v286[v598];local v600=v27[v599];local v601=v29[v599];v284(v600,v601);if (v599>256) then v290=v290 + 1 ;if ((v599>264) and (v599<285)) then v291=v291 + 1 ;local v847=v287[v291];local v848=v23[v599-256 ];v284(v847,v848);end local v741=v288[v290];local v742=v31[v741];v284(v742,5);if (v741>3) then v292=v292 + 1 ;local v849=v289[v292];local v850=((v741-(v741%2))/2) -1 ;v284(v849,v850);end end end end local function v59(v293,v294,v295) v1(((v294-v293) + 1)<=65535 );local v296=3;v295=v295 + 3 ;local v297=(8 -(v295%8))%8 ;v296=v296 + v297 ;v296=v296 + 32 ;v296=v296 + (((v294-v293) + 1) * 8) ;return v296;end local function v60(v298,v299,v300,v301,v302,v303,v304) v1(((v303-v302) + 1)<=65535 );v298((v300 and 1) or 0 ,1);v298(0,2);v304=v304 + 3 ;local v305=(8 -(v304%8))%8 ;if (v305>0) then v298(v13[v305] -1 ,v305);end local v306=(v303-v302) + 1 ;v298(v306,16);local v307=(255 -(v306%256)) + ((255 -((v306-(v306%256))/256)) * 256) ;v298(v307,16);v299(v301:sub(v302,v303));end local function v61(v308,v309,v310,v311,v312,v313) local v314={};local v315={};local v316=nil;local v317;local v318;local v319;local v320=v311(v44);local v321= #v312;local v322;local v323;local v324;if v308 then if v308.level then v323=v308.level;end if v308.strategy then v324=v308.strategy;end end if  not v323 then if (v321<2048) then v323=7;elseif (v321>65536) then v323=3;else v323=5;end end while  not v316 do if  not v317 then v317=1;v318=(64 * 1024) -1 ;v322=0;else v317=v318 + 1 ;v318=v318 + (32 * 1024) ;v322=(v317-(32 * 1024)) -1 ;end if (v318>=v321) then v318=v321;v316=true;else v316=false;end local v602,v603,v604,v605,v606,v607;local v608,v609,v610,v611,v612,v613,v614,v615,v616,v617,v618;local v619;local v620;local v621;if (v323~=0) then v52(v312,v314,v317,v318 + 3 ,v322);if ((v317==1) and v313) then local v851=v313.string_table;local v852=v313.strlen;for v872=0,((( -v852 + 1)< -257) and  -257) or ( -v852 + 1) , -1 do v314[v872]=v851[v852 + v872 ];end end if (v324=="huffman_only") then v602={};v52(v312,v602,v317,v318,v317-1 );v603={};v604={};v602[(v318-v317) + 2 ]=256;for v875=1,(v318-v317) + 2  do local v876=v602[v875];v604[v876]=(v604[v876] or 0) + 1 ;end v605={};v606={};v607={};else v602,v603,v604,v605,v606,v607=v53(v323,v314,v315,v317,v318,v322,v313);end v608,v609,v610,v611,v612,v613,v614,v615,v616,v617,v618=v54(v604,v607);v619=v55(v602,v605,v610,v611,v613,v615,v617);v620=v57(v602,v605);end v621=v59(v317,v318,v320);local v622=v621;v622=(v620 and (v620<v622) and v620) or v622 ;v622=(v619 and (v619<v622) and v619) or v622 ;if ((v323==0) or ((v324~="fixed") and (v324~="dynamic") and (v621==v622))) then v60(v309,v310,v316,v312,v317,v318,v320);v320=v320 + v621 ;elseif ((v324~="dynamic") and ((v324=="fixed") or (v620==v622))) then v58(v309,v316,v602,v603,v605,v606);v320=v320 + v620 ;elseif ((v324=="dynamic") or (v619==v622)) then v56(v309,v316,v602,v603,v605,v606,v608,v609,v610,v611,v612,v613,v614,v615,v616,v617,v618);v320=v320 + v619 ;end if v316 then v319=v311(v44);else v319=v311(v41);end v1(v319==v320 );if  not v316 then local v743;if (v313 and (v317==1)) then v743=0;while v314[v743] do v314[v743]=nil;v743=v743-1 ;end end v313=nil;v743=1;for v779=v318-32767 ,v318 do v314[v743]=v314[v779-v322 ];v743=v743 + 1 ;end for v782,v783 in v3(v315) do local v784= #v783;if ((v784>0) and (((v318 + 1) -v783[1])>32768)) then if (v784==1) then v315[v782]=nil;else local v907={};local v908=0;for v916=2,v784 do v743=v783[v916];if (((v318 + 1) -v743)<=32768) then v908=v908 + 1 ;v907[v908]=v743;end end v315[v782]=v907;end end end end end end local function v62(v325,v326,v327) local v328,v329,v330=v45();v61(v327,v328,v329,v330,v325,v326);local v331,v332=v330(v42);local v333=(8 -(v331%8))%8 ;return v332,v333;end local function v63(v334,v335,v336) local v337,v338,v339=v45();local v340=8;local v341=7;local v342=(v341 * 16) + v340 ;v337(v342,8);local v343=(v335 and 1) or 0 ;local v344=2;local v345=(v344 * 64) + (v343 * 32) ;local v346=31 -(((v342 * 256) + v345)%31) ;v345=v345 + v346 ;v337(v345,8);if (v343==1) then local v675=v335.adler32;local v676=v675%256 ;v675=(v675-v676)/256 ;local v677=v675%256 ;v675=(v675-v677)/256 ;local v678=v675%256 ;v675=(v675-v678)/256 ;local v679=v675%256 ;v337(v679,8);v337(v678,8);v337(v677,8);v337(v676,8);end v61(v336,v337,v338,v339,v334,v335);v339(v43);local v347=v0:Adler32(v334);local v348=v347%256 ;v347=(v347-v348)/256 ;local v349=v347%256 ;v347=(v347-v349)/256 ;local v350=v347%256 ;v347=(v347-v350)/256 ;local v351=v347%256 ;v337(v351,8);v337(v350,8);v337(v349,8);v337(v348,8);local v352,v353=v339(v42);local v354=(8 -(v352%8))%8 ;return v353,v354;end v0.CompressDeflate=function(v355,v356,v357) local v358,v359=v40(v356,false,nil,true,v357);if  not v358 then v2("Usage: LibDeflate:CompressDeflate(str, configs): "   .. v359 ,2);end return v62(v356,nil,v357);end;v0.CompressDeflateWithDict=function(v360,v361,v362,v363) local v364,v365=v40(v361,true,v362,true,v363);if  not v364 then v2("Usage: LibDeflate:CompressDeflateWithDict"   .. "(str, dictionary, configs): "   .. v365 ,2);end return v62(v361,v362,v363);end;v0.CompressZlib=function(v366,v367,v368) local v369,v370=v40(v367,false,nil,true,v368);if  not v369 then v2("Usage: LibDeflate:CompressZlib(str, configs): "   .. v370 ,2);end return v63(v367,nil,v368);end;v0.CompressZlibWithDict=function(v371,v372,v373,v374) local v375,v376=v40(v372,true,v373,true,v374);if  not v375 then v2("Usage: LibDeflate:CompressZlibWithDict"   .. "(str, dictionary, configs): "   .. v376 ,2);end return v63(v372,v373,v374);end;local function v68(v377) local v378=v377;local v379= #v377;local v380=1;local v381=0;local v382=0;local function v383(v623) local v624=v13[v623];local v625;if (v623<=v381) then v625=v382%v624 ;v382=(v382-v625)/v624 ;v381=v381-v623 ;else local v744=v13[v381];local v745,v746,v747,v748=v4(v378,v380,v380 + 3 );v382=v382 + (((v745 or 0) + ((v746 or 0) * 256) + ((v747 or 0) * 65536) + ((v748 or 0) * 16777216)) * v744) ;v380=v380 + 4 ;v381=(v381 + 32) -v623 ;v625=v382%v624 ;v382=(v382-v625)/v624 ;end return v625;end local function v384(v626,v627,v628) v1((v381%8)==0 );local v629=(((v381/8)<v626) and (v381/8)) or v626 ;for v680=1,v629 do local v681=v382%256 ;v628=v628 + 1 ;v627[v628]=v5(v681);v382=(v382-v681)/256 ;end v381=v381-(v629 * 8) ;v626=v626-v629 ;if ((((((v379-v380) -v626) + 1) * 8) + v381)<0) then return  -1;end for v683=v380,(v380 + v626) -1  do v628=v628 + 1 ;v627[v628]=v8(v378,v683,v683);end v380=v380 + v626 ;return v628;end local function v385(v630,v631,v632) local v633=0;local v634=0;local v635=0;local v636;if (v632>0) then if ((v381<15) and v378) then local v854=v13[v381];local v855,v856,v857,v858=v4(v378,v380,v380 + 3 );v382=v382 + (((v855 or 0) + ((v856 or 0) * 256) + ((v857 or 0) * 65536) + ((v858 or 0) * 16777216)) * v854) ;v380=v380 + 4 ;v381=v381 + 32 ;end local v749=v13[v632];v381=v381-v632 ;v633=v382%v749 ;v382=(v382-v633)/v749 ;v633=v15[v632][v633];v636=v630[v632];if (v633<v636) then return v631[v633];end v635=v636;v634=v636 * 2 ;v633=v633 * 2 ;end for v685=v632 + 1 ,15 do local v686;v686=v382%2 ;v382=(v382-v686)/2 ;v381=v381-1 ;v633=((v686==1) and ((v633 + 1) -(v633%2))) or v633 ;v636=v630[v685] or 0 ;local v687=v633-v634 ;if (v687<v636) then return v631[v635 + v687 ];end v635=v635 + v636 ;v634=v634 + v636 ;v634=v634 * 2 ;v633=v633 * 2 ;end return  -10;end local function v386() return (((v379-v380) + 1) * 8) + v381 ;end local function v387() local v637=v381%8 ;local v638=v13[v637];v381=v381-v637 ;v382=(v382-(v382%v638))/v638 ;end return v383,v384,v385,v386,v387;end local function v69(v388,v389) local v390,v391,v392,v393,v394=v68(v388);local v395={ReadBits=v390,ReadBytes=v391,Decode=v392,ReaderBitlenLeft=v393,SkipToByteBoundary=v394,buffer_size=0,buffer={},result_buffer={},dictionary=v389};return v395;end local function v70(v396,v397,v398) local v399={};local v400=v398;for v639=0,v397 do local v640=v396[v639] or 0 ;v400=((v640>0) and (v640<v400) and v640) or v400 ;v399[v640]=(v399[v640] or 0) + 1 ;end if (v399[0]==(v397 + 1)) then return 0,v399,{},0;end local v401=1;for v642=1,v398 do v401=v401 * 2 ;v401=v401-(v399[v642] or 0) ;if (v401<0) then return v401;end end local v402={};v402[1]=0;for v643=1,v398-1  do v402[v643 + 1 ]=v402[v643] + (v399[v643] or 0) ;end local v404={};for v645=0,v397 do local v646=v396[v645] or 0 ;if (v646~=0) then local v752=v402[v646];v404[v752]=v645;v402[v646]=v402[v646] + 1 ;end end return v401,v399,v404,v400;end local function v71(v405,v406,v407,v408,v409,v410,v411) local v412,v413,v414,v415,v416,v417=v405.buffer,v405.buffer_size,v405.ReadBits,v405.Decode,v405.ReaderBitlenLeft,v405.result_buffer;local v418=v405.dictionary;local v419;local v420;local v421=1;if (v418 and  not v412[0]) then v419=v418.string_table;v420=v418.strlen;v421= -v420 + 1 ;for v755=0,((( -v420 + 1)< -257) and  -257) or ( -v420 + 1) , -1 do v412[v755]=v14[v419[v420 + v755 ]];end end repeat local v647=v415(v406,v407,v408);if ((v647<0) or (v647>285)) then return  -10;elseif (v647<256) then v413=v413 + 1 ;v412[v413]=v14[v647];elseif (v647>256) then v647=v647-256 ;local v896=v22[v647];v896=((v647>=8) and (v896 + v414(v23[v647]))) or v896 ;v647=v415(v409,v410,v411);if ((v647<0) or (v647>29)) then return  -10;end local v897=v24[v647];v897=((v897>4) and (v897 + v414(v25[v647]))) or v897 ;local v898=(v413-v897) + 1 ;if (v898<v421) then return  -11;end if (v898>= -257) then for v920=1,v896 do v413=v413 + 1 ;v412[v413]=v412[v898];v898=v898 + 1 ;end else v898=v420 + v898 ;for v923=1,v896 do v413=v413 + 1 ;v412[v413]=v14[v419[v898]];v898=v898 + 1 ;end end end if (v416()<0) then return 2;end if (v413>=65536) then v417[ #v417 + 1 ]=v9(v412,"",1,32768);for v785=32769,v413 do v412[v785-32768 ]=v412[v785];end v413=v413-32768 ;v412[v413 + 1 ]=nil;end until symbol==256  v405.buffer_size=v413;return 0;end local function v72(v423) local v424,v425,v426,v427,v428,v429,v430=v423.buffer,v423.buffer_size,v423.ReadBits,v423.ReadBytes,v423.ReaderBitlenLeft,v423.SkipToByteBoundary,v423.result_buffer;v429();local v431=v426(16);if (v428()<0) then return 2;end local v432=v426(16);if (v428()<0) then return 2;end if (((v431%256) + (v432%256))~=255) then return  -2;end if ((((v431-(v431%256))/256) + ((v432-(v432%256))/256))~=255) then return  -2;end v425=v427(v431,v424,v425);if (v425<0) then return 2;end if (v425>=65536) then v430[ #v430 + 1 ]=v9(v424,"",1,32768);for v760=32769,v425 do v424[v760-32768 ]=v424[v760];end v425=v425-32768 ;v424[v425 + 1 ]=nil;end v423.buffer_size=v425;return 0;end local function v73(v434) return v71(v434,v30,v28,7,v34,v32,5);end local function v74(v435) local v436,v437=v435.ReadBits,v435.Decode;local v438=v436(5) + 257 ;local v439=v436(5) + 1 ;local v440=v436(4) + 4 ;if ((v438>286) or (v439>30)) then return  -3;end local v441={};for v648=1,v440 do v441[v26[v648]]=v436(3);end local v442,v443,v444,v445=v70(v441,18,7);if (v442~=0) then return  -4;end local v446={};local v447={};local v448=0;while v448<(v438 + v439)  do local v650;local v651;v650=v437(v443,v444,v445);if (v650<0) then return v650;elseif (v650<16) then if (v448<v438) then v446[v448]=v650;else v447[v448-v438 ]=v650;end v448=v448 + 1 ;else v651=0;if (v650==16) then if (v448==0) then return  -5;end if ((v448-1)<v438) then v651=v446[v448-1 ];else v651=v447[(v448-v438) -1 ];end v650=3 + v436(2) ;elseif (v650==17) then v650=3 + v436(3) ;else v650=11 + v436(7) ;end if ((v448 + v650)>(v438 + v439)) then return  -6;end while v650>0  do v650=v650-1 ;if (v448<v438) then v446[v448]=v651;else v447[v448-v438 ]=v651;end v448=v448 + 1 ;end end end if ((v446[256] or 0)==0) then return  -9;end local v449,v450,v451,v452=v70(v446,v438-1 ,15);if ((v449~=0) and ((v449<0) or (v438~=((v450[0] or 0) + (v450[1] or 0))))) then return  -7;end local v453,v454,v455,v456=v70(v447,v439-1 ,15);if ((v453~=0) and ((v453<0) or (v439~=((v454[0] or 0) + (v454[1] or 0))))) then return  -8;end return v71(v435,v450,v451,v452,v454,v455,v456);end local function v75(v457) local v458=v457.ReadBits;local v459;while  not v459 do v459=v458(1)==1 ;local v652=v458(2);local v653;if (v652==0) then v653=v72(v457);elseif (v652==1) then v653=v73(v457);elseif (v652==2) then v653=v74(v457);else return nil, -1;end if (v653~=0) then return nil,v653;end end v457.result_buffer[ #v457.result_buffer + 1 ]=v9(v457.buffer,"",1,v457.buffer_size);local v461=v9(v457.result_buffer);return v461;end local function v76(v462,v463) local v464=v69(v462,v463);local v465,v466=v75(v464);if  not v465 then return nil,v466;end local v467=v464.ReaderBitlenLeft();local v468=(v467-(v467%8))/8 ;return v465,v468;end local function v77(v469,v470) local v471=v69(v469,v470);local v472=v471.ReadBits;local v473=v472(8);if (v471.ReaderBitlenLeft()<0) then return nil,2;end local v474=v473%16 ;local v475=(v473-v474)/16 ;if (v474~=8) then return nil, -12;end if (v475>7) then return nil, -13;end local v476=v472(8);if (v471.ReaderBitlenLeft()<0) then return nil,2;end if ((((v473 * 256) + v476)%31)~=0) then return nil, -14;end local v477=((v476-(v476%32))/32)%2 ;local v478=((v476-(v476%64))/64)%4 ;if (v477==1) then if  not v470 then return nil, -16;end local v692=v472(8);local v693=v472(8);local v694=v472(8);local v695=v472(8);local v696=(v692 * 16777216) + (v693 * 65536) + (v694 * 256) + v695 ;if (v471.ReaderBitlenLeft()<0) then return nil,2;end if  not v36(v696,v470.adler32) then return nil, -17;end end local v479,v480=v75(v471);if  not v479 then return nil,v480;end v471.SkipToByteBoundary();local v481=v472(8);local v482=v472(8);local v483=v472(8);local v484=v472(8);if (v471.ReaderBitlenLeft()<0) then return nil,2;end local v485=(v481 * 16777216) + (v482 * 65536) + (v483 * 256) + v484 ;local v486=v0:Adler32(v479);if  not v36(v485,v486) then return nil, -15;end local v487=v471.ReaderBitlenLeft();local v488=(v487-(v487%8))/8 ;return v479,v488;end v0.DecompressDeflate=function(v489,v490) local v491,v492=v40(v490);if  not v491 then v2("Usage: LibDeflate:DecompressDeflate(str): "   .. v492 ,2);end return v76(v490);end;v0.DecompressDeflateWithDict=function(v493,v494,v495) local v496,v497=v40(v494,true,v495);if  not v496 then v2("Usage: LibDeflate:DecompressDeflateWithDict(str, dictionary): "   .. v497 ,2);end return v76(v494,v495);end;v0.DecompressZlib=function(v498,v499) local v500,v501=v40(v499);if  not v500 then v2("Usage: LibDeflate:DecompressZlib(str): "   .. v501 ,2);end return v77(v499);end;v0.DecompressZlibWithDict=function(v502,v503,v504) local v505,v506=v40(v503,true,v504);if  not v505 then v2("Usage: LibDeflate:DecompressZlibWithDict(str, dictionary): "   .. v506 ,2);end return v77(v503,v504);end;do v29={};for v654=0,143 do v29[v654]=8;end for v656=144,255 do v29[v656]=9;end for v658=256,279 do v29[v658]=7;end for v660=280,287 do v29[v660]=8;end v33={};for v662=0,31 do v33[v662]=5;end local v507;v507,v30,v28=v70(v29,287,9);v1(v507==0 );v507,v34,v32=v70(v33,31,5);v1(v507==0 );v27=v48(v30,v29,287,9);v31=v48(v34,v33,31,5);end return v0;
]=======])
if err ~= nil then
    error(err)
end
deflate = deflate()

local expect = require("cc.expect")
local field, range = expect.field, expect.range

-- local logFile = fs.open("ccr_remote/debug_log", "w+")
function log(...)
    return
--     local msg = ""
--     local args = table.pack(...)
--     for i = 1,args.n do
--         if i ~= 1 then
--             msg = msg .. " "
--         end
--         msg = msg .. tostring(args[i])
--     end
--     logFile.writeLine(msg)
--     logFile.flush()
end

local function mkRow(chars, fg, bg)
    local chars = expect(1, chars, "string")
    local fg = expect(2, fg, "string")
    local bg = expect(3, bg, "string")

    if #fg ~= #chars then
        error("fg length does not match chars", 2)
    end

    if #bg ~= #chars then
        error("bg length does not match chars", 2)
    end

    return { chars = chars, fg = fg, bg = bg }
end

local blankChar = "\0"
local screenBuffer = {}
function screenBuffer.new()
    local self = {
        size = { x = 0, y = 0 },
        rows = {}
    }

    return setmetatable(self, {
        __index = screenBuffer,
    })
end

function screenBuffer:resize(newSize, fg, bg)
    expect(1, self, "table")
    expect(2, newSize, "table")
    expect(3, fg, "string")
    expect(4, bg, "string")
    log("screenBuffer:resize", newSize.x, newSize.y, fg, bg)
    self:debugAssertScreenSize()

    local oldSize = self.size
    self.size = {
        x = field(newSize, "x", "number"),
        y = field(newSize, "y", "number")
    }

    -- Every row between 1 and minY is only being modified
    local minY = math.min(self.size.y, oldSize.y)
    local maxY = math.max(self.size.y, oldSize.y)

    for y = 1,maxY do
        if (y <= minY) and (self.size.x ~= oldSize.x) then
            local oldRow = self.rows[y]
            if self.size.x > oldSize.x then
                -- Extending an old row
                local delta = self.size.x - oldSize.x
                self.rows[y] = mkRow(
                    oldRow.chars .. blankChar:rep(delta),
                    oldRow.fg .. fg:rep(delta),
                    oldRow.bg .. bg:rep(delta)
                )
            elseif oldSize.x > self.size.x then
                -- Shortening an old row
                self.rows[y] = mkRow(
                    oldRow.chars:sub(1, self.size.x),
                    oldRow.fg:sub(1, self.size.x),
                    oldRow.bg:sub(1, self.size.x)
                )
            end
        elseif y <= self.size.y then
            -- Adding a new row
            self.rows[y] = mkRow(
                blankChar:rep(self.size.x),
                fg:rep(self.size.x),
                bg:rep(self.size.x)
            )
        else
            -- Removing an old row
            self.rows[y] = nil
        end
    end

    self:debugAssertScreenSize()
end

function screenBuffer:debugAssertScreenSize()
    return
--     if (#self.rows) ~= self.size.y then
--         error("y borked", 2)
--     end
--
--     for y = 1,self.size.y do
--         r = self.rows[y]
--         if (#r.chars) ~= self.size.x then
--             error(tostring(y) .. " x borked", 2)
--         end
--     end
end

function screenBuffer:scroll(y, fg, bg)
    expect(1, self, "table")
    expect(2, y, "number")
    expect(3, fg, "string")
    expect(4, bg, "string")
    log("screenBuffer:scroll", y, fg, bg)
    self:debugAssertScreenSize()

    if n == 0 then
        return
    end

    local doScroll = function(newY)
        local y = newY + n
        if (y >= 1) and (y <= self.size.y) then
            local oldRow = self.rows[y]
            self.rows[newY] = mkRow(
                oldRow.chars, oldRow.fg, oldRow.bg
            )
        else
            self.rows[newY] = mkRow(
                blankChar:rep(self.size.x),
                fg:rep(self.size.x),
                bg:rep(self.size.x)
            )
        end
    end

    if n > 0 then
        for newY = 1,self.size.y do
            doScroll(newY)
        end
    else
        -- Iterate backward to avoid clobbering rows
        for newY = self.size.y,1,-1 do
            doScroll(newY)
        end
    end

    self:debugAssertScreenSize()
end

function screenBuffer:blit(cursorX, cursorY, text, fg, bg)
    expect(1, self, "table")
    expect(2, cursorX, "number")
    expect(3, cursorY, "number")
    expect(4, text, "string")
    expect(5, fg, "string")
    expect(6, bg, "string")
    log("screenBuffer:blit", cursorX, cursorY, text, fg, bg)
    self:debugAssertScreenSize()

    local startX = cursorX
    local endX = startX + #text - 1
    if (cursorY < 1 or cursorY > self.size.y)
    or (endX < 1 or startX > self.size.x) then
       return
    end

    if (#self.rows[cursorY].chars ~= self.size.x) then
        error("before blit borked")
    end

    -- Clip the strings + start/end position to what is visible
    startX = math.max(startX, 1)
    startClipLen = (startX - cursorX)
    endClipLen = (endX - self.size.x) + 1
    endX = math.min(endX, self.size.x)

    log("blit_clip_start", startX, startClipLen)
    log("blit_clip_end", endX, endClipLen)
    log("blit_clipped_text", text:sub(startClipLen, -endClipLen))

    -- Insert the substrings into the line
    local oldRow = self.rows[cursorY]
    self.rows[cursorY] = mkRow(
        oldRow.chars:sub(1, startX-1) .. text:sub(startClipLen, -endClipLen) .. oldRow.chars:sub(endX+1),
        oldRow.fg:sub(1, startX-1) .. fg:sub(startClipLen, -endClipLen) .. oldRow.fg:sub(endX+1),
        oldRow.bg:sub(1, startX-1) .. bg:sub(startClipLen, -endClipLen) .. oldRow.bg:sub(endX+1)
    )

    log("blit_end_len", #self.rows[cursorY].chars, #self.rows[cursorY].fg, #self.rows[cursorY].bg)

    self:debugAssertScreenSize()
end

function screenBuffer:clear(fg, bg)
    expect(1, self, "table")
    expect(2, fg, "string")
    expect(3, bg, "string")
    log("screenBuffer:clear", fg, bg)
    self:debugAssertScreenSize()

    for y = 1,self.size.y do
        self.rows[y] = mkRow(
            blankChar:rep(self.size.x),
            fg:rep(self.size.x),
            bg:rep(self.size.x)
        )
    end
end

function screenBuffer:clearLine(n, fg, bg)
    expect(1, self, "table")
    expect(2, n, "number")
    expect(3, fg, "string")
    expect(4, bg, "string")
    log("screenBuffer:clearLine", n, fg, bg)
    self:debugAssertScreenSize()

    if (n < 1 or n > self.size.y) then
       return
    end

    self.rows[n] = mkRow(
        blankChar:rep(self.size.x),
        fg:rep(self.size.x),
        bg:rep(self.size.x)
    )
end

local headlessRedirect = {}
function headlessRedirect.new()
    local self = {
        buffer = screenBuffer.new(),
        cursor = { x = 1, y = 1, blink = false },
        fgColor = colors.toBlit(colors.white),
        bgColor = colors.toBlit(colors.black),
        palette = {},
        dirty = true
    }

    for i = 0,15 do
        local c = 2 ^ i
        self.palette[colors.toBlit(c)] = { term.nativePaletteColor(c) }
    end

    self.buffer:resize({ x = 51, y = 19 }, self.fgColor, self.bgColor)

    local fenv = setmetatable(
        { self = self },
        { __index = _ENV }
    )

    return setmetatable(self, {
        __index = function(_, idx)
            if type(idx) == "string" then
                idx = idx:gsub("Colour", "Color")
            end

            local v = headlessRedirect[idx]
            if type(v) == "function" and _ENV["self"] ~= self then
                v = setfenv(v, fenv)
            end

            return v
        end,
        __newIndex = function()
            error("Refusing to set value on headlessRedirect")
        end
    })
end

function headlessRedirect.resize(x, y)
    log("headlessRedirect.resize", x, y)
    self.dirty = true
    self.buffer:resize({ x = x, y = y }, self.fgColor, self.bgColor)
end

function headlessRedirect.blit(text, fgColor, bgColor)
    if #fgColor ~= #text or #bgColor ~= #text then
        error("Arguments must be the same length", 2)
    end
    log("headlessRedirect.blit", text, fgColor, bgColor)
    self.dirty = true

    self.buffer:blit(self.cursor.x, self.cursor.y, text, fgColor:lower(), bgColor:lower())
    self.cursor.x = self.cursor.x + #text
end

function headlessRedirect.write(text)
    text = tostring(text)
    log("headlessRedirect.write", text)
    self.dirty = true

    self.buffer:blit(self.cursor.x, self.cursor.y, text, self.fgColor:rep(#text), self.bgColor:rep(#text))
    self.cursor.x = self.cursor.x + #text
end

function headlessRedirect.scroll(n)
    log("headlessRedirect.scroll", n)
    self.dirty = true

    self.buffer:scroll(n, self.fgColor, self.bgColor)
end

function headlessRedirect.clearLine()
    log("headlessRedirect.clearLine")
    self.dirty = true

    self.buffer:clearLine(self.cursor.y, self.fgColor, self.bgColor)
end

function headlessRedirect.clear()
    log("headlessRedirect.clear")
    self.dirty = true

    self.buffer:clear(self.fgColor, self.bgColor)
end

function headlessRedirect.getCursorPos()
    log("headlessRedirect.getCursorPos", self.cursor.x, self.cursor.y)
    return self.cursor.x, self.cursor.y
end

function headlessRedirect.setCursorPos(x, y)
    self.cursor.x = math.floor(x)
    self.cursor.y = math.floor(y)
    log("headlessRedirect.setCursorPos", self.cursor.x, self.cursor.y)
    self.dirty = true
end

function headlessRedirect.getCursorBlink()
    log("headlessRedirect.getCursorBlink", self.cursor.blink)
    return self.cursor.blink
end

function headlessRedirect.setCursorBlink(blink)
    expect(1, blink, "boolean")
    self.cursor.blink = (blink == true)
    log("headlessRedirect.setCursorBlink", self.cursor.blink)
    self.dirty = true
end

function headlessRedirect.getSize()
    log("headlessRedirect.getSize", self.buffer.size.x, self.buffer.size.y)
    return self.buffer.size.x, self.buffer.size.y
end

function headlessRedirect.getTextColor()
    local fgColor = colors.fromBlit(self.fgColor)
    log("headlessRedirect.getTextColor", fgColor)
    return fgColor
end

function headlessRedirect.setTextColor(color)
    expect(1, color, "number")
    log("headlessRedirect.setTextColor", color)
    self.fgColor = colors.toBlit(color)
    self.dirty = true
end

function headlessRedirect.getBackgroundColor()
    local bgColor = colors.fromBlit(self.bgColor)
    log("headlessRedirect.getBackgroundColor", bgColor)
    return bgColor
end

function headlessRedirect.setBackgroundColor(color)
    expect(1, color, "number")
    log("headlessRedirect.setBackgroundColor", color)
    self.bgColor = colors.toBlit(color)
    self.dirty = true
end

function headlessRedirect.isColor()
    return true
end

function headlessRedirect.setPaletteColor(index, r, g, b)
    expect(1, index, "number")
    expect(2, r, "number")
    expect(3, g, "number", "nil")
    expect(4, b, "number", "nil")

    if (g ~= nil) and (b ~= nil) then
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
    else
        r, g, b = colors.unpackRGB(tonumber(r))
    end

    log("headlessRedirect.setPaletteColor", index, r, g, b)
    self.dirty = true

    self.palette[colors.toBlit(index)] = { r, g, b }
end

function headlessRedirect.getPaletteColor(color)
    expect(1, color, "number")
    local r, g, b = table.unpack(self.palette[colors.toBlit(color)])
    log("headlessRedirect.getPaletteColor", color, r, g, b)
    return r, g, b
end

---@param ws Websocket
---@param redirect table
local function pollEvent(ws, redirect)
    expect(1, ws, "table")
    expect(2, redirect, "table")

    local rawPacket = ws.receive()
    if rawPacket == nil then
        error("websocket closed", 2)
    end

    events = textutils.unserializeJSON(rawPacket)
    for _,e in ipairs(events) do
        local eventName = field(e, "name", "string")
        local eventArgs = field(e, "args", "table", "nil")
        if eventArgs == nil then
            eventArgs = {}
        end

        local typedArgs = {}
        if (eventName == "char") then
            typedArgs = eventArgs
        else
            for _,v in ipairs(eventArgs) do
                local tv
                if (v == "true") or (v == "false") then
                    tv = (v == "true")
                elseif v:match("^[0-9]+%.?[0-9]*$") then
                    tv = tonumber(v, 10)
                else
                    tv = v
                end

                table.insert(typedArgs, tv)
            end
        end

        log("event", eventName, table.unpack(typedArgs))

        if eventName == "term_resize" then
            local width, height = table.unpack(typedArgs)
            redirect.resize(width, height)
        elseif eventName == "terminate" then
        --    TODO: Somehow deliver this only to the shell
        end

        os.queueEvent(eventName, table.unpack(typedArgs))
    end
end

local function getCfg()
    local defaultShell = "shell"
    if term.native().isColor() then
        defaultShell = "multishell"
    end

    local defaultTabName = os.getComputerLabel()
    if defaultTabName == nil then
        defaultTabName = ("#%d"):format(os.getComputerID())
    end

    local spec = {
        shell = {
            description = "Shell binary that ccr starts when connecting",
            default = defaultShell,
            type = "string"
        },
        updateRate = {
            description = "Amount of screen updates sent in a second",
            default = 30,
            type = "number"
        },
        tabName = {
            description = "The name displayed on the ccr tab when connected",
            default = defaultTabName,
            type = "string"
        },
        defaultHost = {
            description = "Connect to this host if one isn't provided",
            type = "string"
        }
    }

    local values = {}
    for n,s in pairs(spec) do
        local key = "ccr." .. n
        settings.define(key, s)
        values[n] = settings.get(key)
    end

    return values
end

---@param host string
---@return Websocket
local function connectWs(host)
    local url = string.format("ws://%s/.well-known/ccremote", host)

    log("connectWs", url)

    if http.checkURLAsync(url) then
        local event, event_url, ok, failure_reason
        while (event ~= "http_check") and (event_url ~= url) do
            event, event_url, ok, failure_reason = os.pullEvent("http_check")
        end
        if ok ~= true then
            error(string.format("Can't request '%s', %s", url, tostring(failure_reason)), 2)
        end
    end

    print(string.format("Connecting to '%s'", url))
    local ws, err = http.websocket({
        url = url,
        timeout = 10
    })
    if ws == false then
        error(err, 2)
    end

    return ws
end

local function main(host)
    expect(1, host, "string", "nil")

    log("starting")

    local cfg = getCfg()
    if (host == nil) then
        if (cfg.defaultHost ~= nil) then
            host = cfg.defaultHost
        else
            error("No host given")
        end
    end

    if not host:match(".+%:%d+$") then
        host = host .. ":338"
    end

    local ws = connectWs(host)
    local redirect = headlessRedirect.new()
    local originalRedirect = term.redirect(redirect)
    local ok, err = pcall(
            parallel.waitForAny,
            function()
                shell.run(cfg.shell)
            end,
            function()
                while true do
                    pollEvent(ws, redirect)
                end
            end,
            function()
                local sleepTime = 1.0 / cfg.updateRate
                while true do
                    os.sleep(sleepTime)
                    if redirect.dirty then
                        redirect.buffer:debugAssertScreenSize()
                        local packet = deflate:CompressZlib(textutils.serialiseJSON(redirect))
                        if packet == nil then
                            error("Something went wrong.", 2)
                        end
                        ws.send(packet, true)
                        redirect.dirty = false
                    end

                end
            end
    )
    term.redirect(originalRedirect)
    ws.close()
    if ok ~= true and err ~= "Terminated" then
        error(err, 2)
    else
        print("Goodbye!")
    end
end

main(...)