#!/bin/sh

files='tpcc_redolog_tail'
trace_dir="../blktrace/"
plotting=1

if [ ! -d plot_timestamp ]
then
    mkdir plot_timestamp
fi
if [ ! -d plot_seq ]
then
    mkdir plot_seq
fi

seq=0;

for file in $files
do
cp ${trace_dir}${file} temp;
        # blkparse -i ${trace_dir}${file} -o temp;
        # awk format = <R|W, lsn, sect_cnt, timestamp, sequence_num>
        egrep '(D   W|D   R)' temp | awk '{printf "%s,%d,%d,%.3f,%d\n",$7, $8, $10, $4, NR}' > ${file}_RW;
        grep "R" ${file}_RW > ${file}_R
        grep "W" ${file}_RW > ${file}_W
        rm temp;

        if [ $plotting -eq 1 ]
        then
            gnuplot << EOF

set te jpeg giant size 800,600;

set xlabel "Timestamp (second)";

set ylabel "Logical Sector Number";

set style line 1 pt 7 lc rgb "green";

set style line 2 pt 7 lc rgb "red";

set pointsize 0.2;

set datafile separator ",";

set output "${file}.jpg";

plot "< grep R ${file}_RW" u 4:2 ls 1 ti "Read", "< grep W ${file}_RW" u 4:2 ls 2 ti "Write";

set output "${file}_R.jpg";

plot "< grep R ${file}_R" u 4:2 ls 1 ti "Read";

set output "${file}_W.jpg";

plot "< grep W ${file}_W" u 4:2 ls 2 ti "Write";

EOF
            mv *.jpg plot_timestamp;

            gnuplot << EOF

set te jpeg giant size 800,600;

set xlabel "Sequence Number";

set ylabel "Logical Sector Number";

set style line 1 pt 7 lc rgb "green";

set style line 2 pt 7 lc rgb "red";

set pointsize 0.2;

set datafile separator ",";

set output "${file}.jpg";

plot "< grep R ${file}_RW" u 5:2 ls 1 ti "Read", "< grep W ${file}_RW" u 5:2 ls 2 ti "Write";

set output "${file}_R.jpg";

plot "< grep R ${file}_R" u 2 ls 1 ti "Read";

set output "${file}_W.jpg";

plot "< grep W ${file}_W" u 2 ls 2 ti "Write";

EOF
            mv *.jpg plot_seq;
        fi

rm -rf ${file}_R ${file}_W

done



