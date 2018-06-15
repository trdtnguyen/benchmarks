#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -o - | blkparse -i - > trace.txt
datafile=$1
wtemp='wtemp'
ctemp='ctemp'
rtemp='rtemp'
wsynctemp='wsynctemp'
blkcount='blkcount'
MAX=1e+12
xmin=-1
xmax=$MAX
ymin=-1
ymax=$MAX
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

echo "extract info from input file..."
#temporary don't trace read pattern
#sudo grep 'WS' ${datafile} | awk  '/C/ { if("'"${xmin}"'" <= $4 && $4 < 100000000) printf("%s\t%s\t%s\n", $4, $8, $10) }'  > ${wsynctemp}
sudo grep 'WS' ${datafile} | awk  '/Q/ { if("'"${xmin}"'" <= $4 && $4 < 100000000) printf("%s\t%s\t%s\n", $4, $8, $10) }'  > ${wsynctemp}
sudo grep '\bR\b\|RM' ${datafile} | awk  '/C/ { if("'"${xmin}"'" <= $4 && $4 < 100000000) printf("%s\t%s\t%s\n", $4, $8, $10) }'  > ${rtemp}
sudo grep '\bW\b' ${datafile} | awk  '/Q/ { if("'"${xmin}"'" <= $4 && $4 < 100000000) printf("%s\t%s\t%s\n", $4, $8, $10) }'  > ${wtemp}
#sudo grep '\bW\b' ${datafile} | awk  '/C/ { if("'"${xmin}"'" <= $4 && $4 < 100000000) printf("%s\t%s\t%s\n", $4, $8, $10) }'  > ${wtemp}

#count number of writes 
echo $1 >> ${blkcount}
wc -l ${wtemp} >> ${blkcount}

#count hot pages
#awk  '{ h[$2]++}; END { for (k in h) printf("%s\t%s\n", k, h[k]) }' ${wtemp}  > ctemp1

#sort the hot pages
#sort -k 2 ctemp1 > ${ctemp}
echo "plotting..."
gnuplot << EOF
#set te jpeg giant size 800,600;
set terminal pngcairo size 800,600
#set terminal postscript eps color colortext
#set te jpeg giant size 1024,768;
set xlabel "Timestamp (second)" font ", 14";
#set xlabel "sequences";
set ylabel "Logical Sector Number" font ", 14";
set style line 1 pt 1 lc rgb "red";
set style line 2 pt 1 lc rgb "green";
#set style line 1 pt 1 lc rgb "#FF0000";
#set style line 2 pt 1 lc rgb "#CF96FA";
set style line 3 pt 1 lc rgb "#96F3FA";

set pointsize 0.1;
set tics font ", 14";
set key font ", 14";

set autoscale
if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}

set output '${outfile}_R.png';
plot '${rtemp}' u 1:2 ls 1 ti "Read";

set output '${outfile}_W.png';
plot '${wtemp}' u 1:2 ls 2 ti "Write";

set output '${outfile}_WS.png';
plot '${wsynctemp}' u 1:2 ls 3 ti "Write Sync";

#set output '${outfile}_RW.jpeg';
#plot '${rtemp}' u 1:2 ls 1 ti "Read",  '${wtemp}' u 1:2 ls 2 ti "Write", '${wsynctemp}' u 1:2 ls 3 ti "Write Sync";

