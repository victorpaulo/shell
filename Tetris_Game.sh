#!/bin/bash
# Tetris Game  // The Art Of Shell Programming

############################################################################################
#                                                                                          #
#   License: GPLv3+                                                                        #
#   Project: https://github.com/yongye/shell                                               #
#   Author : YongYe <complex.invoke@gmail.com>                                             #
#   Version: 7.0 11/01/2011 BeiJing China [Updated 12/12/2012]                             #
#                                                                                          #
#                                                                         [][][]           #
#   Algorithm:  [][][]                                                [][][][]             #
#               []                  [][][]                      [][][]    [][]             #
#   [][] [][]   []  [][][][]  [][][][][]    [][]              [][][]      []   [][] [][]   #
#   [] row []   []  [] (x-m)*zoomx  [][]    []  cos(a) -sin(a)  [][]      []   []  m  []   #
#   []     [] = []  []              []   *  []                  []        [] + []     []   #
#   [] col []   []  [] (y-n)*zoomy  []      []  sin(a)  cos(a)  []        []   []  n  []   #
#   [][] [][]   []  [][][][]  [][][][]      [][]              [][]        []   [][] [][]   #
#               []                                                        []               #
#               [][][]                                                [][][]               #
#                                                                                          #
############################################################################################

box0=(4 30)
box1=(4 30 4 32)
box2=(4 30 5 32)
box3=(4 28 4 30 4 32)
box4=(4 28 4 30 5 30)
box5=(4 28 5 30 6 32)
box6=(4 30 5 28 5 32)
box7=(4 28 5 30 6 32 7 34)
box8=(4 30 5 28 5 30 5 32)
box9=(4 30 5 28 5 32 6 30)
box10=(4 28 4 30 4 32 4 34)
box11=(4 28 5 28 5 30 5 32)
box12=(4 28 4 30 5 30 5 32)
box13=(4 28 4 30 5 28 5 30)
box14=(4 28 4 34 5 30 5 32)
box15=(4 26 4 28 4 30 4 32 4 34)
box16=(4 30 5 28 5 30 5 32 6 30)
box17=(4 28 4 32 5 30 6 28 6 32)
box18=(4 28 4 32 5 28 5 30 5 32)
box19=(4 28 4 30 5 30 6 30 6 32)
box20=(4 28 5 28 6 28 6 30 6 32)
box21=(4 28 4 30 5 30 5 32 6 32)
box22=(4 26 4 34 5 28 5 30 5 32)
box23=(4 26 4 34 5 28 5 32 6 30)
box24=(4 26 5 28 6 30 7 32 8 34)
box25=(4 28 4 32 5 26 5 30 5 34)
box26=(4 28 4 34 5 30 5 32 6 30 6 32 7 28 7 34)
box27=(4 30 5 28 5 32 6 26 6 30 6 34 7 28 7 32 8 30)
box28=(4 30 5 28 5 30 5 32 6 26 6 28 6 30 6 32 6 34 7 28 7 30 7 32 8 30)
box29=(4 30 5 30 6 28 6 30 6 32 7 26 7 30 7 34 8 30 9 30 10 30 11 30 12 30)
box30=(4 26 4 28 4 30 4 34 5 30 5 34 6 26 6 28 6 30 6 32 6 34 7 26 7 30 8 26 8 30 8 32 8 34)
box31=(4 30 5 28 6 26 6 34 7 28 7 32 7 36 8 22 8 30 8 38 9 24 9 28 9 32 10 26 10 34 11 32 12 30)

unit=[]
toph=3
modw=5
wthm=55
dist=61
width=25
lower=33
height=30
scorelevel=0
prelevel=${3:-6} 
speedlevel=${4:-0}
BOX=(box{0..31}[@])
((prelevel=prelevel<1?6:prelevel))
((speedlevel=speedlevel>30?0:speedlevel))
gmover="\e[?25h\e[36;26HGame Over!\e[0m\n"
coltab=(1\;{30..38}\;{40..48}m {38,48}\;5\;{0..255}\;1m)

