#! /bin/bash                                                                                                                                                                           

HOST=115.145.173.215:27017
#common changed
METHOD=ORI_ORISB_4KB
#METHOD=OP6_DEBUG_PAGE_TYPE_up_80M_32k_nors
#METHOD=ORI_up_80M_32k_nors

BENCHMARK_HOME=/ssd2/benchmark/sysbench-mongodb
SB_HOME=/home/vldb/sysbench-mongodb
SB_CONFIG_FILE=${BENCHMARK_HOME}/config.bash
SB_CONFIG_FILE_LOAD=${BENCHMARK_HOME}/config_load.bash

MONGO_DATA_PATH=/ssd1/data/db
MONGO_HOME=/home/vldb/mongodb-dev
MONGO_CONFIG_FILE=${BENCHMARK_HOME}/mongod.conf

#NVME SSD specify variables
#number of streams should open: ORI: 0;OP6 (boundary): 7,  OP8 (DSM-3): 10; OP11 (DSM-5): 14; OP10 (file-based): 13
#change this value every time use switch the approach 
NUM_OPEN_STREAM=0

IS_RESET=0
IS_NVME_SSD=0

#IS_NVME_SSD=1
NVME_TOOLS=/ssd2/benchmark/linkbench/nvme-user
NVME_DEV_ROOT=/dev/nvme0n1
NVME_DEV=/dev/nvme0n1p1
#MOUNT_POINT='nvme1' #for trace_disk_util.sh
MOUNT_POINT='ssd1' #for trace_disk_util.sh
NOSA_NAME=nosa.txt
STREAM_NAME=stream.txt

#LINKBENCH_HOME=/home/vldb/linkbenchX
#LINKBENCH_CONFIG_FILE=${LINKBENCH_HOME}/config/LinkConfigMongoDBv2.properties

#LINKBENCH_CONFIG_FILE=${BENCHMARK_HOME}/LinkConfigMongoDBv2.properties
DB_NAME=sbtest

########################################
# SB overwriten cofig key-value

#number threads of loaders
#SB_LOAD_THREADS=20
SB_LOAD_THREADS=1
SB_RUN_THREADS=20 #N
SB_WAREHOUSE=100 #W
SB_DURATION=3600 #D
#LB_MAX_TIME=3600
#LB_MAX_TIME=600
############################################
#collections: CUSTERM, DISTRICT, ITEM, NEW_ORDER, STOCK, WAREHOUSE


IOSTAT_FILE=iostat.txt
TOP_FILE=top.txt
LINUX_STAT_FILE=linux_stat.txt
SBTEST_RUN=sbtest_run.txt
SERVER_STATUS_RUN=server_status_run.txt


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
#IS_DIRECT_IO=0
#IS_USE_OPLOG=1
IS_USE_OPLOG=0
#TRACK_DEV=nvme0n1
TRACK_DEV=sda4
TRACK_TOP_FILE=track_top_${YCSB_REC_COUNT}.txt
TRACK_IOSTAT_FILE=track_iostat_${YCSB_REC_COUNT}.txt

#HOST=192.168.1.1:27017
#MONGOS_HOST1=vldb10:30000
#MONGOS_HOST1=192.168.1.24:27017
MONGOS_HOST1=192.168.1.24:27017,192.168.1.1:27018
#MONGOS_HOST2=115.145.173.195:27017

#####################################
#THREADS=40
#THREADS=1

WORKLOAD_DIR=tpcc_out

OPS_RESULT_FILE=throughput.txt
RUNTIME_RESULT_FILE=runtime.txt
LATENCY_FILE_95=latency95.txt
LATENCY_FILE_99=latency99.txt
COUNT_FILE=count.txt
IOSTAT_FILE=iostat.txt
MONGO_STAT_FILE=mongostat.txt
OVERALL_FILE=overall.txt



#=================   BLKTRACE   =========================
#DEVICE: collection, DEVICE2: index, DEVICE3: HDD journal, DEVICE4: remain
#DEVICE=sdb4
#DEVICE=nvme0n1
DEVICE=sda4
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

