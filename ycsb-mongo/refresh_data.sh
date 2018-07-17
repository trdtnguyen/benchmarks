#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

src_dir=/mnt/nvme1/
dst_dir=/mnt/ssd1/data
#Replace the data_dir with your desired value
data_dir=ycsb_mongo_10G_32K

echo "remove old data..."
#optionary remove data from pmem 
rm -rf /mnt/pmem1/*

rm -rf $dst_dir
mkdir -p $dst_dir

echo "copy data ..."
cp -r $src_dir/$data_dir $dst_dir/db
echo "refresh data is done."

