#!/bin/bash
source const.sh
#print number of block (512 bytes) write on each stream by time 

outfile=$1
#interval in seconds
INTERVAL=10
#MOUNT_POINT='ssd1'

rm $outfile 

while true; do

cat /proc/multi_stream  >> $outfile 

sleep $INTERVAL;
done
