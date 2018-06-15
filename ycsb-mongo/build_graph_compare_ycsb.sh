#!/bin/sh
#usage: ./build_graph_compare_ycsb.sh file1 file2 file3 output
#file1: time1 val1
#		time2 val2
#file2: time1 val3
#		time2 val 4
# ==> combine:
#		time1 val1 val3
#		time2 val2 val4
#now combine results from multiple file experiment to compare
#normalization by using the first value as basedline

file1=$1
file2=$2
ycsbtem1=ycsbtem1
ycsbtem2=ycsbtem2
ctem1=ctem1
ctem2=ctem2
ctem3=ctem3
ctem4=ctem4
outfile=$3
#1: png, 2: eps
terminal=2
tic_font=24
global_font=24
if [ $terminal -eq 1 ]; then
	ext='png'
else
	ext='eps'
fi
grep 'current' ${file1} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${ycsbtem1}
grep 'current' ${file2} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${ycsbtem2}

#calculate average value for each 60 seconds, one line of YCSB output is 10 seconds 
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${ycsbtem1} > $ctem1
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${ycsbtem2} > $ctem2

#combine 
awk 'FNR==NR{a[$1]=$2 FS $3;next}{ print $0, a[$1]}' ${ctem2} ${ctem1} > $ctem3
#normalization
awk 'NR==1 {tem=$2} {printf("%s\t%f\t%f\n",$1, ($2*1.0)/tem, ($3*1.0)/tem)}' $ctem3 > $ctem4

gnuplot << EOF

set terminal postscript eps size 4, 2.5 enhanced color font 'Helvetica,${global_font}'
#set terminal pngcairo dashed size 800,600 enhanced color font 'Helvetica,${global_font}'
#set te jpeg giant size 800,600;


set output '${outfile}.${ext}';

set xlabel "Time (minutes)";
set ylabel "Throughput (Ops/s)";
#set y2label "Latency (us)";
#set style line 1 pt 1 lc rgb "blue" lt 3 lw 2;
set style line 1 pt 1  lt 3 lw 2;
set style line 2 pt 1  lt 1 lw 3;

set autoscale
#set xrange and scale
#set xrange [1 : 12]
#set x2range [1 :12]
set autoscale y
#set autoscale y2
#set yrange [0 : 10000]

set ytics nomirror
#set y2tics
set tics out

set pointsize 4;
set tics font ", ${tic_font}";

plot '${ctem3}' u 1:2  axes x1y1 with lines ti "Original" ls 1 , \
'${ctem3}' u 1:3 axes x1y1 with lines ti "multi-streamed ssd" ls 2, \
;

set ylabel "Normalized Throughput";
set output '${outfile}_norm.${ext}';
plot '${ctem4}' u 1:2  axes x1y1 with lines ti "Original" lt 3 lw 4, \
'${ctem4}' u 1:3 axes x1y1 with lines ti "Multi-streamed ssd" lt 10 lw 4, \
;

EOF
