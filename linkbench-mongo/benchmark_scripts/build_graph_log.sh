#!/bin/sh                                                                                                                                                                              
#page type: 6: internal page, 7: leaf page, 8: root page, 9: extend page
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
temp1='templog1'
temp2='templog2'
temp3='templog3'
temp4='templog4'
xmin=-1
xmax=-1
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
sudo grep 'page_type wt_log_release' ${datafile} | awk  '{ printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp1} 
sudo grep 'page_type log_fill' ${datafile} | awk  '{ printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp2} 
sudo grep 'page_type wt_log_zero' ${datafile} | awk  '{ printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp3} 
sudo grep 'page_type wt_log_slot_destroy' ${datafile} | awk  '{ printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp4} 
#sudo grep 'page_type 7' ${datafile} | awk  '/ycsb\/collection/ { printf("%s\t%s\t%s\t%s\n", $1 , $2/1000,  $9/512, $5) }'  > ${temp2} 
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
set style line 1 pt 7 lc rgb "green";
set style line 2 pt 7 lc rgb "red";
set style line 3 ps 1 pt 7 lc rgb "blue";
set style line 4 ps 1 pt 7 lc rgb "#96F3FA";

set output '${outfile}_log.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "wt_log_release",  '${temp2}' u 2:3 ls 2 ti "log_fill", '${temp3}' u 2:3 ls 3 ti "log_zero", '${temp4}' u 2:3 ls 4 ti "wt_log_slot_destroy";

set output '${outfile}_log1.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "wt_log_release";

set output '${outfile}_log2.jpeg';
plot '${temp2}' u 2:3 ls 2 ti "log_fill";

set output '${outfile}_log3.jpeg';
plot '${temp3}' u 2:3 ls 3 ti "log_zero";

set output '${outfile}_log4.jpeg';
plot '${temp4}' u 2:3 ls 4 ti "wt_log_slot_destroy";
EOF
