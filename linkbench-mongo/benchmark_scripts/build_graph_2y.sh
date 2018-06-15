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

set xlabel "Buffer pool size (GB)";
set ylabel "Runtime (ms)";
set y2label "Ops/s";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
#set autoscale
#if( '${xmin}' != -1 && '${xmax}' != -1) {
#	set xrange ['${xmin}':'${xmax}'];
#}
#if( '${ymin}' != -1 && '${ymax}' != -1) {
#	set yrange ['${ymin}':'${ymax}'];
#}
#set xrange and scale
set xrange [1 : 12]
set x2range [1 :12]
set autoscale y
set autoscale y2

set ytics nomirror
set y2tics
set tics out

plot '${datafile}' u 3:7  axes x1y1 with linespoint ti "Runtime" , \
'${datafile}' u 3:8 axes x2y2 with linespoint ti "OPS/s";
EOF

