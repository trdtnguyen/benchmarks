#!/bin/sh                                                                                                                                                                              
#input my_mssd_track6.txt
#build plot for linkbench benchmark with multi-streamd ssd technique
infile=$1
#node_coll, link_coll, count_coll

#use this to skip awk for formating plot purpose
isoplog=0
isawk=0
isplotj=1
islba=0 #0: y-axist is file offset, 1: y-axist is LBA
filej='filejournal'


if [ $isoplog -eq 1 ]; then

#with oplog
coll1='collection/12' #node coll
coll2='collection/5' #link coll
coll3='collection/9' #count coll

idx1='index/13' # node pri
idx2='index/6' # link pri
idx3='index/7' # link 2nd 1
idx4='index/8' # link 2nd 2
idx5='index/10' # count pri
idx6='index/11' # count 2nd 1
else #[ $isoplog -eq 1 ]
#without op log
coll1='collection/9' #node coll
coll2='collection/2' #link coll
coll3='collection/6' #count coll

idx1='index/10' #node pri
idx2='index/3' # link pri
idx3='index/4' # link 2nd 1
idx4='index/5' # link 2nd 2
idx5='index/7' # count pri
idx6='index/8' # count 2nd
fi

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

#the x value from data file is ms => to show as second use xscale 1000
# to use as 1,000 seconds use xscale 1000000
xscale=1000
#xscale=1000000

yscale=1e+7
if [ $islba -eq 1 ]; then
yscale=1000
fi

MAX=1e+12
xmin=-1
xmax=$MAX
ymin=-1
ymax=$MAX
outfile=$2

#font_size=22
font_size=25

ylabel="File offset"
if [ $islba -eq 1 ]; then
ylabel="File LBA"
fi

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

if [ $isawk -eq 1 ]; then
#awk '/left.*collection/ {printf("%s\t%d\t%s\n",$15*1.0/"'"$xscale"'", $3, $10)}' $infile > $filetemp1
#awk '/right.*collection/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3, $10)}' $infile > $filetemp2
#awk '/left.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3, $10)}' $infile > $filetemp3
#awk '/right.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3, $10)}' $infile > $filetemp4

if [ $islba -eq 1 ] ; then
awk '/left.*collection/ {printf("%s\t%d\t%s\n",$15*1.0/"'"$xscale"'", $5*1.0/"'"$yscale"'", $10)}' $infile > $filetemp1
awk '/right.*collection/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $5*1.0/"'"$yscale"'", $10)}' $infile > $filetemp2
awk '/left.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $5*1.0/"'"$yscale"'", $10)}' $infile > $filetemp3
awk '/right.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $5*1.0/"'"$yscale"'", $10)}' $infile > $filetemp4
else
awk '/left.*collection/ {printf("%s\t%d\t%s\n",$15*1.0/"'"$xscale"'", $3*1.0/"'"$yscale"'", $10)}' $infile > $filetemp1
awk '/right.*collection/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3*1.0/"'"$yscale"'", $10)}' $infile > $filetemp2
awk '/left.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3*1.0/"'"$yscale"'", $10)}' $infile > $filetemp3
awk '/right.*index/ {printf("%s\t%d\t%s\n", $15*1.0/"'"$xscale"'", $3*1.0/"'"$yscale"'", $10)}' $infile > $filetemp4
fi #[ islba -eq 1 ]

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

fi #[ $isawk -eq 1 ]

if [ $isplotj -eq 1 ]; then

if [ $islba -eq 1 ]; then
awk '/na na/ {printf("%s\t%d\t%s\n",$15*1.0/"'"$xscale"'", $5*1.0/"'"$yscale"'", $10)}' $infile > $filej
else
#file offset
awk '/na na/ {printf("%s\t%d\t%s\n",$15*1.0/"'"$xscale"'", $3*1000.0/"'"$yscale"'", $10)}' $infile > $filej
fi
fi

echo "plotting..."
gnuplot << EOF
set terminal pngcairo transparent size 900,400
#set terminal pngcairo size 800,600
#set terminal postscript eps color colortext
#set te jpeg giant size 1024,768;
set xlabel "Time (s)" font ", $font_size";
#for avoiding ylabel overllap by long y values, add offset
set ylabel "$ylabel (x 10M)" font ", $font_size" offset 0 -3;
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

set style line 100 pt 1 lc rgb "#747d7d";

set style fill  transparent solid 0.50 noborder;

#for fix missing a litter part in most right
set rmargin at screen 0.95
set pointsize 0.1;
set tics font ", $font_size";
set key font ", $font_size";

#to reduce the number of xtics
set xtics 1500
set autoscale
#set yrange [0:4000]
if( '${xmin}' != -1 && '${xmax}' != -1) {
	set xrange ['${xmin}':'${xmax}'];
}
if( '${ymin}' != -1 && '${ymax}' != -1) {
	set yrange ['${ymin}':'${ymax}'];
}


