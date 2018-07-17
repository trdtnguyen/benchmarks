#! /bin/bash                                                                                                                                                                           

#common changed
#METHOD=ORI
METHOD=OP6_wla2_23M_32k_6h_nors

#BENCHMARK_HOME=/ssd2/benchmark/linkbench
BENCHMARK_HOME=/home/vldb/benchmarks/ycsb-mongo

#NVME SSD specify variables
#number of streams should open: ORI: 0;OP6 (boundary): 7,  OP8 (DSM-3): 10; OP11 (DSM-5): 14; OP10 (file-based): 13
#change this value every time use switch the approach 
NUM_OPEN_STREAM=0
#NUM_OPEN_STREAM=7
#NUM_OPEN_STREAM=8
#NUM_OPEN_STREAM=10
#NUM_OPEN_STREAM=12
#NUM_OPEN_STREAM=14

IS_RESET=0
IS_NVME_SSD=0

MOUNT_POINT='ssd1' #for trace_disk_util.sh

YCSB_HOME=/home/vldb/YCSB

########################################
YCSB_REC_COUNT=10000000
YCSB_OP_COUNT=1000000000
THREADS=40
#THREADS=120
YCSB_WORKLOAD=workloada
#YCSB_WORKLOAD=workloada2
YCSB_MAX_TIME=300
#YCSB_MAX_TIME=7200
########################################
# Linkbench overwriten cofig key-value

############################################

IOSTAT_FILE=iostat.txt
TOP_FILE=top.txt
LINUX_STAT_FILE=linux_stat.txt

MONGO_DATA_PATH=/mnt/ssd1/data/db
MONGO_HOME=/home/vldb/mongo-pmem
MONGO_CONFIG_FILE=${BENCHMARK_HOME}/mongod.conf


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

