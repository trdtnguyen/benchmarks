#!/bin/sh                                                                                                                                                                              

#usage: ./build_graph_boundary_offset.sh <count_file> <outputfile>
datafile=$1
outfile=$2
magic=71174199
#magic=94900695
#magic=$3
wtemp1='boundtemp1'
wtemp2='boundtemp2'

#count hot pages
#sort temp1 -n > temp2

MAX=1e+12
xmin=-1
xmax=$MAX
ymin=-1
ymax=$MAX

if [ -n "$3" ]; then
	magic=$3
fi
if [ -n "$4" ]; then
	xmin=$4
fi
if [ -n "$5" ]; then
	xmax=$5
fi
if [ -n "$6" ]; then
	ymin=$6
	echo Variable 'yminxxx' is ${ymin}
fi
if [ -n "$7" ]; then
	ymax=$7
fi
awk  -v m=$magic -v s1=0 -v s2=0 '{
if ($1 <  m ) {
	s1 = s1 + $2
	printf("%s\t%s\n", $1 , $2) > "'"${wtemp1}"'" 
}
else {
	s2 += $2
	printf("%s\t%s\n", $1 , $2) > "'"${wtemp2}"'" 
}
	} END {printf("left : %d\t right: %d \t ratio: %f\n", s1, s2, (s2*1.0/s1)) >> "left-right"}' ${datafile} 
echo $s1

echo "ploting..."
gnuplot << EOF
set te jpeg giant size 800,600;
#set te te pngcairo dashed;
set xlabel "Logical Sector Number";
set ylabel "Frequency";
set style line 1 pt 1 lc rgb "#BBBBBB";
set style line 2 pt 1 lc rgb "red";

#set pointsize 0.1;

#set autoscale
if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
set xrange [0:];
set boxwidth 0.1 absolute
set style fill solid 1.0 noborder


set output '$2_boundary_W.jpeg';
plot '${wtemp1}' u 1:2 ls 1 ti "Left" with boxes, '${wtemp2}' u 1:2 ls 2 ti "Right" with boxes;
EOF
