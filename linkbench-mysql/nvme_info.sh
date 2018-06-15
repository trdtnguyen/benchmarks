#!/bin/bash
source const.sh

DEV=/dev/nvme0n1

	UNIT_R1=$(sudo nvme smart-log $DEV | grep "data_units_read" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')
	UNIT_W1=$(sudo nvme smart-log $DEV | grep "data_units_written" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')
	HOST_R1=$(sudo nvme smart-log $DEV | grep "host_read_commands" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')
	HOST_W1=$(sudo nvme smart-log $DEV | grep "host_write_commands" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')

	sleep 5

	UNIT_R2=$(sudo nvme smart-log $DEV | grep "data_units_read" | awk -v FS=" " '{printf("%s\n",$3)}' | sed 's/,//g')
	UNIT_W2=$(sudo nvme smart-log $DEV | grep "data_units_written" | awk -v FS=" " '{printf("%s\n",$3)}' | sed 's/,//g')
	HOST_R2=$(sudo nvme smart-log $DEV | grep "host_read_commands" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')
	HOST_W2=$(sudo nvme smart-log $DEV | grep "host_write_commands" | awk -v FS=" " '{printf("%s\n",$3)}'| sed 's/,//g')

	echo $(($UNIT_W2-UNIT_W1))
	echo $(($HOST_W2-HOST_W1))
