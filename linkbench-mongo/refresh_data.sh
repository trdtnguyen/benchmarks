#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

src_dir=/mnt/nvme1/
dst_dir=/mnt/ssd1/data
#Replace the data_dir with your desired value
#data_dir=ycsb_mongo_10G_32K
#data_dir=ycsb_mongo_100G_32K

echo "remove old data from $PMEM_DIR and $DES_DIR..."
#optionary remove data from pmem 
rm -rf $PMEM_DIR/*

if [ $IS_RESET -eq 1 ]; then
echo "remount $DES_MOUNT from device $SRC_DEV..."
sudo umount $DES_MOUNT
sudo mkfs -t ext4 -F $SRC_DEV
sudo mount $SRC_DEV $DES_MOUNT -o noatime -o nobarrier
sudo chown vldb:vldb -R $DES_MOUNT
else
rm -rf $DES_DIR
fi	
mkdir -p $DES_DIR

echo "copy $DATA_DIR from $SRC_DIR to $DES_DIR ..."
cp -r $SRC_DIR/$DATA_DIR $DES_DIR/db
echo "refresh data is done."
