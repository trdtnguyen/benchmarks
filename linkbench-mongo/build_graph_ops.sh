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



# $3: time, $15: ops
grep 'ops/sec' ${datafile} | awk -F "[ =,]" ' { if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\n",count*10, $15) 
	}}' > ${out_tem}
# $24: 95th latency, $11: count
grep 'ADD_LINK' ${datafile} | awk -F "[ =,]" '{ if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\t%s\n",count*10, $24, $11) 
	}}' > ${LB_ADD_LINK_FILE}
grep 'GET_LINK' ${datafile} | awk -F "[ =,]" '{ if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\t%s\n",count*10, $24, $11) 
	}}' > ${LB_GET_LINK_FILE}
grep 'UPDATE_LINK' ${datafile} | awk -F "[ =,]" '{ if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\t%s\n",count*10, $24, $11) 
	}}' > ${LB_UPDATE_LINK_FILE}
grep 'UPDATE_NODE' ${datafile} | awk -F "[ =,]" '{ if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\t%s\n",count*10, $24, $11) 
	}}' > ${LB_UPDATE_NODE_FILE}
grep 'DELETE_LINK' ${datafile} | awk -F "[ =,]" '{ if (NR <= "'"$runtime"'"/10) { count+=1 
   	printf("%s\t%s\t%s\n",count*10, $24, $11) 
	}}' > ${LB_DELETE_LINK_FILE}
#disk util
awk '{ if (NR <= "'"$runtime"'") { count+=1; printf("%s\t%s\n", count, $1) }}' $disk_util_in > $disk_util_out

#calculate average value for each 60 seconds, one line of YCSB output is 10 seconds 
awk '{sum1+=$2} (NR%6)==0 {count+=1; printf("%s\t%f\n",count, ((sum1*1.0)/6) ); sum1=0}'  ${out_tem} > $out_tem2
#calculate average ops
awk '{sum1+=$2; count+=1} END {printf("=====> runtime = %s (s) \t avg OPS/s = %s \t \n", count*60, ((sum1*1.0)/count))}' $out_tem2
awk '{sum1+= $2;count+=1;count2+=$3} END { printf("add_link avg 99th lat=%s (us) #op=%s \n", ((sum1*1.0)/count), count2)} ' ${LB_ADD_LINK_FILE} >> $tem
awk '{sum1+= $2;count+=1;count2+=$3} END { printf("get_link avg 99th lat=%s (us) #op=%s \n", ((sum1*1.0)/count), count2)} ' ${LB_GET_LINK_FILE} >> $tem
awk '{sum1+= $2;count+=1;count2+=$3} END { printf("update_link avg 99th lat=%s (us) #op=%s \n", ((sum1*1.0)/count), count2)} ' ${LB_UPDATE_LINK_FILE} >> $tem
awk '{sum1+= $2;count+=1;count2+=$3} END { printf("delete_link avg 99th lat=%s (us) #op=%s \n", ((sum1*1.0)/count), count2)} ' ${LB_DELETE_LINK_FILE} >> $tem
awk '{sum1+= $2;count+=1;count2+=$3} END { printf("update_node avg 99th lat=%s (us) #op=%s \n", ((sum1*1.0)/count), count2)} ' ${LB_UPDATE_NODE_FILE} >> $tem

cat $tem
awk -v FS="[ =]" '{count+= $8} END {printf("Total ops = %s\n", count)}' $tem
rm $tem

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
plot '${out_tem}' u 1:2  axes x1y1 with lines lt 1 ti "Throughput" , \
'${LB_ADD_LINK_FILE}' u 1:2 axes x2y2 with lines ti "99th latency add link", \
'${LB_GET_LINK_FILE}' u 1:2 axes x2y2 with lines lt 2 ti "99th Latency get link", \
'${LB_UPDATE_LINK_FILE}' u 1:2 axes x2y2 with lines lt 3 ti "99th Latency update link", \
'${LB_DELETE_LINK_FILE}' u 1:2 axes x2y2 with lines lt 4 ti "99th Latency delete link", \
'${LB_UPDATE_NODE_FILE}' u 1:2 axes x2y2 with lines lt 5 ti "99th Latency update node", \
;

set xlabel "Time (minutes)" font ",14";
set output '$outfile.2.png';
plot '${out_tem2}' u 1:2  axes x1y1 with lines ti "Throughput" , \
;

set xlabel "Time (second)" font ",14";
set ylabel "Ops/s" font ",14";
set y2label "Disk capacity used (%)" font ",14";
set output '$outfile.3.png';
plot '${out_tem}' u 1:2 axes x1y1 with lines ti "Throughput", \
'${disk_util_out}' u 1:2 axes x1y2 with lines ti "disk used (%)",\
;
EOF