set output '${outfile}_streamid_combine.png';
plot '${filetemp1}' u 1:2 ls 1 ti "", \
'${filetemp2}' u 1:2 ls 2 ti "", \
'${filetemp3}' u 1:2 ls 3 ti "", \
'${filetemp4}' u 1:2 ls 4 ti "" 
;
#plot '${filetemp1}' u 1:($2/${yscale}) ls 1 ti "", \
#'${filetemp2}' u 1:($2/${yscale}) ls 2 ti "", \
#'${filetemp3}' u 1:($2/${yscale}) ls 3 ti "", \
#'${filetemp4}' u 1:($2/${yscale}) ls 4 ti "" 
#;

set output '${outfile}_streamid3.png';
plot '${filetemp1}' u 1:2 ls 1 ti "";
set output '${outfile}_streamid4.png';
plot '${filetemp2}' u 1:2 ls 2 ti "";
set output '${outfile}_streamid5.png';
plot '${filetemp3}' u 1:2 ls 3 ti "";
set output '${outfile}_streamid6.png';
plot '${filetemp4}' u 1:2 ls 4 ti "";

#plot by file grouped by streamid
set output '${outfile}_streamid3_coll.png';
plot '$filetemp11' u 1:2 ls 5 ti "", \
'$filetemp12' u 1:2 ls 6 ti "", \
'$filetemp13' u 1:2 ls 7 ti ""; 

#plot by file grouped by streamid
#set output '${outfile}_streamid3_coll.png';
#plot '$filetemp11' u 1:2 ls 5 ti "", \
#'$filetemp12' u 1:2 ls 6 ti "", \
#'$filetemp13' u 1:2 ls 7 ti ""; 
	
set output '${outfile}_streamid4_coll.png';
plot '$filetemp21' u 1:2 ls 5 ti "", \
'$filetemp22' u 1:2 ls 6 ti "", \
'$filetemp23' u 1:2 ls 7 ti ""; 

set output '${outfile}_streamid5_idx.png';
plot '$filetemp31' u 1:2 ls 5 ti "", \
'$filetemp32' u 1:2 ls 6 ti "", \
'$filetemp33' u 1:2 ls 7 ti "", \
'$filetemp34' u 1:2 ls 8 ti "", \
'$filetemp35' u 1:2 ls 9 ti "", \
'$filetemp36' u 1:2 ls 10 ti ""; 

set output '${outfile}_streamid6_idx.png';
plot '$filetemp41' u 1:2 ls 5 ti "", \
'$filetemp42' u 1:2 ls 6 ti "", \
'$filetemp43' u 1:2 ls 7 ti "", \
'$filetemp44' u 1:2 ls 8 ti "", \
'$filetemp45' u 1:2 ls 9 ti "", \
'$filetemp46' u 1:2 ls 10 ti ""; 

#plot by file original
set output '${outfile}_coll_node.png';
plot '$filetemp11' u 1:2 ls 1 ti "", \
 '$filetemp21' u 1:2 ls 2 ti "";
set output '${outfile}_coll_link.png';
plot '$filetemp12' u 1:2 ls 1 ti "", \
 '$filetemp22' u 1:2 ls 2 ti "";
set output '${outfile}_coll_count.png';
#ls 100 is the grey scale color
plot '$filetemp13' u 1:2 ls 100 ti "", \
 '$filetemp23' u 1:2 ls 100 ti "";
#plot '$filetemp13' u 1:2 ls 1 ti "", \
# '$filetemp23' u 1:2 ls 2 ti "";


set autoscale
set output '${outfile}_idx_node_pri.png';
plot '$filetemp31' u 1:2 ls 1 ti "", \
 '$filetemp41' u 1:2 ls 2 ti "";
set output '${outfile}_idx_link_pri.png';
plot '$filetemp32' u 1:2 ls 1 ti "", \
 '$filetemp42' u 1:2 ls 2 ti "";
set output '${outfile}_idx_link_2nd1.png';
plot '$filetemp33' u 1:2 ls 1 ti "", \
 '$filetemp43' u 1:2 ls 2 ti "";
set output '${outfile}_idx_link_2nd2.png';
plot '$filetemp34' u 1:2 ls 1 ti "", \
 '$filetemp44' u 1:2 ls 2 ti "";
set output '${outfile}_idx_count_pri.png';
plot '$filetemp35' u 1:2 ls 100 ti "", \
 '$filetemp45' u 1:2 ls 100 ti "";
#plot '$filetemp35' u 1:2 ls 1 ti "", \
# '$filetemp45' u 1:2 ls 2 ti "";
set output '${outfile}_idx_count_2nd.png';
plot '$filetemp36' u 1:2 ls 100 ti "", \
 '$filetemp46' u 1:2 ls 100 ti "";
#plot '$filetemp36' u 1:2 ls 1 ti "", \
# '$filetemp46' u 1:2 ls 2 ti "";


#plot journal file
set ylabel "$ylabel (x10K)" font ", $font_size" offset 0 -3;
#if ('${isplotj}' == 1){
set output '${outfile}_journal.png';
plot '${filej}' u 1:2 ls 100 ti "";
#}
EOF
