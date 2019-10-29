#!/bin/bash
source const.sh

cur_dir=$(pwd)


sudo sysctl vm.drop_caches=3
sleep $SLEEP_DROP_CACHE 
sudo sysctl vm.drop_caches=3

#don't reset pmem on recovery test
if [ $# -eq 0 ]; then
echo "clear data in $PMEM_DIR"
sudo rm -rf $PMEM_DIR/*
fi

echo "clear data in $DES_DIR"
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

#Set a dummy parameter to copy from recv data (test recovery data)
if [ $# -eq 0 ]; then
echo "copy data from $SRC_DIR/$DATA_DIR to $DES_DIR..."
cp -r $SRC_DIR/$DATA_DIR $DES_DIR/data
else
#cd $cur_dir
echo "copy data from $SRC_DIR/$DATA_DIR_RECV to $DES_DIR..."
cp -r $SRC_DIR/$DATA_DIR_RECV $DES_DIR/data
cp $SRC_DIR/pmemobjfile $PMEM_DIR/
fi
#rsync -avhW --no-compress --progress $SRC_DIR/$DATA_DIR $DES_DIR/data
sudo chown -R vldb:vldb $DES_DIR/data 
