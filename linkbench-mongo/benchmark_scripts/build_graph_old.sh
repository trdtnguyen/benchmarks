#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -a complete -o - | blkparse -f "%d,%T,%S\n" -i - > trace.txt
# $ blktrace -d /dev/sdb1 -a complete -o - | blkparse -f "%T %c %p %d %S %N \n" -i - > trace.txt
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
wtemp='wtemp'
rtemp='rtemp'
xmin=-1
xmax=-1
ymin=-1
ymax=-1
outfile=$2

if [ -n "$3" ]; then
	xmin=$3
fi
if [ -n "$4" ]; then
	xmax=$4
fi
if [ -n "$5" ]; then
	ymin=$5
	echo Variable 'yminxxx' is ${ymin}
fi
if [ -n "$6" ]; then
	ymax=$6
fi
#extract info from blkparse file
#grep 'R,\|RM,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${rtemp}
#grep 'W,\|WS,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${wtemp}

#sudo grep 'R\|RM' ${datafile} | awk  '{ printf("%s\t%s\n", $1+$2/1000000000, $6) }'  > ${rtemp}
#sudo grep 'W\|WS' ${datafile} | awk  '{ printf("%s\t%s\n", $1+$2/1000000000, $6) }'  > ${wtemp}
sudo grep 'C\|R\|RM' ${datafile} | awk  '{ printf("%s\t%s\n", $4, $8) }'  > ${rtemp}
sudo grep 'C\|W\|WS' ${datafile} | awk  '{ printf("%s\t%s\n", $4, $8) }'  > ${wtemp}
gnuplot << EOF
#set te jpeg giant size 800,600;
set te jpeg giant size 1024,768;
set xlabel "Timestamp (second)";
#set xlabel "sequences";
set ylabel "Logical Sector Number x1000";
set style line 1 pt 1 lc rgb "red";
set style line 2 pt 1 lc rgb "green";

set pointsize 0.1;

if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}
set output '${outfile}_R.jpeg';
plot '${rtemp}' u 1:2 ls 1 ti "Read";

set output '${outfile}_W.jpeg';
plot '${wtemp}' u 1:2 ls 2 ti "Write";

set output '${outfile}_RW.jpeg';
plot '${rtemp}' u 1:2 ls 1 ti "Read",  '${wtemp}' u 1:2 ls 2 ti "Write";

