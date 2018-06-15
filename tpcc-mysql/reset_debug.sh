#!/bin/bash
source const.sh

cur_dir=$(pwd)

echo "clear data in $PMEM_DIR and $DES_DIR..."

sudo sysctl vm.drop_caches=3
sleep $SLEEP_DROP_CACHE 
sudo sysctl vm.drop_caches=3

sudo rm -rf $PMEM_DIR/*
sudo rm -rf $DES_DIR/data

#echo "copy tar file..."
#cp $SRC_DEV/$DATA_DIR.tar.gz $DES_DEV/
#echo "decompress tar file..."

#cd $DES_DEV 
#pigz -dc  $DATA_DIR.tar.gz | tar xf -
#mv $DATA_DIR data

#if [ -n $1 ]; then
#	IS_RESET=1
#fi

if [ $IS_RESET -eq 1 ]; then
	echo "re-mkfs for $DEV1"
	sudo umount $DES_DIR 
	sudo mkfs -t ext4 -F $DEV1
	sudo mount $DEV1 $DES_DIR -o noatime -o nobarrier
	sudo chown -R vldb:vldb $DES_DIR 
fi

#cd $cur_dir
echo "copy data from $SRC_DIR/$DATA_DIR to $DES_DIR..."
cp -r $SRC_DIR/$DATA_DIR $DES_DIR/data
#rsync -avhW --no-compress --progress $SRC_DIR/$DATA_DIR $DES_DIR/data
sudo chown -R vldb:vldb $DES_DIR/data 
