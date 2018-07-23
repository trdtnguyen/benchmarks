#! /bin/bash                                                                                                                                                                           
#common changed
#run mode options:
#ori 1, even_pmembuf 2, single_pmembuf 3, less_pmem_buf 4
mode=1

if [ $mode -eq 1 ]; then
METHOD=ori
elif [ $mode -eq 2 ]; then
METHOD=even
elif [ $mode -eq 3 ]; then
METHOD=single
else
METHOD=LESS
fi

# for reset_debug.sh
PMEM_DIR=/mnt/pmem1
SRC_DIR=/mnt/nvme1
DES_DIR=/mnt/ssd1/data


#The pair (#doc, name)
YCSB_REC_COUNT=10000000
DATA_DIR=ycsb_mongo_10G_32K #name of the source data in SRC_DIR

#YCSB_REC_COUNT=100000000
#DATA_DIR=ycsb_mongo_100G_32K #name of the source data in SRC_DIR

BENCHMARK_HOME=/home/vldb/benchmarks/ycsb-mongo
YCSB_HOME=/home/vldb/YCSB
MONGO_DATA_PATH=/mnt/ssd1/data/db
MONGO_HOME=/home/vldb/mongo-pmem
MONGO_CONFIG_FILE=${BENCHMARK_HOME}/mongod.conf


IS_RESET=0
IS_NVME_SSD=0

MOUNT_POINT='ssd1' #for trace_disk_util.sh


########################################
YCSB_OP_COUNT=1000000000
THREADS=40
#THREADS=120
YCSB_WORKLOAD=workloada
#YCSB_WORKLOAD=workloada2
YCSB_MAX_TIME=180
#YCSB_MAX_TIME=600
#YCSB_MAX_TIME=7200
########################################

#slep times
SLEEP_CP=5
SLEEP_DB_LOAD=5
SLEEP_BETWEEN_BM=5
############################################

IOSTAT_FILE=iostat.txt
TOP_FILE=top.txt
LINUX_STAT_FILE=linux_stat.txt



# --journal or --nojournal
MONGO_OPTION_JOURNAL=--journal
WT_CACHE_SIZE=--wiredTigerCacheSizeGB
#MONGO_OPTION_JOURNAL=--nojournal
WT_ENGINE_CONFIG_STR=--wiredTigerEngineConfigString
#set 0 or 1 to build gnuplot
IS_BUILD_GRAPH=0
IS_TRACK_LINUX_STAT=0
#IS_BUILD_GRAPH=1
#build seperate graph index, collection, journal, metadata
IS_BUILD_GRAPH_IDX=0
IS_BTT=0
IS_STANDALONE=1
IS_DIRECT_IO=1
IS_USE_OPLOG=0
TRACK_DEV=sda4
TRACK_TOP_FILE=track_top_${YCSB_REC_COUNT}.txt
TRACK_IOSTAT_FILE=track_iostat_${YCSB_REC_COUNT}.txt

HOST=115.145.173.195:27017
#MONGOS_HOST1=vldb10:30000
#MONGOS_HOST1=192.168.1.24:27017
MONGOS_HOST1=192.168.1.24:27017,192.168.1.1:27018
#MONGOS_HOST2=115.145.173.195:27017
YCSB_HOST=$HOST
if [ $IS_STANDALONE -eq 0 ]; then
#	YCSB_HOST=$MONGOS_HOST1,$MONGOS_HOST2
	YCSB_HOST=$MONGOS_HOST1
else
	YCSB_HOST=$HOST
fi

#####################################
#THREADS=1

WORKLOAD_DIR=ycsb_out

OPS_RESULT_FILE=throughput.txt
RUNTIME_RESULT_FILE=runtime.txt
LATENCY_FILE_95=latency95.txt
LATENCY_FILE_99=latency99.txt
COUNT_FILE=count.txt
IOSTAT_FILE=iostat.txt
MONGO_STAT_FILE=mongostat.txt
OVERALL_FILE=overall.txt

#=================   YCSB  ==============================
YCSB_DOC_SIZE=100
#YCSB_MONGODBURL_OPTION="w=1&maxPoolSize=200"
YCSB_MONGODBURL_LOAD_OPTION="w=1&maxPoolSize=200"
#YCSB_MONGODBURL_RUN_OPTION="w=1&maxPoolSize=200"
#YCSB_MONGODBURL_RUN_OPTION="maxPoolSize=200"
YCSB_MONGODBURL_RUN_OPTION="maxPoolSize=400"
YCSB_MONGODB_BATCHSIZE=100
#choose mongodb or mongodb-async
YCSB_MONGODB_ASYNC_RUN=mongodb-async
#YCSB_MONGODB_ASYNC_RUN=mongodb
#=================   MONGODB  ===========================
#this should be matched with data path in mongod.conf
#MONGO_DATA_PATH=/ssd1/data/db


#=================   BLKTRACE   =========================
#DEVICE: collection, DEVICE2: index, DEVICE3: HDD journal, DEVICE4: remain
#DEVICE=sdb4
#DEVICE=nvme0n1
DEVICE=sdd1
DEVICE2=sdb1
DEVICE3=sdc1
DEVICE4=sdd1
FULL_DEVICE=/dev/${DEVICE}
BLK_DIR=blk
PLOT_DIR=plot
BTT_DIR=btt

if [ ${MONGO_OPTION_JOURNAL} = "--nojournal" ]; then
	JOURNAL_SUFFIX=nj
else
	JOURNAL_SUFFIX=j
fi
BLKTRACE_OUT=${BENCHMARK_HOME}/${BLK_DIR}/${DEVICE}_${JOURNAL_SUFFIX}
BLKTRACE_OUT2=${BENCHMARK_HOME}/${BLK_DIR}/${DEVICE2}_${JOURNAL_SUFFIX}
BLKTRACE_OUT3=${BENCHMARK_HOME}/${BLK_DIR}/${DEVICE3}_${JOURNAL_SUFFIX}
BLKTRACE_OUT4=${BENCHMARK_HOME}/${BLK_DIR}/${DEVICE4}_${JOURNAL_SUFFIX}


PLOT_OUT_INS=${BENCHMARK_HOME}/${PLOT_DIR}/${DEVICE}_${JOURNAL_SUFFIX}_ins

PLOT_OUT=${DEVICE}_${JOURNAL_SUFFIX}
#PLOT_OUT=${BENCHMARK_HOME}/${PLOT_DIR}/${DEVICE}_${JOURNAL_SUFFIX}
PLOT_OUT2=${BENCHMARK_HOME}/${PLOT_DIR}/${DEVICE2}_${JOURNAL_SUFFIX}
PLOT_OUT3=${BENCHMARK_HOME}/${PLOT_DIR}/${DEVICE3}_${JOURNAL_SUFFIX}
PLOT_OUT4=${BENCHMARK_HOME}/${PLOT_DIR}/${DEVICE4}_${JOURNAL_SUFFIX}

