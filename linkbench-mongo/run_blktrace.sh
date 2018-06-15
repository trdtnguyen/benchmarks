#!/bin/bash
#source const.sh
#$1: device
#$2: output file
outfile=$2
sudo blktrace -d $1 -o - | blkparse -i - > $2
exit
#sudo blktrace -d $1 -a complete -o - | blkparse -f "%T %t %c %p %d %S %N \n" -i - > $2
#sudo blktrace -d $1 -a complete -o - | blkparse  -i - > $2
#if [ $IS_BTT=1 ];then
#sudo blktrace -d $1 -o - | blkparse -d ${outfile}_btt.bin -i - > $2
#else
sudo blktrace -d $1 -a complete -o - | blkparse -i - > $2
#fi
