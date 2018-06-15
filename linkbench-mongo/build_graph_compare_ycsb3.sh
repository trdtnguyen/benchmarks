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
file3=$3
ycsbtem1=ycsbtem1
ycsbtem2=ycsbtem2
ycsbtem3=ycsbtem3
atem1=atem1
atem2=atem2
atem3=atem3
ctem1=ctem1
ctem2=ctem2
ntem=ntem
outfile=$4

grep 'current' ${file1} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${ycsbtem1}
grep 'current' ${file2} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${ycsbtem2}
grep 'current' ${file3} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${ycsbtem3}

#calculate average value for each 60 seconds, one line of YCSB output is 10 seconds 
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${ycsbtem1} > $atem1
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${ycsbtem2} > $atem2
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${ycsbtem3} > $atem3

#combine 
awk 'FNR==NR{a[$1]=$2 FS $3;next}{ print $0, a[$1]}' ${atem2} ${atem1} > $ctem1
awk 'FNR==NR{a[$1]=$2 FS $3;next}{ print $0, a[$1]}' ${atem3} ${ctem1} > $ctem2
#normalization
awk 'NR==1 {tem=$2} {printf("%s\t%f\t%f\t%f\n",$1, ($2*1.0)/tem, ($3*1.0)/tem, ($4*1.0)/tem )}' $ctem2 > $ntem

gnuplot << EOF
set terminal postscript eps color colortext

set te jpeg giant size 800,600;
set output '$outfile.jpeg';

set xlabel "Time (minutes)";
set ylabel "Normalized Throughput (Ops/s)";
#set y2label "Latency (us)";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale
#set xrange and scale
#set xrange [1 : 12]
set autoscale y

set ytics nomirror
#set y2tics
set tics out

plot '${ntem}' u 1:2  with lines ti "Original" , \
'${ntem}' u 1:3 with lines ti "Op1", \
'${ntem}' u 1:4 with lines ti "Op2", \
;

EOF
