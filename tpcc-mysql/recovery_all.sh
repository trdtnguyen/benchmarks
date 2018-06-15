# !/bin/bash
#usage: ./autorun.sh
source const.sh

cache_arr=(256 512 1024 2048 3072 4096)
thread_arr=(64 64 64 64 64 64)
pm_buf_arr=(64 128 256 256 256 256)
pm_n_bucket_arr=(32 32 64 64 64 64)
pm_bucket_size_arr=(256 512 512 512 512 512)
pm_flush_threshold_arr=(1 1 5 30 30 30) #for LESS, EVEN
#pm_flush_threshold_arr=(1 1 1 1 1 1) #for LESS, EVEN


echo "cache_arr[@] = $cache_arr[@]"

#Choose only one config
#for i in {3..4}; do
for i in {4..4}; do
	printf "\n==================================================\n"
	echo "========Loop $i  Buffer pool = ${cache_arr[i]} MB, threads = ${thread_arr[i]} ============" 

# (1) Reset the data
	$BENCHMARK_HOME/reset_debug.sh		

	echo "sleep $SLEEP_CP seconds after cp..."
	sleep $SLEEP_CP

# (2) Start the mysqld server
if [ $mode -eq 1 ]; then
	#Original
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} &
elif [ $mode -eq 2 ]; then
	#DWB
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} &
elif [ $mode -eq 3 ]; then
	#WAL
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} &
elif [ $mode -eq 4 ]; then
	#PMEM_BUF with EVEN partition
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]} &
elif [ $mode -eq 5 ]; then
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

# (3) Run the TPC-C benchmark and the thread_killer
echo "(3) Run the TPC-C benchmark method $METHOD"
		$BENCHMARK_HOME/thread_killer.sh &
		$BENCHMARK_HOME/run.sh ${LAST_METHOD} ${thread_arr[i]}

# (4) Stop the server
	#We don't need to stop the server. The thread_killer will handle that

# (5) Collect final result
	printf "=========================================================\n"
done

printf "\n======================================\n"
echo "All benchmarks are finished"
printf "======================================\n"

