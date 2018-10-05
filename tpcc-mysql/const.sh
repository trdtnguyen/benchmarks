#!/bin/bash

#run mode options:
#ori 1, dbw 2, wal 3, even_pmembuf 4, single_pmembuf 5, less_pmem_buf 6, wal + less 7
mode=7

if [ $mode -eq 1 ]; then
METHOD=ori
elif [ $mode -eq 2 ]; then
METHOD=dwb
elif [ $mode -eq 3 ]; then
METHOD=wal
elif [ $mode -eq 4 ]; then
METHOD=even
elif [ $mode -eq 5 ]; then
METHOD=single
elif [ $mode -eq 6 ]; then
METHOD=LESS
elif [ $mode -eq 7 ]; then
METHOD=LSB
else
METHOD=ALL
fi

DEV_NAME=850pro

IS_RESET=1
#IS_RESET=0 #for non-SATA dev

# for reset_debug.sh
PMEM_DIR=/mnt/pmem1
SRC_DIR=/mnt/nvme1
DES_DIR=/mnt/ssd1
#DES_DIR=/mnt/nvme1

IS_INTEL_NVME=0
#set 1 for 960 Pro
IS_SAMSUNG_NVME=0

#DATA_DIR=tpcc_w100_4k
#WH=100

##DATA_DIR=tpcc_w300_16k
#DATA_DIR=tpcc_w300_4k
#WH=300


DATA_DIR=tpcc_w1000_4k
WH=1000


METHOD=${METHOD}_${DEV_NAME}_WH${WH}

##################################################

#for PMEMBUF settings, the same value is in my.cnf file
IS_PMEM_APP=0
PMEM_HOME_DIR=/mnt/pmem1
PMEM_POOL_SIZE=16384

#for UNIV_PMEMOBJ_BUF_XXX family
PMEM_BUF_SIZE=128
PMEM_BUF_N_BUCKETS=32
PMEM_BUF_BUCKET_SIZE=512

#for UNIV_PMEMOBJ_BUF_FLUSHER
PMEM_N_FLUSH_THREADS=32
PMEM_FLUSH_THRESHOLD=1

# for UNIV_PMEMOBJ_BUF_PARTITION
IS_PMEM_PARTITION=1 #set this to 1 for SINGLE, LESS partition
#PMEM_N_SPACE_BITS=3
PMEM_N_SPACE_BITS=5
#PMEM_PAGE_PER_BUCKET_BITS=31 #for SINGLE
PMEM_PAGE_PER_BUCKET_BITS=10 #for EVEN

###################################################



#For statistic information
TRACE_FILE1=trace_flush.txt
TRACE_FILE2=part_debug.txt
PERF_SCHEMA_FILE=perf_schema_trace.txt

#Those values for using nvme, smartctl, umount
NVME_DEV1=/dev/nvme0n1
SSD_DEV1=/dev/sdd1 
#SSD_DEV1=/dev/sdb1

DEV1=$SSD_DEV1


SLEEP_DROP_CACHE=2
SLEEP_CP=90 #small_data: 60, large_data: 120
#SLEEP_CP=120 #small_data: 60, large_data: 120
SLEEP_DB_LOAD=30 #sleep time between start server finish and run benchmark
SLEEP_BETWEEN_BM=60 #sleep time between benchmarks

WARMUP_TIME=60
#WARMUP_TIME=1

#change this value according to the number of warehouse in the dataset 
CONN=32
#CONN=50
#CONN=100

#RUNTIME=3600 #for long benchmark
RUNTIME=900 #for average benchmark
#RUNTIME=800 #for recovery benchmark
#RUNTIME=100 #for debugging

SSD_SIZE=512 #GB

#######         Recovery
RECV_FILE=rec_trace.out
#sleep time (in seconds)  may diffenrent depend on the data size
#this used for recovery benchmark
#THREAD_KILLER_SLEEP=310
THREAD_KILLER_SLEEP=$RUNTIME
###################################

BENCHMARK_HOME=/home/vldb/benchmarks/tpcc-mysql
MYSQL_HOME=/usr/local/mysql
MYSQL_BIN=$MYSQL_HOME/bin
HOST=115.145.173.195
#HOST=localhost
PORT=3306
USER=vldb
DBNAME=tpcc
PASS=""

#Disable DBW for UNIV_PMEMOBJ_BUF
IS_USE_DBW=0


IS_TRACE=0
#IS_TRACE=1

#CONFIG=$BENCHMARK_HOME/my.cnf
CONFIG=/etc/my.cnf
#EXECUTES
MYSQL=$MYSQL_HOME/bin/mysql
TPCCLOAD=$BENCHMARK_HOME/tpcc_load
TABLESQL=$BENCHMARK_HOME/create_table.sql
CONSTRAINTSQL=$BENCHMARK_HOME/add_fkey_idx.sql
TPCC_LOAD=$BENCHMARK_HOME/tpcc_load
TPCC_START=$BENCHMARK_HOME/tpcc_start

OUT_DIR=$BENCHMARK_HOME/output

TRACE_FILE=trace.txt
PMEM_TRACE=pmem_trace.sh
sumfile=$BENCHMARK_HOME/summary.txt
statfile=$BENCHMARK_HOME/overall.txt
perffile=$BENCHMARK_HOME/perf_overall.txt

#METHOD: ori, pmemblk, pmemmem, pmemlogbuf, pmemlogall
#METHOD=pmemblk
#METHOD=pmembuf
#WH=1000
#WH=300
#CONN=24
#RUNTIME=7200
#RUNTIME=600
BP=60
