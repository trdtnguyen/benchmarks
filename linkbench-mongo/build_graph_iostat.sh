#!/bin/bash                                                                                                                                                                              
# build graph for output of $ iostat -mx 1
#input tem is the tracking file form iostat -mx 1 > tem
#output plot file
infile=$1
outfile=$2

# time sda rrqm/s wrqm/s r/s w/s rMB/s wMB/s avgrq-sz avgqu-sz await r_await w_await svctm %util
#${infile} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${out_tem}

gnuplot << EOF
set terminal postscript eps color colortext
#set te jpeg giant size 1024,768;
set te jpeg giant size 800,600;

set xlabel "Time (s)";
set ylabel "requests/s";
set y2label "MB/s";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale
#if( '${xmin}' != -1 && '${xmax}' != -1) {
#	set xrange ['${xmin}':'${xmax}'];
#}
#if( '${ymin}' != -1 && '${ymax}' != -1) {
#	set yrange ['${ymin}':'${ymax}'];
#}
#set xrange and scale
#set xrange [2500 : 3500]
#set x2range [2500 : 3500]
#set x2range [1 :12]
set autoscale y
set autoscale y2
#set yrange [0 : 5000]
#set y2range [0 : 300]

set ytics nomirror
set y2tics
set tics out

set output '$outfile.1.jpeg';
plot '${infile}' u 1:5  axes x1y1 with lines ti "r/s" , \
'${infile}' u 1:6 axes x1y1 with lines ti "w/s", \
'${infile}' u 1:7 axes x2y2 with lines ti "rMB/s", \
'${infile}' u 1:8 axes x2y2 with lines ti "wMB/s", \
;


set autoscale y2
set xlabel "Time (s)";
set ylabel "requests/s";
set y2label "sectors";
set output '$outfile.2.jpeg';
plot '${infile}' u 1:5  axes x1y1 with lines ti "r/s" , \
'${infile}' u 1:6 axes x1y1 with lines ti "w/s", \
'${infile}' u 1:9 axes x2y2 with lines ti "avgrq-sz", \
'${infile}' u 1:10 axes x2y2 with lines ti "avgqu-sz", \
;

set autoscale y
set autoscale y2
set xlabel "Time (s)";
set ylabel "MB/s";
set y2label "ms";
set output '$outfile.3.jpeg';
plot '${infile}' u 1:7  axes x1y1 with lines ti "rMB/s" , \
'${infile}' u 1:8 axes x1y1 with lines ti "wMB/s", \
'${infile}' u 1:12 axes x2y2 with lines ti "r_await", \
'${infile}' u 1:13 axes x2y2 with lines ti "w_await", \
;

EOF
