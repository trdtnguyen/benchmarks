#! /bin/bash
source const.sh

#print nosa of NVME SSD multistream (Samsung PM953) for each interval of time
#nosa = number of sector available. Help detect when the GC is trigered 
#usage: ./trace_nvme_nosa.sh <device> <outfile>
#interval in seconds
INTERVAL=1
outfile=$1
dev=$2

#MOUNT_POINT='ssd1'

rm trace_nosa.txt

#output format: gcs nosa data_units_read data_units_written nand_data_units_written
while true; do
${NVME_TOOLS}/nvme_read_log $dev 81 | awk -v FS="[():]" '/gcs/ {printf("%s\t", $2)}' >> $outfile
${NVME_TOOLS}/nvme_read_log $dev 81 | awk -v FS="[():]" '/nosa/ {printf("%s\t", $2)}' >> $outfile
${NVME_TOOLS}/nvme_smart $dev | awk -v FS="[():]" '/data_units_read/ {printf("%s\t",$2) }' >> $outfile
${NVME_TOOLS}/nvme_smart $dev | awk -v FS="[():]" '/data_units_written/ {printf("%s\t",$3) }' >> $outfile
printf "\n" >> $outfile
sleep $INTERVAL;
done
