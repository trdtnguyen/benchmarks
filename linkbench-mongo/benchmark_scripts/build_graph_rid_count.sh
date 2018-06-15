#!/bin/sh                                                                                                                                                                              
#this script works for count rid request from client
#input: my_track_rid.txt

#usage: ./build_graph_rid_count.sh <inputfile> <outputfile> [<col_count> <xmin> <xmax> <ymin> <ymax>]

datafile=$1
outfile=$2
count_col=3
wtemp='counttemp'

#count hot pages
#sort temp1 -n > temp2

MAX=1e+12
xmin=0
xmax=$MAX
ymin=-1
ymax=$MAX

if [ -n "$3" ] ; then
	count_col=$3
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
#this is huge expensive command 
echo "count on col ${count_col} ..."
awk  '{ h[$"'"${count_col} "'"]++}; END { for (k in h) printf("%s\t%s\n", k, h[k]) }' ${datafile}  > ${wtemp}

echo "ploting..."
gnuplot << EOF
set te jpeg giant size 800,600;
#set te te pngcairo dashed;
set xlabel "Record ID";
set ylabel "Frequency";
set style line 1 pt 1 lc rgb "green";


#set pointsize 0.1;

#set autoscale
if( '${xmin}' != 0 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
set boxwidth 2 absolute;
#set style fill solid 1.0 noborder
set style fill solid 0.25 border;


set output '$2_fre_rid.jpeg';
plot '${wtemp}' u 1:2 ls 1 ti "Number of write" with boxes;
EOF
