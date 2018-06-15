#!/bin/sh                                                                                                                                                                              
#input my_mssd_track6.txt
#build plot for linkbench benchmark with multi-streamd ssd technique
infile=$1
#node_coll, link_coll, count_coll
coll1='collection/9'
coll2='collection/2'
coll3='collection/6'

idx1='index/3'
idx2='index/4'
idx3='index/5'
idx4='index/7'
idx5='index/8'
idx6='index/10'

filetemp1='filetemp1'
filetemp2='filetemp2'
filetemp3='filetemp3'
filetemp4='filetemp4'
#those temp files look a little bit crazy!
#there are 3 collections 
filetemp11='filetemp11'
filetemp12='filetemp12'
filetemp13='filetemp13'

filetemp21='filetemp21'
filetemp22='filetemp22'
filetemp23='filetemp23'

#there are 6 indexes
filetemp31='filetemp31'
filetemp32='filetemp32'
filetemp33='filetemp33'
filetemp34='filetemp34'
filetemp35='filetemp35'
filetemp36='filetemp36'

filetemp41='filetemp41'
filetemp42='filetemp42'
filetemp43='filetemp43'
filetemp44='filetemp44'
filetemp45='filetemp45'
filetemp46='filetemp46'

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
# plot by streamd id
#capture lines with "left" and "collection"
#$3: offset, $10: filename
awk '/left.*collection/ {printf("%s\t%d\t%s\n",$15, $3, $10)}' $infile > $filetemp1
awk '/right.*collection/ {printf("%s\t%d\t%s\n", $15, $3, $10)}' $infile > $filetemp2
awk '/left.*index/ {printf("%s\t%d\t%s\n", $15, $3, $10)}' $infile > $filetemp3
awk '/right.*index/ {printf("%s\t%d\t%s\n", $15, $3, $10)}' $infile > $filetemp4
#awk '/streamid 3/ {printf("%s\t%d\t%s\n",NR, $3, $10)}' $infile > $filetemp1
#awk '/streamid 4/ {printf("%s\t%d\t%s\n",NR, $3, $10)}' $infile > $filetemp2
#awk '/streamid 5/ {printf("%s\t%d\t%s\n",NR, $3, $10)}' $infile > $filetemp3
#awk '/streamid 6/ {printf("%s\t%d\t%s\n",NR, $3, $10)}' $infile > $filetemp4
#plot by file type
grep $coll1 $filetemp1 > $filetemp11
grep $coll2 $filetemp1 > $filetemp12
grep $coll3 $filetemp1 > $filetemp13

grep $coll1 $filetemp2 > $filetemp21
grep $coll2 $filetemp2 > $filetemp22
grep $coll3 $filetemp2 > $filetemp23

grep $idx1 $filetemp3 > $filetemp31
grep $idx2 $filetemp3 > $filetemp32
grep $idx3 $filetemp3 > $filetemp33
grep $idx4 $filetemp3 > $filetemp34
grep $idx5 $filetemp3 > $filetemp35
grep $idx6 $filetemp3 > $filetemp36

grep $idx1 $filetemp4 > $filetemp41
grep $idx2 $filetemp4 > $filetemp42
grep $idx3 $filetemp4 > $filetemp43
grep $idx4 $filetemp4 > $filetemp44
grep $idx5 $filetemp4 > $filetemp45
grep $idx6 $filetemp4 > $filetemp46

echo "plotting..."
gnuplot << EOF
set terminal pngcairo transparent size 800,600
#set terminal pngcairo size 800,600
#set terminal postscript eps color colortext
#set te jpeg giant size 1024,768;
set xlabel "Time (ms)" font ", 14";
set ylabel "file offset" font ", 14";
set style line 1 pt 1 lc rgb "#ff0000";
set style line 2 pt 1 lc rgb "#00ff00";
set style line 3 pt 1 lc rgb "#0000ff";
set style line 4 pt 1 lc rgb "#00f2ff";

#those styles for collections
set style line 5 pt 1 lc rgb "#c55a11";
set style line 6 pt 1 lc rgb "#548235";
set style line 7 pt 1 lc rgb "#76abdc";

#those styles for indexes 
set style line 8 pt 1 lc rgb "#c690d4";
set style line 9 pt 1 lc rgb "#ffc000";
set style line 10 pt 1 lc rgb "#222222";


set style fill  transparent solid 0.50 noborder;

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

set output '${outfile}_streamid_combine.png';
plot '${filetemp1}' u 1:2 ls 1 ti "streamid 3", \
'${filetemp2}' u 1:2 ls 2 ti "streamdid 4", \
'${filetemp3}' u 1:2 ls 3 ti "streamdid 5", \
'${filetemp4}' u 1:2 ls 4 ti "streamdid 6" 
;

