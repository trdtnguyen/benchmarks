#!/bin/bash

#Used for manualy run instead of autorun.sh
# Shell 1: mysqld
# Shell 2: ./run.sh METHOD THREADS
# After the benchmark finish, the result is given in the last line of overall.txt
# This script transfer that last line from overall.txt to summary.txt and only keep data.
# So user just copy/paste that line to excel file

# ./collect_result_line.sh line
# default: line = 1

source const.sh
line=1

if [ -n $1 ]; then
	line=$1
fi

tem1=$((($line-1)*5+1))

echo "get statistic info from the last $line lines of file $statfile to file $sumfile"
printf "\n" >> $sumfile
date=$(date '+%Y%m%d_%H%M%S')
	printf "$date " >> $sumfile
	tail -n $line $statfile | head -n 1 | awk -v FS=" " '{printf("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ",$6, $12, $21,$24, $27, $35, $39, $52, $53, $54, $55, $63, $66, $68, $71)}' >> $sumfile

	#get total time for waiting flush from buffer pool to disk/nvm
	tail -n $line $TRACE_FILE1 | head -n 1 | awk '{printf("%s ", $7)}' >> $sumfile

	if [ $mode -ge 4 ]; then
		#get statistic information for PMEM
		tail -n $tem1 $TRACE_FILE2 | head -n 1 >> $sumfile
	fi
