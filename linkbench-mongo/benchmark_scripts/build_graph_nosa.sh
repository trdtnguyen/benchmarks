#!/bin/bash                                                                                                                                                                              
source const.sh
datafile=$1
out_tem='nosa_out_tem.txt'
#LB_IOPS_TEM2_OUT is defined in const.sh
out_tem2=$LB_IOPS_TEM2_OUT
out_tem3='nosa_out_tem3.txt'
#LB_ADD_LINK_FILE='LB_ADD_LINK_FILE.txt'
#get_link_tem='get_link_tem.txt'

xmin=-1
xmax=-1
ymin=-1
ymax=-1
outfile=$2
runtime=999999999

if [ -n "$3" ]; then
	xmin=$3
fi
if [ -n "$4" ]; then
	xmax=$4
fi



# $3: nosa $5, host write $6, nand write $7: 
awk ' { if (NR <= "'"$runtime"'") { count+=1 
   	printf("%s\t%s\t%s\t%s\n",count, $5, $7, $8) 
	}}' ${datafile} > ${out_tem}

gnuplot << EOF
#set terminal postscript eps color colortext
#set te jpeg giant size 800,600;
set te pngcairo size 800,600;

set style line 1 pt 3 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale
if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}']
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}']
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
set ylabel "Number of sector available" font ",14";
set y2label "Number of sectors written" font ",14";
set output '$outfile.1.png';
plot '${out_tem}' u 1:2  axes x1y1 with lines lt 1 ti "nosa" , \
'${out_tem}' u 1:3 axes x2y2 with lines ti "host written", \
'${out_tem}' u 1:4 axes x2y2 with lines ti "nand written", \
;

EOF
