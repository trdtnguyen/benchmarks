#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

src_dir=/mnt/nvme1/
dst_dir=/mnt/ssd1/data
#Replace the data_dir with your desired value
data_dir=ycsb_mongo_10G_32K

echo "remove old data..."
#optionary remove data from pmem 
rm -rf $PMEM_DIR/*

rm -rf $DES_DIR
mkdir -p $DES_DIR

echo "copy data ..."
cp -r $SRC_DIR/$DATA_DIR $DES_DIR/db
echo "refresh data is done."

