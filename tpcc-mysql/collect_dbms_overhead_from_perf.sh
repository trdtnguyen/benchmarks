#!/bin/bash
source const.sh
#Input: the output of precess_perf_record.sh

#Output: The overhead (%) of each coponent in DBMS

in_file=perf.data

if [ -n $1 ]; then
	in_file=$1
	echo "input file is $1"
fi

out_file=dbms_overheads.txt

date=$(date '+%Y%m%d_%H%M%S')

echo "Collecting data..."
printf "Computed $1 on ${date}\n==================================\n" >> $out_file

printf "Memory:\t\t\t\t\t " >> $out_file
var1=$(awk '/mem/ || /alloc/ || /free/ || /strcmp/ || /qsort/ || /dtoa/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var1 \n" >> $out_file

printf "Query Processing:\t\t " >> $out_file
var2=$(awk '/field/ || /item/ || /table/ || /join/ || /JOIN/ || /select/ || /key/ || /statement/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var2 \n" >> $out_file

printf "Transaction Processing:\t " >> $out_file
var3=$(awk '/mtr/ || /commit/ || /trx/ || /Trx/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var3 \n" >> $out_file

printf "Buffer Management:\t\t " >> $out_file
var4=$(awk '/buf/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var4 \n" >> $out_file

printf "Locking:\t\t\t\t " >> $out_file
var5=$(awk '/lock/ || /mutex/ || /Mutex/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var5 \n" >> $out_file

printf "B+Tree/Indexing:\t\t " >> $out_file
var6=$(awk '/btr/ || /row/ || /search/ || /index/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var6 \n" >> $out_file

printf "Log Management:\t\t\t " >> $out_file
var7=$(awk '/log/ || /undo/  {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var7 \n" >> $out_file

printf "File system:\t\t\t " >> $out_file
var8=$(awk '/pfs/ || /file/ {sum1+=$1} END {printf("%s",sum1)}' $in_file)
printf "$var8 \n" >> $out_file

sum=$(awk -v v1="$var1" -v v2="$var2" -v v3="$var3" -v v4="$var4" -v v5="$var5"  -v v6="$var6" -v v7="$var7" -v v8="$var8" 'BEGIN{printf("%s",v1+v2+v3+v4+v5+v6+v7+v8)}')
remain=$(awk -v s=$sum 'BEGIN{printf("%s",100-s)}')

printf "Others:\t\t\t\t\t " >> $out_file
printf "$remain \n" >> $out_file

printf "Sum:\t\t\t\t\t " >> $out_file
printf "$sum \n" >> $out_file
printf "===============================\n" >> $out_file


echo "Finish, see the result in $out_file"
