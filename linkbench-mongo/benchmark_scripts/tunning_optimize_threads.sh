# !/bin/sh

#author: Trong-Dat Nguyen
#Tunning the optimized number of threads by using throughput (ops/s) and 
#99th read latency, 99th write latency
#BENCHMARK_HOME=/home/vldb/benchmark/mongodb 
source const.sh


OUT_FILE=opt_threads.txt
TRACK_DEV=sda1

MAX_LOGICAL_CPUS=40
MAX=120
#vals=(1 2 4 8 16 20 40 64 80 100 120 140 160 180 200 220 240)
vals=(260 280 300 320)
echo "=============== Repeat $vals[2]"
for i in ${vals[@]}
do
	echo "=============== Run with $i threads ... ============================"
	${MONGO_HOME}/mongod  -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} &
    ${YCSB_HOME}/bin/ycsb run ${YCSB_MONGODB_ASYNC_RUN} \
	   	-s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT} \
	  	-p mongodb.url=mongodb://${YCSB_HOST}/ycsb?${YCSB_MONGODBURL_RUN_OPTION} \
	   	-threads ${i}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt
	${BENCHMARK_HOME}/stop_server.sh

	awk -v date="$(date --rfc-3339=seconds)" '/RunTime/ {printf("%s\t%s\t%s\t%s\t%s", date,"'"${i}"'","'"${YCSB_WORKLOAD}"'","'"${YCSB_REC_COUNT}"'",$3)}' \
	${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE}
	awk '/Throughput/ {printf("\t%s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE} 
	awk '/READ.*AverageLatency/ {printf("\tREAD_avg_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE} 
	awk '/READ.*99thPercentileLatency/ {printf("\tREAD_99th_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE} 
	awk '/UPDATE.*AverageLatency/ {printf("\tUPDATE_avg_lat: %s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE} 
	awk '/UPDATE.*99thPercentileLatency/ {printf("\tUPDATE_99th_lat: %s\n",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> ${OUT_FILE} 
done
echo "=============================  Finish.====================="
