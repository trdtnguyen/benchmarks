#!/bin/bash
source const.sh
#Run perf stat for a benchmark

#usage: ./start_perf_stat <outfile>

out_file=perf_stat.data
stat_file=stat_perf_all.txt
out_dir=contextswitch
#Change this to your desired program e.g, mongod, mysqld
p_name=mysqld

pid=$(ps -opid= -C $p_name)


if [ -n $1 ]; then
	out_file=${out_dir}/$1
	#out_file=$1
	echo "output file is $out_file"
fi

echo "Run perf for program named $p_name with pid=$pid ..."

date=$(date '+%Y%m%d_%H%M%S')

#sudo perf stat -p $pid -a -B -o $out_file sleep $RUNTIME
printf "$date $1 " >> $stat_file
sudo perf stat -p $pid -a -B -o ${out_file} sleep $RUNTIME
cat ${out_file} | grep context >> $stat_file

echo "perf stat finished!"
