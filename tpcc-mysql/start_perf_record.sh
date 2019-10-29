#!/bin/bash
source const.sh
#Run perf record for a benchmark

#usage: ./start_perf_record <outfile>
out_file=perf.data

#Change this to your desired program e.g, mongod, mysqld
p_name=mysqld

pid=$(ps -opid= -C $p_name)


if [ -n $1 ]; then
	out_file=$1
	echo "output file is $1"
fi

echo "Run perf for program named $p_name with pid=$pid ..."
#if you want the graph-called report, us the -g option
#eg: sudo perf record -p $pid -ag -F 1000 --group -o $out_file

sudo perf record -p $pid -a -F 1000 --group -o $out_file
#sudo perf record -p $pid -ag -F 1000 --group -o $out_file

echo "Perf finished!"
