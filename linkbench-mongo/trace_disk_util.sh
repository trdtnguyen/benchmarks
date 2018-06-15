#!/bin/bash
source const.sh
#print disk util of a mount point for each interval of time

#interval in seconds
INTERVAL=1
#MOUNT_POINT='ssd1'

rm trace_disk_util.txt

while true; do
df | grep $MOUNT_POINT | awk -F"[%]" '{printf("%s\n",$1)}' | awk '{printf("%s\n",$5)}' >> disk_util.txt;
sleep $INTERVAL;
done
