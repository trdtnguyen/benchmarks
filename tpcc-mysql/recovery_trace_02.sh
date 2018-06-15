# !/bin/bash
source const.sh

#RECV_FILE=rec_trace.out

cache_arr=(256 512 1024 2048 3072 4096)
thread_arr=(64 64 64 64 64 64)
pm_buf_arr=(64 128 256 256 256 256)
pm_n_bucket_arr=(32 32 64 64 64 64)
pm_bucket_size_arr=(256 512 512 512 512 512)
pm_flush_threshold_arr=(1 1 5 30 30 30) #for LESS, EVEN

for i in {4..4}; do
	printf "\n==================================================\n"
	echo "========Loop $i  Buffer pool = ${cache_arr[i]} MB, threads = ${thread_arr[i]} ============" 

# Start the mysqld server
if [ $mode -eq 1 ]; then
	#Original
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} 2>&1 | tee $RECV_FILE
elif [ $mode -eq 2 ]; then
	#DWB
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]}  2>&1 | tee $RECV_FILE
elif [ $mode -eq 3 ]; then
	#WAL
	LAST_METHOD=${METHOD}_${cache_arr[i]}
	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]}  2>&1 | tee $RECV_FILE
elif [ $mode -eq 4 ]; then
	#PMEM_BUF with EVEN partition
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]}  2>&1 | tee $RECV_FILE
elif [ $mode -eq 5 ]; then
	#PMEM_BUF with SINGLE partition
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]}  2>&1 | tee $RECV_FILE
else
	#PMEM_BUF with LESS partition, or ALL (WAL + LESS)
	LAST_METHOD=${METHOD}_${cache_arr[i]}_${pm_buf_arr[i]}

	$BENCHMARK_HOME/start_server.sh ${cache_arr[i]} ${pm_buf_arr[i]} ${pm_n_bucket_arr[i]} ${pm_bucket_size_arr[i]} ${pm_flush_threshold_arr[i]}  2>&1 | tee $RECV_FILE
fi
done
