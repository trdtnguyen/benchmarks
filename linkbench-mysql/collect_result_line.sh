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


if [ $WORKLOAD_TYPE -eq 1 ]; then
	#original
	tail -n $line $statfile | head -n 1 | awk '{printf("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $49, $58, $67, $76, $85, $94, $103, $111,$115,$128,$129,$130,$131,$139,$142,$144,$147)}' >> $sumfile
	#tail -n $line $statfile | head -n 1 | awk '{printf("%s %s %s %s %s %s na %s %s %s na na na %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $49, $58, $67, $75, $79,$92,$93,$94,$95,$103,$106,$108,$111)}' >> $sumfile
else
	#write-intensive (countlink = getlink = getlinklist = getnode = 0)
	tail -n $line $statfile | head -n 1 | awk '{printf("%s %s %s %s %s %s na %s %s %s na na na %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $49, $58, $67, $75, $79,$92,$93,$94,$95,$103,$106,$108,$111)}' >> $sumfile
	#tail -n $line $statfile | head -n 1 | awk '{printf("%s %s %s %s %s %s na %s %s %s na na na %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $58, $67, $76, $111,$115,$128,$129,$130,$131,$139,$142,$144,$147)}' >> $sumfile
fi

##get total time for waiting flush from buffer pool to disk/nvm
#tail -n 1 $TRACE_FILE1 | awk '{printf("%s ", $7)}' >> $sumfile
#
#if [ $mode -ge 4 ]; then
#	#get statistic information for PMEM
#	echo "get statistic info for PMEM"
#	tail -n 1 $TRACE_FILE2 >> $sumfile
#fi
