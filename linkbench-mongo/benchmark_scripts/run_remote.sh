#! /bin/bash                                                                                                                                                                           

source const.sh
if [ ! -d ${BENCHMARK_HOME}/${BLK_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${BLK_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${PLOT_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${PLOT_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${BTT_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${BTT_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${WORKLOAD_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${WORKLOAD_DIR}
fi

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 
#echo "Stat mongod server"
#${MONGO_HOME}/mongod -f ${MONGO_CONFIG_FILE} &
echo "Run blktrace"

${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE} ${BLKTRACE_OUT} &
echo "Run mongostat"
mongostat --host ${HOST} > ${MONGO_STAT_FILE} &
echo "Run YCSB ..."
#choose run normally (sync) or async
${YCSB_HOME}/bin/ycsb run ${YCSB_MONGODB_ASYNC_RUN} -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT}  -p mongodb.url=mongodb://${YCSB_HOST}/ycsb?${YCSB_MONGODBURL_RUN_OPTION} -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt

echo "YCSB finished. End blktrace process."
pid=$(ps -opid= -C blktrace)
sudo kill -15 $pid

#echo "End iostat tracking"
#pid2=$(ps -opid= -C iostat)
#sudo kill -9 $pid2

echo "End mongostat process"
pid3=$(ps -opid= -C mongostat)
sudo kill -9 $pid3
echo "Take the snapshot of current ycsb"
mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.usertable.stats())' > ycsb_usertable_stats.txt
mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.serverStatus())' > ycsb_serverStatus.txt
#require profile enable in mongod
mongo --host=${HOST} --quiet ycsb --eval 'DBQuery.shellBatchSize=1000000000;db.system.profile.find({millis: {"$gt":100}})' > ${PROFILE_FILE} 

echo "Get benchmark result"

#echo "Measure amount of write data..."
#.${BENCHMARK_HOME}/amount_write.sh ${BENCHMARK_HOME}/${BLK_DIR}/${BLKTRACE_OUT} ${BENCHMARK_HOME}/${COUNT_FILE}

#echo "Analysis iostat"
#tail -n +2 ${IOSTAT_FILE} > temp 
#awk 'NR % 4 == 2' temp

echo "Print output results"
awk -v date="$(date --rfc-3339=seconds)" '/cacheSizeGB/ {printf("%s\t%s\t%s\t%s",date,"'"${YCSB_MONGODB_ASYNC_RUN}"'", "'"${MONGO_OPTION_JOURNAL}"'",$0)}'  ${MONGO_CONFIG_FILE} >> ${OVERALL_FILE}
#device, workload, number ops, num threads, runtime
awk '/RunTime/ {printf("\t%s\t%s\t%s\t%s\t%s","'"${DEVICE}"'","'"${YCSB_WORKLOAD}"'","'"${YCSB_REC_COUNT}"'","'"${THREADS}"'",$3)}' \
	${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE}

#Throughput
awk '/Throughput/ {printf("\t%s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE} 

#count amount of data written
sudo grep 'W\|WS\|WSM\|WM' ${BLKTRACE_OUT} | awk '{ sum+=$10 } END { printf("\tw_in_%s: %d MB","'"${DEVICE}"'", (sum*512)/(1024*1024)) }' >> ${OVERALL_FILE} 
sudo grep 'W\|WS\|WSM\|WM' ${BLKTRACE_OUT2} | awk '{ sum+=$10 } END { printf("\tw_in_%s: %d MB","'"${DEVICE2}"'" ,(sum*512)/(1024*1024)) }' >> ${OVERALL_FILE} 
if [ -n ${DEVICE3} ]; then
	sudo grep 'W\|WS\|WSM\|WM' ${BLKTRACE_OUT3} | awk '{ sum+=$10 } END { printf("\tw_in_%s: %d MB","'"${DEVICE3}"'" ,(sum*512)/(1024*1024)) }' >> ${OVERALL_FILE} 
fi
#count number of slow operation (> 100ms), require profile enable in mongod

sudo grep 'find' ${PROFILE_FILE} | awk '{ sum+=1 } END { printf("\t#slow_find: %d ",sum) }' >> ${OVERALL_FILE} 
sudo grep 'update' ${PROFILE_FILE} | awk '{ sum+=1 } END { printf("\t#slow_upd: %d ",sum) }' >> ${OVERALL_FILE} 
#sudo grep 'W\|WS\|WSM\|WM' ${BENCHMARK_HOME}/${BLK_DIR}/${BLKTRACE_OUT} | awk '{ sum+=$6 } END { printf("\t%d MB", sum/(1024*1024)) }' >> ${OVERALL_FILE} 
#Read avg latency, 99th latency, pattern 1: READ, pattern2: 99thPercentileLatency
awk '/READ.*AverageLatency/ {printf("\tREAD_avg_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE} 
awk '/READ.*99thPercentileLatency/ {printf("\tREAD_99th_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE} 
awk '/UPDATE.*AverageLatency/ {printf("\tUPDATE_avg_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE} 
awk '/UPDATE.*99thPercentileLatency/ {printf("\tUPDATE_99th_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OVERALL_FILE} 

mount -l | awk -v d="$DEVICE" '$1 ~ d {printf("\t%s\n",$0)}' >> ${OVERALL_FILE}
if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Build blkparse plot..."
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${PLOT_OUT}
#	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} .
#	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT2} ${PLOT_OUT2}
#	if [ -n "${DEVICE3}" ]; then
#	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT3} ${PLOT_OUT3}
#	fi
fi
echo "Finished."

