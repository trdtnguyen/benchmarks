#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -o - | blkparse -i - > trace.txt
datafile=$1
outfile=$2

gnuplot << EOF
set te jpeg giant size 800,600;
set output '$outfile.jpeg';

set title "Tuning optimized number of threads with YCSB workload a"
set xlabel "Number of threads";
set ylabel "Throughput (ops/s)";
set y2label "Avg latency (us)";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
#set autoscale
#set xrange [1 : 12]
#set x2range [1 :12]
set autoscale y
set autoscale y2

set ytics nomirror
set y2tics
set tics out

plot '${datafile}' u 3:7  axes x1y1 with linespoint ti "Throughput (ops/s)" , \
'${datafile}' u 3:11 axes x2y2 with linespoint ti "99th read latency", \
'${datafile}' u 3:15 axes x2y2 with linespoint ti "99th update latency"; 
EOF
