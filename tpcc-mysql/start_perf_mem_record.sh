#!/bin/bash
source const.sh
#Run perf mem record for a benchmark. Only focus on load/store mem

out_file=perf.data

#Change this to your desired program e.g, mongod, mysqld
p_name=mysqld

pid=$(ps -opid= -C $p_name)


if [ -n $1 ]; then
	out_file=$1
	echo "output file is $1"
fi

echo "Run perf for program named $p_name with pid=$pid ..."
sudo perf record -e mem-loads,mem-stores -p $pid -a -F 1000 --group -o $out_file

echo "Perf-mem finished!"
