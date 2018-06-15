#!/bin/bash
source const.sh

#number of open stream
MAX_NS=16
#default number of stream is 0
ns=0

if [ -n "$1" ]; then
	ns=$1
fi

#close all streams
for (( i=1; i<=$MAX_NS; i++ ))
do
	$NVME_TOOLS/nvme_ms_ctrl $NVME_DEV 2 $i	
done

#open upto ns streams

for (( i=1; i<=$ns; i++ ))
do
	$NVME_TOOLS/nvme_ms_ctrl $NVME_DEV 1	

done
