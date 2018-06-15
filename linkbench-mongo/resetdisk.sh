# !/bin/sh                                                                                                                                                                             

#run it when restart server
#Readahead: recommended 32, 64
umount /ssd1
mkfs.ext4 /dev/sda4
mount /dev/sda4 /ssd1 -o noatime -o nobarrier

sudo blockdev --setra 64 /dev/sda4
sudo echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
#Disk scheduler
#sudo echo noop > /sys/block/sda/queue/scheduler


