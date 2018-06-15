# !/bin/bash
#usage: ./autorun.sh
source const.sh

#cache_arr=(256 512 1024 2048 3072 4096 5120 10240)
#thread_arr=(8 16 32 64 128)

#Change those arrays based on your experiment purpose
#######################################################
##Config 1: Fix # of threads, various buffer pool and PM buf
#cache_arr=(128 256 512 1024 2048 3072 4096)
#thread_arr=(64 64 64 64 64 64 64)
#pm_buf_arr=(32 64 128 256 256 256 256)
#pm_n_bucket_arr=(32 32 32 64 64 64 64)
#pm_bucket_size_arr=(128 256 512 512 512 512 512)
#pm_flush_threshold_arr=(1 1 1 5 30 30 30)

###Config 2: Fix buffe pool and PMEM_BUF, various # of threads
cache_arr=(3072 3072 3072 3072 3072)
thread_arr=(8 16 32 64 128 256 512)
pm_buf_arr=(256 256 256 256 256)
pm_n_bucket_arr=(64 64 64 64 64)
pm_bucket_size_arr=(512 512 512 512 512)
pm_flush_threshold_arr=(30 30 30 30 30) #for LESS, EVEN
###pm_flush_threshold_arr=(5 5 5 5 1) #for SINGLE

####Config 3: Single bucket 
#cache_arr=(3072 3072 3072 3072 3072)
#thread_arr=(8 16 32 64 128)
#pm_buf_arr=(256 256 256 256 256)
#pm_n_bucket_arr=(1 1 1 1 1)
#pm_bucket_size_arr=(2048 2048 2048 2048 2048)
#pm_flush_threshold_arr=(1 1 1 1 1) #for LESS, EVEN

#####################################################

echo "cache_arr[@] = $cache_arr[@]"

#for i in {0..6}; do
for i in {5..6}; do
#for i in {3..3}; do
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

# (3) Run the Linkbench benchmark
echo "(3) Run the Linkbench benchmark method $METHOD"
		$BENCHMARK_HOME/run.sh ${LAST_METHOD} ${thread_arr[i]}

# (4) Stop the server
	#====>> finish benchmark
	$BENCHMARK_HOME/stop_server.sh
	sleep 5 

# (5) Collect final result
	printf "\n" >> $sumfile

date=$(date '+%Y%m%d_%H%M%S')
# req/s (from Linkbench)
# 99th_latency (next 10 params) (from Linkbench)
# os_file_write, os_fsyncs (from mysql)
# RW-shared, RW-excl, RW-sx (from mysql)
# log ios (from mysql)
# sum_mutexs, n_reads_buf, n_reads_device (from mysql)
# LBAs_write_to_SSD (from Samsung 850Pro)

if [ $WORKLOAD_TYPE -eq 1 ]; then
	#original
	tail -n 1 $statfile | awk '{printf("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $49, $58, $67, $76, $85, $94, $103, $111,$115,$128,$129,$130,$131,$139,$142,$144,$147)}' >> $sumfile
else
	#write-intensive (countlink = getlink = getlinklist = getnode = 0)
	tail -n 1 $statfile | awk '{printf("%s %s %s %s %s %s na %s %s %s na na na %s %s %s %s %s %s %s %s %s %s ",$1,$4,$16,$22, $31,$40, $49, $58, $67, $75, $79,$92,$93,$94,$95,$103,$106,$108,$111)}' >> $sumfile
fi

	#get total time for waiting flush from buffer pool to disk/nvm
	tail -n 1 $TRACE_FILE1 | awk '{printf("%s ", $7)}' >> $sumfile

	if [ $mode -ge 4 ]; then
		#get statistic information for PMEM
		echo "get statistic info for PMEM"
		tail -n 1 $TRACE_FILE2 >> $sumfile
	fi

	sleep $SLEEP_BETWEEN_BM 

	printf "=========================================================\n"
	# Next loop
done

printf "\n======================================\n"
echo "All benchmarks are finished"
printf "======================================\n"
