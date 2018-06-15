#!/bin/sh                                                                                                                                                                              
#./build_graph_size_type.sh my_func_track.txt size_type ${xmin} ${xmax}
# my_func_track.txt is output file when 
#size type: 4096, 28672, 32768
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
temp1='temp1'
temp2='temp2'
temp3='temp3'
temp4='temp4'
temp11='temp11'
temp12='temp12'
temp13='temp13'
temp14='temp14'
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
#extract info from blkparse file
#grep 'R,\|RM,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${rtemp}
#grep 'W,\|WS,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${wtemp}

#sudo grep 'R\|RM' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${rtemp}
#sudo grep 'W\|WS' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${wtemp}
echo "extracting data..."

grep 'ycsb/collection' ${datafile} |  awk  '{
if ($11 == 4096) printf("%s\t%f\t%s\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11, $7) > "temp1" 
else if ($11 == 28672) printf("%s\t%f\t%s\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11, $7) > "temp2" 
else if ($11 == 32768) printf("%s\t%f\t%s\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11, $7) > "temp3" 
else printf("%s\t%f\t%s\t%s\t%s\n", $1 , $2*1.0/1000,  $9/512, $11, $7) > "temp4" 
}' 

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
#set style line 1 pt 2 lc rgb "#23B87058";
set style line 1 pt 2 lc rgb "#ff0000";
set style line 2 pt 2 lc rgb "#2358A0B8";
#set style line 3 ps 2 pt 2 lc rgb "#10B075";
set style line 3 pt 2 lc rgb "#10B075";
set style line 4 pt 2 lc rgb "#96F3FA";

set output '${outfile}.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "4096",  '${temp2}' u 2:3 ls 2 ti "28672",  '${temp3}' u 2:3 ls 3 ti "32768",'${temp4}' u 2:3 ls 4 ti "Others";

set output '${outfile}_1.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "4096";

set output '${outfile}_2.jpeg';
plot '${temp2}' u 2:3 ls 2 ti "28672";

set output '${outfile}_3.jpeg';
plot '${temp3}' u 2:3 ls 3 ti "32768";

set output '${outfile}_4.jpeg';
plot '${temp4}' u 2:3 ls 4 ti "Others";

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
