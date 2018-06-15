#!/bin/bash                                                                                                                                                                       
source const.sh
# build graph for output of $ iostat -mx 1
#input tem is the tracking file form iostat -mx 1 > tem
iostat_file=$1
top_file=$2

iostat_tem=iostat_tem
top_tem=top_tem
top_tem2=top_tem2
top_tem3=top_tem3
#$LINUX_STAT_FILE is defined in const.sh
outfile=$LINUX_STAT_FILE

if [ -n "$3" ]; then
	outfile=$3
fi

#${infile} | awk -F "[ =,]" '{printf("%s\t%s\t%s\t%s\t%s\n",$3, $7, $26, $32, $35)}' > ${out_tem}
#get

date="$(date --rfc-3339=seconds)"

printf "\n========== Linux Stat report on $date ================\n" >> $outfile
#iostat
grep $TRACK_DEV $iostat_file | awk '{count+=1; printf("%s\t%s\n",count, $0)}'  > $iostat_tem
awk '{count+=1; sum2+=$3; sum3+=$4; sum4+=$5; sum5+=$6; sum6+=$7; sum7+=$8; sum8+=$9; sum9+=$10; sum10+=$11; sum11+=$12; sum12+=$13; sum13+=$14; sum14+=$15 } END {printf ("rrqm/s  wrqm/s  r/s    w/s    rMB/s  wMB/s   avgrq-sq avgqu-sz await   r_await w_await svctm   util    \n%5s%8s%8s %5s %5s %5s %5s %5s %5s %5s %5s %5s \t %s \n", sum2*1.0/count, sum3*1.0/count, sum4*1.0/count, sum5*1.0/count, sum6*1.0/count, sum7*1.0/count, sum8*1.0/count, sum9*1.0/count, sum10*1.0/count, sum11*1.0/count,sum12*1.0/count, sum13*1.0/count, sum14*1.0/count )}' $iostat_tem >> $outfile

#top
grep Cpu $top_file | awk '{count+=1; printf("%s %s %s %s %s\n", count, $2, $4, $8, $10)}' > $top_tem
grep cached $top_file | awk '{count+=1; printf("%s %s\n",count, $9)}' > $top_tem2
grep mongod $top_file | awk '{count+=1; printf("%s %s %s \n", count, $9, $10)}' > $top_tem3
awk '{count+=1; sum1+=$2; sum2+=$3; sum3+=$4; sum4+=$5} END {printf("AVG us \t sy \t id \t wa \n %s \t %s \t %s \t %s \n", sum1*1.0/count, sum2*1.0/count, sum3*1.0/count, sum4*1.0/count )}' $top_tem >> $outfile
awk '{count+=1; sum1+=$2} END {printf("AVG cached_mem %s GB ", sum1*1.0/(count*1024^2))}' $top_tem2 >> $outfile
awk '{count+=1; sum1+=$2; sum2+=$3} END {printf("AVG_%CPU %s AVG_%MEM %s ", sum1*1.0/count, sum2*1.0/count)}' $top_tem3 >> $outfile

printf "\n========================End of Linux stat report ================\n" >> $outfile
echo "See the output result in $outfile"
gnuplot << EOF
set te pngcairo size 800,600;

set xlabel "Time (s)";
set ylabel "%";
set y2label "MB/s";
#set style line 1 pt 1 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale
#if( '${xmin}' != -1 && '${xmax}' != -1) {
#	set xrange ['${xmin}':'${xmax}'];
#}
#if( '${ymin}' != -1 && '${ymax}' != -1) {
#	set yrange ['${ymin}':'${ymax}'];
#}
#set xrange and scale
#set xrange [2500 : 3500]
#set x2range [2500 : 3500]
#set x2range [1 :12]
set autoscale y
set autoscale y2
#set yrange [0 : 5000]
#set y2range [0 : 300]

set ytics nomirror
set y2tics
set tics out

set output '$outfile.1.png';
plot '${iostat_tem}' u 1:14  axes x1y1 with lines ti "%util" , \
'${iostat_tem}' u 1:5 axes x1y1 with lines ti "rMB/s", \
'${iostat_tem}' u 1:6 axes x2y2 with lines ti "wMB/s" \
;

set output '$outfile.2.png';
plot '${top_tem}' u 1:2  axes x1y1 with lines ti "us" , \
'${top_tem}' u 1:3 axes x1y1 with lines ti "sy", \
'${top_tem}' u 1:5 axes x1y1 with lines ti "wa" \
;
EOF

rm $iostat_tem
rm $top_tem
rm $top_tem2
rm $top_tem3
