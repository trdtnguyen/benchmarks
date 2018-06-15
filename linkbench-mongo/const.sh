#! /bin/bash                                                                                                                                                                           

#common changed
#METHOD=ORI
METHOD=OP6_DEBUG_PAGE_TYPE_up_80M_32k_nors
#METHOD=ORI_up_80M_32k_nors

BENCHMARK_HOME=/ssd2/benchmark/linkbench

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

#IS_NVME_SSD=1
NVME_TOOLS=/ssd2/benchmark/linkbench/nvme-user
NVME_DEV_ROOT=/dev/nvme0n1
NVME_DEV=/dev/nvme0n1p1
#MOUNT_POINT='nvme1' #for trace_disk_util.sh
MOUNT_POINT='ssd1' #for trace_disk_util.sh
NOSA_NAME=nosa.txt
STREAM_NAME=stream.txt

#YCSB_HOME=/home/vldb/YCSB
LINKBENCH_HOME=/home/vldb/linkbenchX
LINKBENCH_CONFIG_FILE=${LINKBENCH_HOME}/config/LinkConfigMongoDBv2.properties
#LINKBENCH_CONFIG_FILE=${BENCHMARK_HOME}/LinkConfigMongoDBv2.properties
LB_DB_NAME=graph-linkbench

########################################
# Linkbench overwriten cofig key-value

#maxid1 
#10M rec ~ 10GB
#LB_NUM_REC=4001
LB_NUM_REC=80000001
#LB_NUM_REC=100000001
#LB_NUM_REC=250000001
#LB_NUM_REC=400000001
#LB_NUM_REC=80000001
#LB_NUM_REC=40000001
#number threads of loaders
LB_LOAD_THREADS=20
LB_RUN_THREADS=40
#LB_LOAD_THREADS=40
#LB_RUN_THREADS=10
LB_NUM_REQUESTS=100000000000
#debuglevel=INFO, DEBUG
LB_DEBUG_LEVEL=INFO
#>0 limits the average request rate to that number of requests per second per thread,
#with the inter-request intervals governed by an exponential distribution
LB_REQUEST_RATE=0 #default
#LB_REQUEST_RATE=20000

#LB_MAX_TIME=21600
#LB_MAX_TIME=28800
#LB_MAX_TIME=14400
LB_MAX_TIME=7200
#LB_MAX_TIME=3600
#LB_MAX_TIME=600
############################################

LB_CSVSTATS_LOAD_FILE=lb_csvstats_load.txt
LB_CSVSTREAM_LOAD_FILE=lb_csvstream_load.txt
LB_CSVSTATS_RUN_FILE=lb_csvstats_run.txt
LB_CSVSTREAM_RUN_FILE=lb_csvstream_run.txt
LB_IOPS_OUT=lb_ops
LB_IOPS_TEM2_OUT=lb_ops_tem2
LB_LOG_FILE=lb.log

LB_ADD_LINK_FILE=add_link_tem.txt
LB_GET_LINK_FILE=get_link_tem.txt
LB_UPDATE_LINK_FILE=update_link_tem.txt
LB_DELETE_LINK_FILE=delete_link_tem.txt
LB_UPDATE_NODE_FILE=update_node_tem.txt


LB_SERVER_STATUS=lb_serverStatus.txt
LB_NODE_LOAD=load_node_stats.txt
LB_LINK_LOAD=load_link_stats.txt
LB_COUNT_LOAD=load_count_stats.txt


LB_NODE_RUN=run_node_stats.txt
LB_LINK_RUN=run_link_stats.txt
LB_COUNT_RUN=run_count_stats.txt

IOSTAT_FILE=iostat.txt
TOP_FILE=top.txt
LINUX_STAT_FILE=linux_stat.txt

MONGO_DATA_PATH=/ssd1/data/db
#MONGO_DATA_PATH=/nvme1/data/db
MONGO_HOME=/home/vldb/mongodb-dev
MONGO_CONFIG_FILE=${BENCHMARK_HOME}/mongod.conf


# --journal or --nojournal
MONGO_OPTION_JOURNAL=--journal
WT_CACHE_SIZE=--wiredTigerCacheSizeGB
#MONGO_OPTION_JOURNAL=--nojournal
WT_ENGINE_CONFIG_STR=--wiredTigerEngineConfigString
#set 0 or 1 to build gnuplot
IS_BUILD_GRAPH=1
IS_TRACK_LINUX_STAT=1
#IS_BUILD_GRAPH=1
#build seperate graph index, collection, journal, metadata
IS_BUILD_GRAPH_IDX=1
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

HOST=115.145.173.215:27017
#HOST=192.168.1.1:27017
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
#THREADS=40
#THREADS=1

WORKLOAD_DIR=linkbench_out

OPS_RESULT_FILE=throughput.txt
RUNTIME_RESULT_FILE=runtime.txt
LATENCY_FILE_95=latency95.txt
LATENCY_FILE_99=latency99.txt
COUNT_FILE=count.txt
IOSTAT_FILE=iostat.txt
MONGO_STAT_FILE=mongostat.txt
OVERALL_FILE=overall.txt

#=================   YCSB  ==============================
#YCSB_WORKLOAD=workloada
YCSB_WORKLOAD=workloada2
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

