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
ctem1=ctem1
ctem2=ctem2
ctem3=ctem3
ctem4=ctem4
outfile=$3
runtime=999999999
t1='original'
t2='mssd'
if [ -n "$4" ]; then
	runtime=$4
fi

grep 'ops/sec' ${file1} | awk -F "[ =,]" ' { if (NR <= "'"$runtime"'"/10) { count1+=1 
   	printf("%s\t%s\n",count1*10, $15) 
	}}' > ${ctem1}
grep 'ops/sec' ${file2} | awk -F "[ =,]" ' { if (NR <= "'"$runtime"'"/10) { count2+=1 
   	printf("%s\t%s\n",count2*10, $15) 
	}}' > ${ctem2}

awk '{sum1+=$2; count11+=1} END {printf("=====> runtime = %s (s) \t avg OPS/s = %s \t \n", count11*10, ((sum1*1.0)/count11))}' $ctem1
awk '{sum2+=$2; count22+=1} END {printf("=====> runtime = %s (s) \t avg OPS/s = %s \t \n", count22*10, ((sum2*1.0)/count22))}' $ctem2

#combine 
awk 'FNR==NR{a[$1]=$2 FS $3;next}{ print $0, a[$1]}' ${ctem2} ${ctem1} > $ctem3
#normalization
awk 'NR==1 {tem=$2} {printf("%s\t%f\t%f\n",$1, ($2*1.0)/tem, ($3*1.0)/tem)}' $ctem3 > $ctem4

gnuplot << EOF
#set terminal postscript eps color colortext
#set terminal postscript eps enhanced color font 'Helvetica,20'
set terminal pngcairo dashed size 800,600
#set te jpeg giant size 800,600;

set xlabel "Time (s)";
set ylabel "Throughput (Ops/s)";
#set y2label "Latency (us)";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

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
set tics font ", 16";

set output '$outfile.png';
plot '${ctem3}' u 1:2  axes x1y1 with lines ti "$t1" , \
'${ctem3}' u 1:3 axes x1y1 with lines ti "$t2", \
;

set ylabel "Normalized Throughput";
set output '${outfile}_norm.png';
plot '${ctem4}' u 1:2  axes x1y1 with lines ti "$t1" lt 3 lw 4, \
'${ctem4}' u 1:3 axes x1y1 with lines ti "$t2" lt 10 lw 4, \
;

EOF
