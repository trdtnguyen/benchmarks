#!/bin/sh                                                                                                                                                                              
#./build_graph_page_type.sh my_func_track.txt page_type ${xmin} ${xmax}
# my_func_track.txt is output file when 
#page type: 6: internal page, 7: leaf page, 8: root page, 9: extend page
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
temp11='temp11'
temp12='temp12'
temp13='temp13'
temp14='temp14'
temp21='temp21'
temp22='temp22'
temp23='temp23'
temp24='temp24'
xmin=-1
xmax=1000000000000
ymin=-1
ymax=-1
outfile=$2
#change the prefix value based on YCSB or linkbench (ycsb or linkbench)
prefix=linkbench
coll_prefix=$prefix/collection
idx_prefix=$prefix/index

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
#extract info from blkparse file
#grep 'R,\|RM,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${rtemp}
#grep 'W,\|WS,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${wtemp}

#sudo grep 'R\|RM' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${rtemp}
#sudo grep 'W\|WS' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${wtemp}
echo "extracting data..."

#$1: order, $2: time, $7: page type, $9: offset, $11: size
#page type: 6: internal page, 7: leaf page, 8: root page, 9: extend page
grep $coll_prefix ${datafile} |  awk  '{
if ($7 == 6) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp11"'"
else if ($7 == 7) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp12"'"
else if ($7 == 8) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp13"'"
else if ($7 == 9) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp14"'"
}' 

grep $idx_prefix ${datafile} |  awk  '{
if ($7 == 6) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp21"'"
else if ($7 == 7) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp22"'"
else if ($7 == 8) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp23"'"
else if ($7 == 9) printf("%s\t%f\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11) > "'"$temp24"'"
}' 
echo "counting..."
#count amount of write for each file type
awk '{count+=1; sum+=$4} END {printf("number of writes - size on collection internal page: %s - %s\n", count, sum)}' $temp11
awk '{count+=1; sum+=$4} END {printf("number of writes - size on collection leaf page: %s - %s\n", count, sum)}' $temp12
awk '{count+=1; sum+=$4} END {printf("number of writes - size on collection root page: %s - %s\n", count, sum)}' $temp13
awk '{count+=1; sum+=$4} END {printf("number of writes - size on collection extend page: %s - %s\n", count, sum)}' $temp14


awk '{count+=1; sum+=$4} END {printf("number of writes - size on index internal page: %s - %s\n", count, sum)}' $temp21
awk '{count+=1; sum+=$4} END {printf("number of writes - size on index leaf page: %s - %s\n", count, sum)}' $temp22
awk '{count+=1; sum+=$4} END {printf("number of writes - size on index root page: %s - %s\n", count, sum)}' $temp23
awk '{count+=1; sum+=$4} END {printf("number of writes - size on index extend page: %s - %s\n", count, sum)}' $temp24

rm $temp11 && rm $temp12 && rm $temp13 && rm $temp14
rm $temp21 && rm $temp22 && rm $temp23 && rm $temp24
#remove this line if you want to plot
exit

#grep 'ycsb/collection' ${datafile} |  awk  '{
#if ($7 == 6 && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $11) > "temp1" 
#else if ($7 == 7 && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $11) > "temp2" 
#else if ($7 == 8 && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $11) > "temp3" 
#else if ($7 == 9 && ("'"${xmin} "'" <= $2/1000) && ("'"${xmax} "'" >= $2/1000)) printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $11) > "temp4" 
#}' 

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
set style line 3 ps 3 pt 7 lc rgb "#10B075";
set style line 4 ps 2 pt 7 lc rgb "#96F3FA";

set output '${outfile}.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "Internal",  '${temp2}' u 2:3 ls 2 ti "Leaf",  '${temp3}' u 2:3 ls 3 ti "Root",'${temp4}' u 2:3 ls 4 ti "Extend";

#set output '${outfile}_1.jpeg';
#plot '${temp1}' u 2:3 ls 1 ti "Internal";

#set output '${outfile}_2.jpeg';
#plot '${temp2}' u 2:3 ls 2 ti "Leaf";

#set output '${outfile}_3.jpeg';
#plot '${temp3}' u 2:3 ls 3 ti "Root";

#set output '${outfile}_4.jpeg';
#plot '${temp4}' u 2:3 ls 4 ti "Extend";

#set output '${outfile}_index.jpeg';
#plot '${temp11}' u 2:3 ls 1 ti "IDX Internal",  '${temp12}' u 2:3 ls 2 ti "IDX Leaf",  '${temp13}' u 2:3 ls 3 ti "IDX Root",'${temp14}' u 2:3 ls 4 ti "IDX Extend";

#set output '${outfile}_index1.jpeg';
#plot '${temp11}' u 2:3 ls 1 ti "IDX Internal";

#set output '${outfile}_index2.jpeg';
#plot '${temp12}' u 2:3 ls 2 ti "IDX Leaf";

#set output '${outfile}_index3.jpeg';
#plot '${temp13}' u 2:3 ls 3 ti "IDX Root";

#set output '${outfile}_index4.jpeg';
#plot '${temp14}' u 2:3 ls 4 ti "IDX Extend";
EOF
