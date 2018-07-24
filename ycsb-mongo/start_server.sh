# !/bin/bash
source const.sh

#ulimit, login as root required
#echo "Set ulimit"
#sudo ulimit -n 640000
cache=$1


WT_ENGINE_CONFIG_VAL=""
printf "===========================\n"
echo "Mode $mode: $METHOD"
printf "WiredTiger Buffer size:\t%s MB\n" "$cache"

if [ $mode -eq 1 ]; then
#do nothing
EXTRA_PARAM=
printf "===========================\n"
elif [ $mode -eq 2 ]; then
	#EVEN
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	printf "PMEM buf size:\t\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "===========================\n"
	EXTRA_PARAM="--pmem_home_dir=$PMEM_HOME_DIR --pmem_pool_size=$PMEM_POOL_SIZE --pmem_buf_size=$PMEM_BUF_SIZE --pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --pmem_buf_flush_pct=1 --pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD"
elif [ $mode -eq 3 ]; then
	#SINGLE
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	PMEM_PAGE_PER_BUCKET_BITS=31
	printf "PMEM buf size:\t\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "===========================\n"
	EXTRA_PARAM="--pmem_home_dir=$PMEM_HOME_DIR --pmem_pool_size=$PMEM_POOL_SIZE --pmem_buf_size=$PMEM_BUF_SZIE --pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --pmem_buf_flush_pct=1 --pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --pmem_n_space_bits=$PMEM_N_SPACE_BITS --pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
else
	#LESS
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	PMEM_PAGE_PER_BUCKET_BITS=10
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "===========================\n"
	EXTRA_PARAM="--pmem_home_dir=$PMEM_HOME_DIR --pmem_pool_size=$PMEM_POOL_SIZE --pmem_buf_size=$PMEM_BUF_SZIE --pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --pmem_buf_flush_pct=1 --pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --pmem_n_space_bits=$PMEM_N_SPACE_BITS --pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
fi # if [ $mode -eq 1 ];


echo "Last EXTRA_PARAM is $EXTRA_PARAM"

echo "Start mongod"
############ Begin start mongod
#disable NUMA
sudo sysctl -w vm.zone_reclaim_mode=0
if [ "${IS_DIRECT_IO}" -eq 1 ]; then
	if [ "${IS_USE_OPLOG}" -eq 1 ]; then
	numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=90,eviction_trigger=95,eviction_dirty_target=90,eviction_dirty_trigger=95,eviction=(threads_max=16,threads_min=8)" 
	else # IS_USE_OPLOG
	numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${EXTRA_PARAM} ${WT_ENGINE_CONFIG_STR}="direct_io=[data],eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" 
	fi
else #IS_DRIECT_IO
	if [ "${IS_USE_OPLOG}" -eq 1 ]; then
#add --master for using oplog
	numactl --interleave=all	${MONGO_HOME}/mongod --master -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${EXTRA_PARAM} ${WT_ENGINE_CONFIG_STR}="eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" 
	else #IS_USE_OPLOG
	numactl --interleave=all	${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} ${WT_CACHE_SIZE}=$cache ${MONGO_OPTION_JOURNAL} ${EXTRA_PARAM} ${WT_ENGINE_CONFIG_STR}="eviction_target=40,eviction_trigger=80,eviction_dirty_target=40,eviction_dirty_trigger=80,eviction=(threads_max=8,threads_min=6)" 
	fi
fi #DIRECT_IO
#######End start mongod
