#!/bin/sh                                                                                                                                                                              
#this script works for
# $ blktrace -d /dev/sdb1 -a complete -o - | blkparse -f "%d,%T,%S\n" -i - > trace.txt
# $ blktrace -d /dev/sdb1 -a complete -o - | blkparse -f "%T %c %p %d %S %N \n" -i - > trace.txt
#   timestamp cpu_id process_id read_write_pattern Sector Number_of_bytes
datafile=$1
temp1='temp1'
temp2='temp2'
temp3='temp3'
outfile=$2

#extract info from blkparse file
#grep 'R,\|RM,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${rtemp}
#grep 'W,\|WS,' ${datafile} | awk -F[,] '{ printf("%s\t%s\n", $2, $3) }' | sort -n -k1 > ${wtemp}

#sudo grep 'R\|RM' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${rtemp}
#sudo grep 'W\|WS' ${datafile} | awk  '{ printf("%s\t%s\n", $1, $5) }'  > ${wtemp}
sudo grep 'track1: 1' ${datafile} | awk  '{ printf("%s\t%s\t%s\n", $1 , $2/1000,  $15) }'  > ${temp1} 
sudo grep 'track1: 2' ${datafile} | awk  '{ printf("%s\t%s\t%s\n", $1 , $2/1000,  $15) }'  > ${temp2} 
gnuplot << EOF
set te jpeg giant size 800,600;
#set te jpeg giant size 1024,768;
set xlabel "Timestamp (second)";
#set xlabel "sequences";
set pointsize 0.2;

set ylabel "Logical Sector Number";
set style line 1 pt 7 lc rgb "green";
set style line 2 pt 7 lc rgb "red";
set style line 3 pt 7 lc rgb "blue";

set output '${outfile}_ckpt_evict.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "Ckpt",  '${temp2}' u 2:3 ls 2 ti "Evict";

set output '${outfile}_ckpt.jpeg';
plot '${temp1}' u 2:3 ls 1 ti "Ckpt";

set output '${outfile}_evict.jpeg';
plot '${temp2}' u 2:3 ls 2 ti "Evict";

EOF
