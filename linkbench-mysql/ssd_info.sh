#!/bin/bash
source const.sh


#####################################
######Compute WAF for Samsung SSD device ################
#####################################
DEV=/dev/sdd1
#capacity in GB

sudo smartctl -a $DEV > smart.tem
a1=$(cat smart.tem | grep "Total_LBAs_Written" | awk -v FS=" " '{printf("%s\n",$10)}')
sleep 5
sudo smartctl -a $DEV > smart.tem
a2=$(cat smart.tem | grep "Total_LBAs_Written" | awk -v FS=" " '{printf("%s\n",$10)}')

host_gb_written= $(( ($a2-$a1)/2/1024/1024 ))
capcity=$(cat smart.tem1 | grep "Capacity" | awk -v FS=" " '{printf("%s\n",$5)}' | awk -v FS="["  '{printf("%s\n",$2)}')

tem=$(($a2-$a1)) 

echo $(($tem/2/1024/1024))
rm smart.tem
