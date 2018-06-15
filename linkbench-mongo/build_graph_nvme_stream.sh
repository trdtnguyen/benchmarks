#!/bin/bash                                                                                                                                                                              
#build graph from output file in trace_stream_write 
source const.sh
#this script works for

infile=$1
outfile=$2
out_tem=nvme_out_tem
#number line of a circle
N=19
#MAX streams
MAX_STREAM=16
#interval in seconds, this value should be same with the value in trace_stream_write.sh
INTERVAL=10

stem1=stem1
stem2=stem2
stem3=stem3
stem4=stem4
stem5=stem5
stem6=stem6
stem7=stem7
stem8=stem8
stem9=stem9
stem10=stem10
stem11=stem11
stem12=stem12
stem13=stem13
stem14=stem14
stem15=stem15
stem16=stem16

if [ -n "$1" ]; then
	infile=$1
fi
if [ -n "$2" ]; then
	outfile=$2
fi

rm $out_tem
rm $outfile

#step 1: Parse the input file to format: count s1 s2 ... s16
awk  '{ if (NR%"'"$N"'"==2) {count+=1; if(count !=1) {printf("\n%s ", count)} else {printf("%s ", count)} } 
if (((NR%"'"$N"'">=3) &&  (NR%"'"$N"'"<= "'"$MAX_STREAM"'" + 2)) || (NR%"'"$N"'"==0) ) {printf("%s ", $3)}
}' $infile >> $out_tem
#step 2: compute delta such as
# 1 val11 val12 ... val116
# 2 (val21 - val11) (val22 - val12) ... (val216 - val116)
awk '{
if (NR==1) {s2=$2; s3=$3;s4=$4;s5=$5;s6=$6;s7=$7;s8=$8;s9=$9;s10=$10;s11=$11;s12=$12;s13=$13;s14=$14;s15=$15;s16=$16;s17=$17;s18=$18
}
	printf("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n",$1*"'"$INTERVAL"'", $2-s2, $3-s3,$4-s4,$5-s5,$6-s6,$7-s7,$8-s8,$9-s9,$10-s10,$11-s11,$12-s12,$13-s13,$14-s14,$15-s15,$16-s16,$17-s17, $18-s18)
}' $out_tem >> $outfile

echo "the last line is "
tail -n 1 $outfile

gnuplot << EOF
set te pngcairo size 800,600;

set style line 1 pt 3 ps 3 lc rgb "red";
#set style line 2 pt 1 lc rgb "green";

#set pointsize 0.3;
set autoscale

set xlabel "Time (s)" font ",14";
set ylabel "Number blocks written" font ",14";
set output '$outfile.1.png';
plot '${outfile}' u 1:2  axes x1y1 with lines lt 1 ti "Stream 0" , \
	 '${outfile}' u 1:3  axes x1y1 with lines lt 2 ti "Stream 1", \
	 '${outfile}' u 1:4  axes x1y1 with lines lt 3 ti "Stream 2", \
	 '${outfile}' u 1:5  axes x1y1 with lines lt 4 ti "Stream 3", \
	 '${outfile}' u 1:6  axes x1y1 with lines lt 5 ti "Stream 4", \
	 '${outfile}' u 1:7  axes x1y1 with lines lt 6 ti "Stream 5", \
	 '${outfile}' u 1:8  axes x1y1 with lines lt 7 ti "Stream 6", \
	 '${outfile}' u 1:9  axes x1y1 with lines lt 8 ti "Stream 7", \
	 '${outfile}' u 1:10  axes x1y1 with lines lt 9 ti "Stream 8", \
	 '${outfile}' u 1:11  axes x1y1 with lines lt 10 ti "Stream 9", \
	 '${outfile}' u 1:12  axes x1y1 with lines lt 11 ti "Stream 10", \
	 '${outfile}' u 1:13  axes x1y1 with lines lt 12 ti "Stream 11", \
	 '${outfile}' u 1:14  axes x1y1 with lines lt 13 ti "Stream 12", \
	 '${outfile}' u 1:15  axes x1y1 with lines lt 14 ti "Stream 13", \
	 '${outfile}' u 1:16  axes x1y1 with lines lt 15 ti "Stream 14", \
	 '${outfile}' u 1:17  axes x1y1 with lines lt 16 ti "Stream 15", \
	 '${outfile}' u 1:18  axes x1y1 with lines lt 17 ti "Stream 16", \
;

EOF
