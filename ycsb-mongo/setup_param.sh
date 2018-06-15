# !/bin/bash                                                                                                                                                                             
#source const.sh
#run it when restart server
#Readahead: recommended 32, 64
sudo blockdev --setra 32 /dev/nvme0n1
sudo echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
sudo echo noop > /sys/block/nvme0n1/queue/scheduler
#Disk scheduler
#sudo echo noop > /sys/block/sda/queue/scheduler


