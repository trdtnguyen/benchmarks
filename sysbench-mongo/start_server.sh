# !/bin/bash                                                                                                                                                                             
#BENCHMARK_HOME=/home/vldb/benchmark/mongodb

source const.sh

#ulimit, login as root required
#echo "Set ulimit"
#sudo ulimit -n 640000
#independant usage: ./start_server.sh <cache_sizeGB>
cache=$1 
echo "Start mongod"
############ Begin start mongod
#disable NUMA
sudo sysctl -w vm.zone_reclaim_mode=0
if [ "${IS_DIRECT_IO}" -eq 1 ]; then
#	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data]" &
#numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} --wiredTigerCacheSizeGB=${WT_CACHE_SIZE}  ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &

#this version use cachesize from mongod.conf file
#numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &

#this version use cachesize from parameter
# eviction_target < eviction_trigger
# eviction_target = 80 as default
# eviction_trigger = 95 as default
if [ "${IS_USE_OPLOG}" -eq 1 ]; then
#add --master for using oplog
#numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &
#numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=90,eviction_trigger=95,eviction_dirty_target=90,eviction_dirty_trigger=95,eviction=(threads_max=8,threads_min=6)" &
numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=90,eviction_trigger=95,eviction_dirty_target=90,eviction_dirty_trigger=95,eviction=(threads_max=16,threads_min=8)" &
else
numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &
fi
else
#	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} &
#numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} &

if [ "${IS_USE_OPLOG}" -eq 1 ]; then
#add --master for using oplog
numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &
else
numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" &
fi
fi #DIRECT_IO
#######End start mongod

#${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} --dbpath=${MONGO_DATA_PATH}

