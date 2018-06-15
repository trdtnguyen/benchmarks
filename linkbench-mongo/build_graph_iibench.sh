#!/bin/sh                                                                                                                                                                              
#./build_graph_page_type.sh my_func_track.txt page_type ${xmin} ${xmax}
# my_func_track.txt is output file when 
#page type: 6: internal page, 7: leaf page, 8: root page, 9: extend page
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
infile=$1
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



echo "plotting..."

gnuplot << EOF
set te jpeg giant size 800,600;
#set te jpeg giant size 1024,768;
set xlabel "elap (second)";
#set xlabel "sequences";
set pointsize 0.2;

if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
set ylabel "ips";
set style line 1 pt 7 lc rgb "#23B87058";
set style line 2 pt 7 lc rgb "#2358A0B8";
set style line 3 ps 3 pt 7 lc rgb "#10B075";
set style line 4 ps 2 pt 7 lc rgb "#96F3FA";

set output '${outfile}.jpeg';
plot '${infile}' u 3:4 ls 1 ti "mongodb";

EOF
