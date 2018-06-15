#!/bin/bash                                                                                                                                                                              
#Get LB_ADD_LINK_FILE and LB_GET_LINK_FILE from const.txt 
source const.sh
#this script works for
# $ blktrace -d /dev/sdb1 -o - | blkparse -i - > trace.txt
datafile=$1
out_tem='out_tem.txt'
#LB_IOPS_TEM2_OUT is defined in const.sh
out_tem2=$LB_IOPS_TEM2_OUT
out_tem3='out_tem3.txt'
#LB_ADD_LINK_FILE='LB_ADD_LINK_FILE.txt'
#get_link_tem='get_link_tem.txt'
disk_util_in='disk_util.txt'
disk_util_out='disk_util.out'
tem=ops_tem1
ops=0

xmin=-1
xmax=-1
ymin=-1
ymax=-1
outfile=$2
runtime=999999999

if [ -n "$3" ]; then
	runtime=$3
fi

grep 'current' ${datafile} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${tem}
awk '{sum1+=$2; count+=1} END {printf("avg ops/s=%s\n", (sum1*1.0)/count )}' ${tem}
grep 'Return' ${datafile}
grep '99th' ${datafile}

gnuplot << EOF
#set terminal postscript eps color colortext
#set te jpeg giant size 800,600;
set te pngcairo size 800,600;

set style line 1 pt 3 ps 3 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale
if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
#set xrange and scale
#set xrange [1 : 12]
#set x2range [1 :12]
#set xrange [0 : 1200]
set autoscale y
set autoscale y2
#set yrange [10000 : 20000]

#set y2range [0 : 160000]
set ytics nomirror
set y2tics
set tics out

set xlabel "Time (s)" font ",14";
set ylabel "Ops/s" font ",14";
set y2label "Latency (us)" font ",14";
set output '$outfile.1.png';

plot '${tem}' u 1:2  axes x1y1 with lines lt 1 ti "Throughput" ; 

EOF
