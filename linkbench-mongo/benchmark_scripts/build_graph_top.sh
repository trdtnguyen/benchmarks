#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -o - | blkparse -i - > trace.txt
datafile=$1
xmin=-1
xmax=-1
ymin=-1
ymax=-1
outfile=$2

gnuplot << EOF
set te jpeg giant size 800,600;
set output '$outfile.jpeg';

set xlabel "Time (s)";
set ylabel "Percentage (%)";
#set y2label "%";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

set pointsize 0.2;
#set autoscale
#if( '${xmin}' != -1 && '${xmax}' != -1) {
#	set xrange ['${xmin}':'${xmax}'];
#}
#if( '${ymin}' != -1 && '${ymax}' != -1) {
#	set yrange ['${ymin}':'${ymax}'];
#}
#set xrange and scale
#set xrange [1 : 12]
#set x2range [1 :12]
#set autoscale y
set yrange [0 : 100]
#set autoscale y2
#set y2range [0 : 100]

#set ytics nomirror
#set y2tics
#set tics out

plot '${datafile}' u 1:3 ti "us" , \
'${datafile}' u 1:5 ti "sy" , \
'${datafile}' u 1:7 ti "idle" , \
'${datafile}' u 1:9 ti "wa" , \
;

#plot '${datafile}' u 1:3 with lines ti "us" , \
#'${datafile}' u 1:5 with lines ti "sy" , \
#'${datafile}' u 1:7 with lines ti "idle" , \
#'${datafile}' u 1:9 with lines ti "wa" , \
#;
EOF