set output '${outfile}_streamid3.png';
plot '${filetemp1}' u 1:2 ls 1 ti "streamid 3";
set output '${outfile}_streamid4.png';
plot '${filetemp2}' u 1:2 ls 2 ti "streamid 4";
set output '${outfile}_streamid5.png';
plot '${filetemp3}' u 1:2 ls 3 ti "streamid 5";
set output '${outfile}_streamid6.png';
plot '${filetemp4}' u 1:2 ls 4 ti "streamid 6";

#plot by file grouped by streamid
set output '${outfile}_streamid3_coll.png';
plot '$filetemp11' u 1:2 ls 5 ti "streamid 3 coll 1", \
'$filetemp12' u 1:2 ls 6 ti "streamid 3 coll 2", \
'$filetemp13' u 1:2 ls 7 ti "streamid 3 coll 3"; 
	
set output '${outfile}_streamid4_coll.png';
plot '$filetemp21' u 1:2 ls 5 ti "streamid 4 coll 1", \
'$filetemp22' u 1:2 ls 6 ti "streamid 4 coll 2", \
'$filetemp23' u 1:2 ls 7 ti "streamid 4 coll 3"; 

set output '${outfile}_streamid5_idx.png';
plot '$filetemp31' u 1:2 ls 5 ti "streamid 5 idx 1", \
'$filetemp32' u 1:2 ls 6 ti "streamid 5 idx 2", \
'$filetemp33' u 1:2 ls 7 ti "streamid 5 idx 3", \
'$filetemp34' u 1:2 ls 8 ti "streamid 5 idx 4", \
'$filetemp35' u 1:2 ls 9 ti "streamid 5 idx 5", \
'$filetemp36' u 1:2 ls 10 ti "streamid 5 idx 6"; 

set output '${outfile}_streamid6_idx.png';
plot '$filetemp41' u 1:2 ls 5 ti "streamid 6 idx1", \
'$filetemp42' u 1:2 ls 6 ti "streamid 6 idx 2", \
'$filetemp43' u 1:2 ls 7 ti "streamid 6 idx 3", \
'$filetemp44' u 1:2 ls 8 ti "streamid 6 idx 4", \
'$filetemp45' u 1:2 ls 9 ti "streamid 6 idx 5", \
'$filetemp46' u 1:2 ls 10 ti "streamid 6 idx 6"; 

#plot by file original
set output '${outfile}_coll_node.png';
plot '$filetemp11' u 1:2 ls 1 ti "streamid 3 node coll", \
 '$filetemp21' u 1:2 ls 2 ti "streamid 4 node coll";
set output '${outfile}_coll_link.png';
plot '$filetemp12' u 1:2 ls 1 ti "streamid 3 link coll", \
 '$filetemp22' u 1:2 ls 2 ti "streamid 4 link coll";
set output '${outfile}_coll_count.png';
plot '$filetemp13' u 1:2 ls 1 ti "streamid 3 count coll", \
 '$filetemp23' u 1:2 ls 2 ti "streamid 4 coll 3";


set output '${outfile}_idx_link_pri.png';
plot '$filetemp31' u 1:2 ls 1 ti "streamid 5 idx 1", \
 '$filetemp41' u 1:2 ls 2 ti "streamid 6 idx 1";
set output '${outfile}_idx_link_2nd1.png';
plot '$filetemp32' u 1:2 ls 1 ti "streamid 5 idx 2", \
 '$filetemp42' u 1:2 ls 2 ti "streamid 6 idx 2";
set output '${outfile}_idx_link_2nd2.png';
plot '$filetemp33' u 1:2 ls 1 ti "streamid 5 idx 3", \
 '$filetemp43' u 1:2 ls 2 ti "streamid 6 idx 3";
set output '${outfile}_idx_count_pri.png';
plot '$filetemp34' u 1:2 ls 1 ti "streamid 5 idx 4", \
 '$filetemp44' u 1:2 ls 2 ti "streamid 6 idx 4";
set output '${outfile}_idx_count_2nd.png';
plot '$filetemp35' u 1:2 ls 1 ti "streamid 5 idx 5", \
 '$filetemp45' u 1:2 ls 2 ti "streamid 6 idx 5";
set output '${outfile}_idx_node_pri.png';
plot '$filetemp36' u 1:2 ls 1 ti "streamid 5 idx 6", \
 '$filetemp46' u 1:2 ls 2 ti "streamid 6 idx 6";
