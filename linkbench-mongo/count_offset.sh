#!/bin/sh                                                                                                                                                                              

#usage: ./build_graph_boundary_offset.sh <count_file> <outputfile>
datafile=$1
#outfile=$2
count_col=2
magic=47456111
#magic=71174199
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

if [ -n "$2" ]; then
	count_col=$2
fi
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
awk  -v date="$(date --rfc-3339=seconds)" -v m=$magic -v s1=0 -v s2=0 '{
if ($"'"${count_col} "'" <  m ) {
	s1 = s1 + 1
}
else {
	s2 += 1
}
	} END {printf("%s \t %s \t left : %d\t right: %d \t ratio: %f %f\n", date, "'"$1"'",s1, s2, (s2*1.0/s1), (s1*1.0/s2)) >> "left-right-only"}' ${datafile} 
