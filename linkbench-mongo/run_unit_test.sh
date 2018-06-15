# !/bin/bash

#repeat the benchmark $1 time
#call this after finishing loading data

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb 
source const.sh

outdir=$1
cache_size=$2
mount=/nvme1
temfile=$mount/tem

#step 0: preparation 
#double check:
# (1) building the desired method: ORI, OP8, ...
# (2) mongod.conf
# (3) const.sh
# (4) format, fdisk, mkfs.ext4

umount $mount
${NVME_TOOLS}/nvme_format_ns $NVME_DEV 0 0 1

sleep 3 
(
	echo d # delete partition
	echo n # new partition
	echo p # Primary
	echo 1 # Partition number
	echo # first sector, use default
	echo # last sector, use default
	echo w
) | fdisk $NVME_DEV_ROOT
sleep 3

mkfs.ext4 $NVME_DEV
mount $NVME_DEV $mount -o noatime -o nobarrier

echo "seq fill SSD 1st time..."
#step 1: fill SSD with sequential data twice of it's capacity
dd if=/dev/zero of=$temfile bs=1G oflag=direct
#dd if=/dev/zero of=$NVME_DEV bs=1G oflag=direct
echo "seq fill SSD 2nd time..."
dd if=/dev/zero of=$temfile bs=1G oflag=direct
#dd if=/dev/zero of=$NVME_DEV bs=1G oflag=direct
rm $temfile
echo "fill SSD with random data ..."
#fio --name=global --ioengine=libaio --iodepth=4 --rw=randwrite --bs=4k --direct=1 --filename $NVME_BLKDEV --size=100% --numjobs=1 --loops=2 --name=job1
fio --name=global --ioengine=libaio --iodepth=4 --rw=randwrite --bs=4k --direct=1 --filename $temfile --size=450G --numjobs=1 --loops=2 --name=job1
rm $temfile

echo "copying data..."
#step 3: copy data and run benchmark
cp -R /ssd3/data $mount 
${BENCHMARK_HOME}/autorun.sh $outdir $cache_size

