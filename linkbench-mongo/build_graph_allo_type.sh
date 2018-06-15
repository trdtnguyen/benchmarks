#!/bin/sh                                                                                                                                                                              
#page type: 6: internal page, 7: leaf page, 8: root page, 9: extend page
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
temp1='allo_temp1'
temp2='allo_temp2'
temp3='allo_temp3'
xmin=-1
xmax=1000000000000
ymin=-1
ymax=-1
outfile=$2

if [ -n "$3" ]; then
	xmin=$3
fi
if [ -n "$4" ]; then
	xmax=$4
fi
if [ -n "$5" ]; then
	ymin=$5
	echo Variable 'yminxxx' is ${ymin}
fi
if [ -n "$6" ]; then
	ymax=$6
fi
echo "extracting data ..."
grep 'ycsb/collection' ${datafile} |  awk  '{
if ($13 == "append" && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $2/1000,  $9/512, $7, $11) > "'"${temp1}"'" 
else if ($13 == "first-fit" && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $2/1000,  $9/512, $7, $11) > "'"${temp2}"'" 
else if ($13 == "best-fit" && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $2/1000,  $9/512, $7, $11) > "'"${temp3}"'"
}' 
#count hot offsets in leaf pages

#awk  '{ h[$3]++}; END { for (k in h) printf("%s\t%s\n", k, h[k]) }' ${temp2}  > ctemp1 
#sort -k 2 ctemp1 > count_leaf_hot_offset.txt

#else if ($7 == 9) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) > "temp4" 

#grep 'ycsb/index' ${datafile} |  awk  '{
#if ($7 == 6) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) > "temp11" 
#else if ($7 == 7) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) > "temp12" 
#else if ($7 == 8) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) > "temp13" 
#else if ($7 == 9) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) > "temp14" 
#}' 

#sudo grep 'page_type 6' ${datafile} | awk  '/ycsb\/collection/ { printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp1} 
#sudo grep 'page_type 7' ${datafile} | awk  '/ycsb\/collection/ { printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp2} 
#sudo grep 'page_type 8' ${datafile} | awk  '/ycsb\/collection/ { printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp3} 
#sudo grep 'page_type 9' ${datafile} | awk  '/ycsb\/collection/ { printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp4} 
echo "plotting..."

gnuplot << EOF
set te jpeg giant size 800,600;
#set te jpeg giant size 1024,768;
set xlabel "Timestamp (second)";
#set xlabel "sequences";
set pointsize 0.2;

if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
set ylabel "Logical Sector Number";
set style line 1 pt 7 lc rgb "#23B87058";
set style line 2 pt 7 lc rgb "#2358A0B8";
set style line 3 pt 7 lc rgb "#10B075";
set style line 4 pt 7 lc rgb "#96F3FA";

set output '${outfile}_allo.jpeg';
plot '${temp1}' u 1:2 ls 1 ti "append",  '${temp2}' u 1:2 ls 2 ti "first-fit",  '${temp3}' u 1:2 ls 3 ti "best-fit";

set output '${outfile}_allo1.jpeg';
plot '${temp1}' u 1:2 ls 1 ti "append";

set output '${outfile}_allo2.jpeg';
plot '${temp2}' u 1:2 ls 2 ti "first-fit";

set output '${outfile}_allo3.jpeg';
plot '${temp3}' u 1:2 ls 3 ti "best-fit";

EOF
