#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -o - | blkparse -i - > trace.txt
datafile=$1
tem1='add_link_tem1.txt'
tem11='add_link_tem2.txt'
tem2='get_link_tem1.txt'
tem22='get_link_tem2.txt'
tem3='out_tem3.txt'
disk_util_in='disk_util.txt'
disk_util_out='disk_util.out'

xmin=-1
xmax=-1
ymin=-1
ymax=-1
outfile=$2
runtime=999999999

if [ -n "$3" ]; then
	runtime=$3
fi
rm ${tem1} ${tem11} ${tem2} ${tem22} ${tem3} 

# timestamp,totalops,op,ops,concurrency,queue_size,max_us,p95_us,p99_us
#for ADD_LINK, we need: timestamp, ops, p95_us, p99_us
grep 'ADD_LINK' ${datafile} | awk -F "[ ,]" '{ if (NR <= "'"$runtime"'"/10)  
   	printf("%s\t%s\t%s\t%s\n",$1, $4, $8, $9) 
	}' > ${tem1}

#for GET_LINK, we need: timestamp, ops, p95_us, p99_us
grep 'GET_LINK' ${datafile} | awk -F "[ ,]" '{ if (NR <= "'"$runtime"'"/10)  
   	printf("%s\t%s\t%s\t%s\n",$1, $4, $8, $9) 
	}' > ${tem2}

#disk util
awk '{count+=1; printf("%s\t%s\n", count, $1) }' $disk_util_in > $disk_util_out

#calculate average value for each 60 seconds, one line of YCSB output is 10 seconds 
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${tem1} > $tem11
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${tem2} > $tem22
#calculate average ops
#awk '{sum1+=$2;sum2+=$3; sum3+=$4; count+=1} END {printf("=====> runtime = %s (s) \t avg OPS/s = %s \t avg lat = %s (us) \t 99th lat = %s (us) \n",
#														count*10, ((sum1*1.0)/count), ((sum2*1.0)/count), ((sum3*1.0)/count))}' $out_tem

gnuplot << EOF
#set terminal postscript eps color colortext
#set te jpeg giant size 1024,768;
#set te jpeg giant size 800,600;
set terminal pngcairo size 800,600

set xlabel "Time (s)";
set ylabel "Ops/s";
set y2label "Latency (us)";
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

set output '${outfile}_add_link_1.jpeg';
plot '${tem1}' u 1:2  axes x1y1 with lines ti "Throughput" , \
'${tem1}' u 1:3 axes x2y2 with lines ti "95th Latency", \
'${tem1}' u 1:4 axes x2y2 with lines lt 5 ti "99th Latency", \
;
set output '${outfile}_get_link_1.jpeg';
plot '${tem2}' u 1:2  axes x1y1 with lines ti "Throughput" , \
'${tem2}' u 1:3 axes x2y2 with lines ti "95th Latency", \
'${tem2}' u 1:4 axes x2y2 with lines lt 5 ti "99th Latency", \
;

set xlabel "Time (minutes)";
set output '${outfile}_add_link_2.jpeg';
plot '${tem11}' u 1:2  axes x1y1 with lines ti "Throughput" , \
;
set output '${outfile}_get_link_2.jpeg';
plot '${tem22}' u 1:2  axes x1y1 with lines ti "Throughput" , \
;

set xlabel "Time (second)";
set ylabel "Ops/s";
set y2label "Disk capacity used (%)";
set output '${outfile}_add_link_3.jpeg';
plot '${tem1}' u 1:2 axes x1y1 with lines ti "Throughput", \
'${disk_util_out}' u 1:2 axes x1y2 with lines ti "disk used (%)",\
;
set output '${outfile}_get_link_3.jpeg';
plot '${tem2}' u 1:2 axes x1y1 with lines ti "Throughput", \
'${disk_util_out}' u 1:2 axes x1y2 with lines ti "disk used (%)",\
;
EOF
