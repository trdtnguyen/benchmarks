# !/bin/sh

source const.sh

outdir=ycsb_out

#Change those arrays based on your experiment purpose
#######################################################
##Config 1: Fix # of threads, various buffer pool and PM buf
#cache_arr=(256 512 1024 2048 3072)
#thread_arr=(64 64 64 64 64 64)
#pm_buf_arr=(256 512 1024 1536 1536)
#pm_n_bucket_arr=(32 32 32 64 64)
#pm_bucket_size_arr=(128 256 512 512 512)
#pm_flush_threshold_arr=(1 1 1 5 30 30)

#cache_arr=(256 512 1024 2048 3072 4096)
#thread_arr=(64 64 64 64 64 64)
#pm_buf_arr=(64 128 256 256 256 256)
#pm_n_bucket_arr=(32 32 64 64 64 64)
#pm_bucket_size_arr=(256 512 512 512 512 512)
#pm_flush_threshold_arr=(1 1 5 30 30 30) #for LESS, EVEN
##pm_flush_threshold_arr=(1 1 5 20 5 5) #for SINGLE

## This config for non-AIO PMEM_BUF
#####Config 2: Fix buffe pool and PMEM_BUF, various # of threads
##cache_arr=(3072 3072 3072 3072 3072)
#cache_arr=(1024 1024 1024 1024 1024)
#thread_arr=(8 16 32 64 128)
#pm_buf_arr=(576 576 576 576 576)
#pm_n_bucket_arr=(256 256 256 256 256)
#pm_bucket_size_arr=(64 64 64 64 64)
#pm_flush_threshold_arr=(30 30 30 30 30) #for LESS, EVEN
##pm_flush_threshold_arr=(5 5 5 5 1) #for SINGLE

#This config is for AIO PMEM_BUF
####Config 3: Fix buffe pool and PMEM_BUF, various # of threads
#Cache size in GB
cache_arr=(3 3 3 3 3)
#cache_arr=(1024 1024 1024 1024 1024)
#thread_arr=(8 16 32 64 128)
thread_arr=(128 64 32 16 8)
pm_buf_arr=(1024 1024 1024 1024 1024)
pm_n_bucket_arr=(64 64 64 64 64)
pm_bucket_size_arr=(256 256 256 256 256)
#pm_flush_threshold_arr=(30 30 30 30 30) #for LESS, EVEN
pm_flush_threshold_arr=(1 1 1 1 1) #for LESS, EVEN
##pm_flush_threshold_arr=(5 5 5 5 1) #for SINGLE
#####################################################

echo "cache_arr[@] = $cache_arr[@]"

for i in {0..4}; do
#for i in {0..0}; do
	printf "\n==================================================\n"
	echo "========Loop $i  Buffer pool = ${cache_arr[i]} MB, threads = ${thread_arr[i]} ============" 

# (1) Reset the data
	$BENCHMARK_HOME/refresh_data.sh		

	echo "sleep $SLEEP_CP seconds after cp..."
	sleep $SLEEP_CP

# (2) Start the mongod server
if [ $mode -eq 1 ]; then
	#Original
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} &
elif [ $mode -eq 2 ]; then
	#PMEM_BUF with EVEN partition
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]} &
elif [ $mode -eq 3 ]; then
	#PMEM_BUF with SINGLE partition
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]} &
else
	#PMEM_BUF with LESS partition, or ALL (WAL + LESS)
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]} &
fi

	echo "sleep $SLEEP_DB_LOAD seconds before run the benchmark..."
	sleep $SLEEP_DB_LOAD 
#exit
# (3) Run the TPC-C benchmark
echo "(3) Run the YCSB benchmark method $METHOD"
		$BENCHMARK_HOME/run.sh $outdir ${LAST_METHOD} ${thread_arr[i]}
echo "sleep 10 seconds before shutdown..."
	sleep 10
# (4) Stop the server
	#====>> finish benchmark
echo "(4) Stop the server and collect results..."
	$BENCHMARK_HOME/stop_server.sh
	pid=$(ps -opid= -C mongod)
	sudo kill -9 $pid
# (5) Collect final result
	echo "sleep $SLEEP_BETWEEN_BM seconds before start the new benchmark"
	sleep $SLEEP_BETWEEN_BM 

	printf "=========================================================\n"
	# Next loop
done