get.pause(){ kill -${1} ${pid}; }
get.check(){ (( ! map[index] )) && k=1; }
run.initi(){ ((map[index]=pam[index]=0)); }
get.piece(){ box=(${!BOX[RANDOM%runlevel]}); }
get.erase(){ printf "${oldpie//${unit}/  }\e[0m\n"; }
get.resum(){ stty ${oldtty}; printf "\e[?25h\e[36;4H\n"; }
get.stime(){ (( ${1} == ${2} )) && { ((++${3})); ((${1}=0)); }; }
run.prbox(){ oldpie="${cdn}"; printf "\e[${colpie}${cdn}\e[0m\n"; }
get.point(){ ((${1}=mid[${#mid[@]}/2])); ((${2}=mid[${#mid[@]}/2${3}1])); }
run.compr(){ (( ${1} <= ${2} )) && { ((${5})); (( ${3} < ${4} )) && ((${6})); }; }
run.level(){ lhs=${#BOX[@]}; rhs=${1:-$((lhs-1))}; ((runlevel=(rhs < 0 || rhs > lhs-1)?lhs:rhs+1)); }
run.leave(){ (( ! ${#} )) && printf "${gmover}" || { (( ${#}%2 )) && get.pause 22; get.resum; }; exit; }

lower.side()
{
   local i row col
   for((i=0; i!=${#box[@]}; i+=2)); do
      (( col[box[i+1]] < box[i] )) && ((col[box[i+1]]=box[i]))
         row[box[i+1]]="${col[box[i+1]]} ${box[i+1]}"
   done
   max=(${row[@]})
}

get.update()
{ 
   pos="\e[${i};${j}H"
   (( ! map[index] )) && printf "${pos}  " || printf "${pos}\e[${pam[index]}${unit}\e[0m"
}

ini.loop()
{
   local i j k l index
   for((i=4,j=6,l=54; i<=lower; j+=2)); do
        k=0; ((index=(i-4)*width+j/2-toph)); ${1}
        if (( k || j == l )); then
              (( ! k )) && ${2}
              j=4; ((++i))
        fi
   done
}

map.piece()
{
   local j u p q 
   ((++line))
   for((j=i-1,u=6; j>=toph+1; u+=2)); do
        ((p=(j-toph)*width+u/2-toph)); ((q=p-width))
        ((map[p]=map[q])); pam[p]="${pam[q]}"
        (( u == l )) && { u=4; ((--j)); }
   done
   for((u=6; u<=l; u+=2)); do
        ((map[u/2-toph]=0))
   done
}

get.preview()
{
   local i vor clo
   vor=(${!1})
   for((i=0; i!=${#vor[@]}; i+=2)); do
        ((clo=vor[i+1]-(${3}-dist)))
        smobox+="\e[$((vor[i]-1));${clo}H${unit}"
   done
   printf "${!2//${unit}/  }\e[${!4}${smobox}\e[0m\n"
}

pipe.piece()
{
   smobox=""
   (( ${5} )) && {
   get.piece
   eval ${1}="(${box[@]})"
   colpie="${coltab[RANDOM%${#coltab[@]}]}"
   eval ${6}=\"${colpie}\"
   get.preview box[@] ${3} ${4} colpie
   } || {
   eval ${1}="(${!2})"
   eval ${6}=\"${!7}\"
   get.preview ${2} ${3} ${4} ${7}
   }
   eval ${3}=\"${smobox}\"
}

get.invoke()
{
   local i arya aryb
   for((i=0; i!=prelevel-1; ++i)); do
        arya=(rpvbox$((i+1)) rpvbox$((i+2))[@] pvbox$((i+1)))
        aryb=($((12*(2-i))) ${1} s${arya[0]} srpvbox$((i+2))) 
        pipe.piece ${arya[@]} ${aryb[@]} 
   done
}

show.piece()
{
   local smobox 
   colpie="${srpvbox1}"
   olbox=(${rpvbox1[@]})
   get.invoke ${#}
   smobox=""
   get.piece
   eval rpvbox${prelevel}="(${box[@]})"
   eval srpvbox${prelevel}=\"${coltab[RANDOM%${#coltab[@]}]}\"
   get.preview box[@] crsbox $(((3-prelevel)*12)) srpvbox${prelevel}
   crsbox="${smobox}"
   box=(${olbox[@]})
}

draw.piece()
{
   (( ${#} )) && {
      get.piece
      colpie="${coltab[RANDOM%${#coltab[@]}]}"
      coor.dinate box[@]
   } || {
   colpie="${srpvbox1}"
   coor.dinate rpvbox1[@]
   }
   run.prbox 
   if ! move.piece; then
        kill -22 ${PPID}
        get.pause 22
        run.leave
   fi
}

run.bmob()
{
   local i x y u v 
   ((u=vor[0]))
   ((v=vor[1]))
   for((i=0; i!=${#vor[@]}; i+=2)); do
        run.compr x vor[i] y vor[i+1] x=vor[i] y=vor[i+1]   
        run.compr vor[i] u vor[i+1] v u=vor[i] v=vor[i+1]
   done
   if (( x-u == 3 && y-v == 6 )); then
         vor=($((x-3)) $((y-6)) $((x-3)) ${y} ${x} $((y-6)) ${x} ${y})
   fi
}

run.bomb()
{
   local j p q bom scn sbos index boolp boolq
   sbos="\040\040"
   bom=(x-1 y-2 x-1 y x-1 y+2 x y-2 x y x y+2 x+1 y-2 x+1 y x+1 y+2)
   for((j=0; j!=${#bom[@]}; j+=2)); do
        ((p=bom[j]))
        ((q=bom[j+1]))
        ((index=(p-4)*width+q/2-toph))
        boolp="p > toph && p <= lower"
        boolq="q <= wthm && q > modw"
        if (( boolp && boolq )); then
              (( ! map[index] && p+q != x+y && ${1} != 8 )) && continue
              scn+="\e[${p};${q}H${sbos}"
              run.initi 
        fi
   done
   sleep 0.03; printf "${scn}\n"
} 

random.piece()
{
   local i j k 
   ((++count))
   for((i=0,j=6; i!=count; j+=2)); do
        ((k=(29-i)*25+j/2-3))
        (( j == 54 )) && { j=4; ((++i)); }
        (( RANDOM%2 )) && { map[k]=1; pam[k]="${coltab[RANDOM%${#coltab[@]}]}"; }
   done
   (( count == 29 )) && count=0
}

del.row()
{
   local i x y len num vor index line
   vor=(${locus[@]})
   len=${#vor[@]}
   (( len == 16 )) && run.bmob
   for((i=0; i!=${#vor[@]}; i+=2)); do
        ((x=vor[i]))
        ((y=vor[i+1]))
        (( len == 16 )) && run.bomb ${#vor[@]} || {
           ((index=(x-4)*width+y/2-toph))
           ((map[index]=1))
           pam[index]="${colpie}"
        }
   done
   line=0
   ini.loop get.check map.piece
   (( ! line )) && return
   ((num=line*200-100))
   printf "\e[1;34m\e[$((toph+10));$((dist+49))H$((scorelevel+=num))\e[0m\n"
   if (( scorelevel%5000 < num && speedlevel < 30 )); then
         random.piece
         printf "\e[1;34m\e[$((toph+10));$((dist+30))H$((++speedlevel))\e[0m\n"
   fi
   ini.loop get.update
}        

get.ctime()
{
   local i d h m s vir Time color
   trap "run.leave" 22 
   ((d=0, h=0, m=0, s=0))
   vir=----------------
   color="\e[1;33m"
   printf "\e[2;6H${color}${vir}[\e[2;39H${color}]${vir}\e[0m\n"
   while :; do
         sleep 1 &
         get.stime s 60 m
         get.stime m 60 h
         get.stime h 24 d
         for i in ${d} ${h} ${m} ${s}; do
             (( ${#i} != 2 )) && Time[i]="0${i}" || Time[i]="${i}"
         done    
         printf "\e[2;23H${color}Time ${Time[d]}:${Time[h]}:${Time[m]}:${Time[s]}\e[0m\n"
         wait; ((++s))
   done
}
 
per.sig()
{
   local i j pid sig sigswap
   pid=${1} 
   for i in {23..31}; do
       trap "sig=${i}" ${i}
   done
   trap "get.pause 22; run.leave" 22
   while (( ++j )); do 
         (( j != 1 )) && sleep 0.02
         sigswap=${sig}
         sig=0
         case ${sigswap} in
         23)  per.transform   -1                  ;;
         24)  per.transform    1                  ;;
         25)  per.transform   -2                  ;;
         26)  per.transform    1/2                ;;
         27)  per.transform    0             -2   ;;
         28)  per.transform    0              2   ;;
         29)  per.transform    1              0   ;;
         30)  per.transform   -1              0   ;;
         31)  per.transform    $(run.bottom)  0   ;;
         esac
         (( j == 31-speedlevel )) && { per.transform  1  0; j=0; }
   done
}

get.sig()
{
   local sig pid key arry pool oldtty
   printf "\e[?25l"
   pid=${1}; arry=(0 0 0)
   pool="$(printf "\e")"; oldtty="$(stty -g)"
   trap "run.leave 0" INT TERM; trap "run.leave 0 0" 22
   while read -s -n 1 key; do
         arry[0]=${arry[1]}; arry[1]=${arry[2]}
         arry[2]=${key}; sig=0
         if   [[ ! "${key}" ]]; then sig=31      
         elif [[ "${key}${arry[1]}" == "${pool}${pool}" ]]; then run.leave 0
         elif [[ "${arry[0]}" == "${pool}" && "${arry[1]}" == "[" ]]; then
                 case ${key} in
                 A)    sig=23         ;;
                 B)    sig=29         ;;
                 D)    sig=27         ;;
                 C)    sig=28         ;;
                 esac
         else
                 case ${key} in
                 W|w)  sig=23         ;;
                 T|t)  sig=24         ;;
                 M|m)  sig=25         ;;
                 N|n)  sig=26         ;;
                 S|s)  sig=29         ;;
                 A|a)  sig=27         ;;
                 D|d)  sig=28         ;; 
                 U|u)  sig=30         ;; 
                 P|p)  get.pause  19  ;;
                 R|r)  get.pause  18  ;;
                 Q|q)  run.leave   0  ;;
                 esac
         fi
                 (( sig != 0 )) && get.pause ${sig}
   done
}

run.bottom()
{  
   local i j max col row 
   lower.side
   for((i=0,j=0; i!=height; j+=2)); do
        row="max[j]+i == lower"
        col="map[(max[j]+i-toph)*width+max[j+1]/2-toph]"
        (( col || row )) && { echo ${i}; return; }
        (( j+2 == ${#max[@]} )) && { j=-2; ((++i)); }
   done
}

move.piece()
{
   local i j x y index boolx booly 
   len=${#locus[@]}
   for((i=0; i!=len; i+=2)); do    
        ((x=locus[i]+dx)) 
        ((y=locus[i+1]+dy))
        ((index=(x-4)*width+y/2-toph))
        (( index < 0 || index > 749 )) && return 1
        boolx="x <= toph || x > lower"
        booly="y > wthm || y <= modw"
        (( boolx || booly )) && return 1
        if (( map[index] )); then
              if (( len == 2 )); then
                    for((j=lower; j>x; --j)); do
                         (( ! map[(j-4)*width+y/2-toph] )) && return 0
                    done
              fi
              return 1
        fi
   done 
   return 0  
}

run.cross()
{
   local i j index
   ((i=locus[0]))
   ((j=locus[1]))
   ((index=(i-4)*width+j/2-toph))
   (( map[index] )) && printf "\e[${i};${j}H\e[${pam[index]}${unit}\e[0m\n"
}

coor.dinate()
{
   local i
   locus=(${!1})
   for((i=0; i!=${#locus[@]}; i+=2)); do    
        cdn+="\e[${locus[i]};${locus[i+1]}H${unit}"
   done
}

get.optimize()
{
   for j in dx dy; do
       (( j )) && { [[ ${j} == dx ]] && k=i || k=i+1; ${1}; }
   done
}

add.box()
{
   for((i=0; i!=${#vbox[@]}; i+=2)); do
        ((vbox[k]+=j))
   done
}

per.plus()
{
   local i j k
   (( len == 2 )) && run.cross
   vbox=(${box[@]})
   get.optimize add.box
   coor.dinate vbox[@]
   box=(${vbox[@]})
}

get.move()
{
   if move.piece; then
        get.erase
        per.plus
        run.prbox
   else
        (( dx == 1 )) && {
        del.row  
        draw.piece 
        show.piece
        }
   fi
}

mid.point()
{
   local mid
   mid=(${!1})
   (( ${#mid[@]}%4 )) && get.point ${3} ${2} - || get.point ${2} ${3} +
}

per.multiple()
{
   local i mid vor
   mid=(${!1})
   vor=(${!1})
   for((i=0; i!=${#mid[@]}-2; i+=2)); do
        ((mid[i+3]=mid[i+1]+(vor[i+3]-vor[i+1])${2}2))
   done
   vbox=(${mid[@]})
}

run.unique()
{
   local i mid
   declare -A mid
   for((i=0; i!=${#log[@]}; i+=2)); do
        mid[${log[i]}::${log[i+1]}]="${log[i]} ${log[i+1]}"
   done
   log=(${mid[@]})
}

per.algorithm()
{
   local i                               # row=(x-m)*zoomx*cos(a)-(y-n)*zoomy*sin(a)+m
   for((i=0; i!=${#vbox[@]}; i+=2)); do  # col=(x-m)*zoomx*sin(a)+(y-n)*zoomy*cos(a)+n
        ((log[i]=m+vbox[i+1]-n))         # a=-pi/2 zoomx=+1 zoomy=+1 dx=0 dy=0
        ((log[i+1]=(vbox[i]-m)*${dx}+n)) # a=-pi/2 zoomx=-1 zoomy=+1 dx=0 dy=0 
   done                                  # a=+pi/2 zoomx=+1 zoomy=-1 dx=0 dy=0
   [[ ${dx} == 1/2 ]] && run.unique 
}

mid.plus()
{
   local i j k dx dy
   ((dx=mp-p))
   ((dy=nq-q))
   get.optimize add.box
}

per.abstract()
{
   per.multiple ${1} "${2}"
   mid.point vbox[@] ${3} ${4} 
}

per.rotate()
{     
   local m n p q mp nq log
   (( arg == 2 )) && return
   mid.point box[@] mp nq 
   per.abstract box[@] "/" m n
   per.algorithm; dx=0
   per.abstract log[@] "*" p q
   mid.plus; locus=(${vbox[@]})
   if move.piece; then
       get.erase; coor.dinate vbox[@]
       run.prbox; box=(${locus[@]})
   else
       locus=(${box[@]})
   fi
}

per.transform()
{ 
   local dx dy cdn len arg vbox 
   dx=${1}
   dy=${2}
   arg=${#}
   (( arg == 2 )) && get.move || per.rotate 
}

show.matrix()
{
   one=" "
   sr="\e[0m"
   trx="[][]"
   two="${one}${one}"
   tre="${one}${two}"
   cps="${two}${tre}"
   spc="${cps}${cps}"         
   equ="\e[38;5;191;1m"
   colbon="\e[38;5;47;1m"
   mcol="\e[38;5;30;1m"
   fk5="${spc}${spc}"
   fk4="${mcol}[]${sr}"
   fk0="${colbon}[]${sr}"
   fk1="${colbon}${trx}${sr}"
   fk6="${mcol}[]${trx}${sr}"
   fk2="${colbon}[]${trx}${sr}"
   fk3="${colbon}${trx}${trx}${sr}"
   fk="${tre}${fk0}${two}${fk3}${two}${fk3}"
   fk7="${fk1}${one}${fk1}${fk}${fk4}${two}${two}"
   fk8="${fk0}${one}${equ}row${one}${fk0}${tre}${fk0}${two}${fk0}${one}${equ}(x-m)*zoomx${two}"
   fk9="${one}${equ}=${one}${fk0}${two}${fk0}${spc}${tre}${one}${fk0}${tre}${equ}*${two}"
   fk10="${spc}${cps}${two}${fk0}${two}${fk0}${one}${equ}+${one}${fk0}${cps}${fk0}"
   fk11="${tre}${one}${fk0}${two}${equ}cos(a)${one}${equ}sin(a)${two}${fk0}${two}${fk0}${tre}${fk0}${two}${equ}m${two}${fk0}"
   fk12="${one}${equ}col${one}${fk0}${tre}${fk0}${two}${fk0}${one}${equ}(y-n)*zoomy${two}${fk0}${cps}${one}"
   fk13="${one}${equ}-sin(a)${one}${equ}cos(a)${two}${fk0}${two}${fk0}${tre}${fk0}${two}${equ}n${two}${fk0}"
   fk14="${fk1}${one}${fk1}${fk}${cps}${one}"
   fk15="${fk1}${two}${fk0}${tre}${fk1}${one}${fk1}"
   printf "\e[$((toph+23));${dist}H${colbon}Algorithm:${two}${fk2}${one}${fk5}${fk5}${fk2}${fk4}\n"
   printf "\e[$((toph+30));${dist}H${spc}${two}${fk0}${two}${two}${cps}${fk5}${fk5}${fk0}\n"
   printf "\e[$((toph+25));${dist}H${fk7}${fk1}${spc}${tre}${fk1}${two}${fk0}${tre}${fk1}${one}${fk1}\n"
   printf "\e[$((toph+26));${dist}H${fk8}${fk0}${fk4}${fk11}\e[$((toph+28));${dist}H${fk0}${fk12}${fk0}${fk13}\n"
   printf "\e[$((toph+24));${dist}H${two}${spc}${fk0}${spc}${tre}${two}${tre}${fk6}${fk5}${cps}${fk0}${fk4}\n"
   printf "\e[$((toph+22));${dist}H${tre}${fk5}${fk5}${fk5}${fk6}\e[$((toph+29));${dist}H${fk14}${fk1}${spc}${tre}${fk15}\n"
   printf "\e[$((toph+27));${dist}H${fk0}${cps}${fk0}${fk9}${fk0}${fk10}\e[$((toph+31));${dist}H${spc}${two}${fk2}${fk5}${fk5} ${fk2}\n"
}

show.boundary()
{
   clear
   boucol="\e[38;5"
   ((color=RANDOM%145+6))
   for((i=6; i<=wthm; i+=2)); do
        printf "${boucol};$((color+i));1m\e[${toph};${i}H==${boucol};$((color+i+25));1m\e[$((lower+1));${i}H==\e[0m\n"
   done
   for((i=toph; i<=lower+1; ++i)); do
        printf "${boucol};$((color+i));1m\e[${i};$((modw-1))H||${boucol};$((color+i+30));1m\e[${i};$((wthm+1))H||\e[0m\n"
   done
}

show.instruction()
{
   printf "\e[1;31m\e[$((toph+9));${dist}HRunLevel\e[1;31m\e[$((toph+9));$((dist+15))HPreviewLevel\e[0m\n"
   printf "\e[1;31m\e[$((toph+9));$((dist+30))HSpeedLevel\e[1;31m\e[$((toph+9));$((dist+49))HScoreLevel\e[0m\n"
   printf "\e[1;34m\e[$((toph+10));$((dist+49))H${scorelevel}\e[1;34m\e[$((toph+10));$((dist+30))H${speedlevel}\e[0m\n"
   printf "\e[1;34m\e[$((toph+10));${dist}H$((runlevel-1))\e[1;34m\e[$((toph+10));$((dist+15))H${prelevel}\e[0m\n"
   printf "\e[38;5;34;1m\e[$((toph+12));${dist}HM|m      ===   double         N|n          ===   half\n"
   printf "\e[$((toph+13));${dist}HQ|q|ESC  ===   exit           U|u          ===   one step up\n"
   printf "\e[$((toph+14));${dist}HP|p      ===   pause          S|s|down     ===   one step down\n"
   printf "\e[$((toph+15));${dist}HR|r      ===   resume         A|a|left     ===   one step left\n"
   printf "\e[$((toph+16));${dist}HW|w|up   ===   rotate         D|d|right    ===   one step right\n"
   printf "\e[$((toph+17));${dist}HT|t      ===   transpose      Space|enter  ===   drop all down\n"
   printf "\e[38;5;106;1m\e[$((toph+19));${dist}HTetris Game  Version 7.0\n"
   printf "\e[$((toph+20));${dist}HYongYe <complex.invoke@gmail.com>\e[$((toph+21));${dist}H11/01/2011 BeiJing China [Updated 12/12/2012]\n"
}

   case ${1} in
   -h|--help)    echo "Usage: bash ${0} [runlevel] [previewlevel] [speedlevel]"
                 echo "Range: [ 0 =< runlevel <= $((${#BOX[@]}-1)) ]   [ previewlevel >= 1 ]   [ speedlevel <= 30 ]" ;;
   -v|--version) echo "Tetris Game  Version 7.0 [Updated 12/12/2012]" ;;
   ${PPID})      run.level ${2}; ini.loop run.initi 
                 show.boundary; show.instruction
                 show.piece 0; draw.piece 0
                 show.matrix; get.ctime &
                 per.sig ${!} ;;
   *)            bash ${0} ${$} ${@} &
                 get.sig ${!} ;;
   esac
