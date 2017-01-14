#!/bin/bash 
#functions
getkeyn()
{
i=1
k=`sed -n '3p' $pathh/$dname/$tname`
nf=`echo $k| awk -F: '{print NF}'`
echo $nf

while [ $i -le $nf ]
do
v3=`echo $k |cut -d: -f$i`
if [ $v3 != 0 ]
then
 ka=$v3
fi
let "i+=1"
done
}
validate()
{
vf=0
vfk=0
v=`sed -n '2p' $pathh/$dname/$tname`
k=`sed -n '3p' $pathh/$dname/$tname`
nf=`echo $1| awk -F: '{print NF}'`
i=1
while [ $i -le $nf ]
do
v1=`echo $1 |cut -d: -f$i`
v2=`echo $v |cut -d: -f$i`
v3=`echo $k |cut -d: -f$i`
cktype $v1
if [ $v3 != 0 ]
then 
ckunique  $v1 $v3
fi
if [ $typee = $v2 ]
then
fake=0
else 
vf=1
fi
let "i+=1"
done
}

ckunique()
{
uni=`cut -d: -f$2 $pathh/$dname/$tname`
for j in $uni
do 
if [ $1 = $j ]
then
vfk=1
fi
done
}

cktype()
{
if [[ $1 = *[!0-9]* ]];
then
typee="str"
else
typee="int"
fi
}

isin ()
{
for i in $2
do
if [ $1 = $i ]
then f=1
else
m=0
fi
done
}

isexsit ()
{
while [[ $2 == *"$1"* ]]
do
echo  already exist
done
}
deletee()
{
 delll=("del table" "del row" "exit")
while true
do
clear
select ccc in "${delll[@]}"
do
case $ccc in
"del table") 
rm $pathh/$dname/$tname
echo table $tname deleted
sleep 1
break 2
;;
"del row")
echo enter row key
read row
getkeyn
cp $pathh/$dname/$tname $pathh/$dname/temp
awk -F: -v var="$row" -v num="$ka"  '{ if (NR<4){print $0} else { if ( $num != var ) { print $0; }} }' $pathh/$dname/temp > $pathh/$dname/$tname
rm $pathh/$dname/temp
#echo row deleted
#sleep 1
break
;;
"exit")
break 2
;;
*)
echo not an option
break 
;;
esac
done
done
}

insert ()
{
vf=1
while [ $vf -eq 1 ] || [ $vfk -eq 1 ]
do
clear 
echo enter data as seen
echo `sed -n '1p' $pathh/$dname/$tname`
read inn
validate $inn
if [ $vf -eq 1 ]  
then
echo error: wrong datatype
sleep 1
fi
if [ $vfk -eq 1 ]  
then
echo error: key is not unique
sleep 1
fi
done
}

insertt()
{

while [ $f -eq 0 ]
do
clear
echo tables:$tnames
echo no such table please enter again
read tname
isin $tname "$tnames"
done
insert
echo $inn >>$pathh/$dname/$tname
clear
echo row added
sleep 1
inss=("insert again" "done")
while true
do
clear
select ch in "${inss[@]}"
do
case $ch in
"insert again")
insert
echo $inn >>$pathh/$dname/$tname
echo row added
sleep 1
break
;;
"done")
break 2
;;
*)
echo not an option
break
;;
esac
done
done
}
opendb2()
{
 opendbb=("insert" "modify" "display" "delete" "exit db" );
while true
do
clear
select ch in "${opendbb[@]}"
do
case $ch in
"insert")
insertt
break
;;
"modify")
#
clear 
echo enter row to modify
read row
insert

getkeyn
cp $pathh/$dname/$tname $pathh/$dname/temp
awk -F: -v var="$row" -v num="$ka" -v mod="$inn"  '{ if (NR<4){print $0} else { if ( $num != var ) { print $0; } else print inn; } }' $pathh/$dname/temp > $pathh/$dname/$tname
rm $pathh/$dname/temp
echo modified 
sleep 1

#
break
;;
"display")
awk '{if (NR==3 ||NR==2);else print $0;}' $pathh/$dname/$tname
read fake
break
;;
"delete")
deletee
break
;;
"exit db")
break 2
;;
*)
echo not an option
break
;;
esac
done
done
}

opendb ()
{
dnames=`ls $pathh`
clear
echo databases:$dnames
echo enter database name
read dname
f=0
isin $dname "$dnames"
while [ $f -eq 0 ]
do
clear
echo databases:$dnames
echo no such database please enter again
read dname
isin $dname "$dnames"
done


clear

dd=($(ls $pathh/$dname))
while true
do
clear
echo choose table:
select opt in "${dd[@]}" "Quit" ;
do
if (( REPLY == 1 + ${#dd[@]} )) ; 
then
break 2
elif (( REPLY > 0 && REPLY <= ${#dd[@]} )) ; 
then
tname=$opt
opendb2
break
else
echo "Invalid option"
fi
done
done


}

addcol ()
{
echo enter col name:
read cname
#cnames=`cut -d: -f2- $pathh/$dname/$dname.meta`
meta+="$cname:"
select ch in "${typee[@]}"
do
case $ch in
"string")
dmeta+="str:"
break 
;;
"integer")
dmeta+="int:"
break 
;;
*)
echo not an option

;;
esac
done
kmeta+="$key:"
clear 
echo col added
sleep 1
}


creattb ()
{
tmanes=`cut -d: -f1 $pathh/$dname/$dname.meta`
echo enter table name:
read tname
isexsit $tname $tnames
echo enter num of col.
read ncol
meta=" "
dmeta=" "
kmeta=" "
typee=("string" "integer")
iskey=0
key=0
counter=1
# $pathh/$dname/$dname.meta


creatt=("add new col"  "add pkey col" "done" )
while true 
do
clear
select ch in "${creatt[@]}"
do
case $ch in
"add new col")
key=0
addcol
let "counter+=1"
break
;;
"add pkey col")
key=$counter
if [ $iskey -eq 1 ]
then echo key already added
else 
iskey=1
addcol
let "counter+=1"
break
fi
;; 
"done")
break 2
;;
*)
echo not an option
break
;;
esac
done
if [ $counter -gt $ncol ]
then break
fi
done
touch $pathh/$dname/$tname
echo $meta >>$pathh/$dname/$tname
echo $dmeta >>$pathh/$dname/$tname
echo $kmeta >>$pathh/$dname/$tname
#echo $tname: >>$pathh/$dname/$dname.meta
clear
echo $tname table created
sleep 1
}

creatdb ()
{
echo enter db name:;
read dname;
mkdir -p $pathh/$dname;
touch $pathh/$dname/$dname.meta;

creat=("creat new table"  "exit" );
while true
do
clear
select ch in "${creat[@]}"
do
case $ch in
"creat new table")
creattb
break
;;
"exit")
break 2
;;
*)
echo not an option
break
;;
esac
done
done
clear
echo $dname database created;
sleep 1

}



#functions//


PS3="choose:"
pathh="/home/$(whoami)/ldt"
database=("creat new data base" "open old database" "exit" )
while true
do
clear
select ch in "${database[@]}"
do
case $ch in
"creat new data base")
creatdb

break
;;
"open old database")
opendb
break
;;
"exit")
break 2
;;
*)
echo not an option
break
;;
esac
done
done
