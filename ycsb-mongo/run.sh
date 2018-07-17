#! /bin/bash                                                                                                                                                                           

source const.sh

if [ ! -d ${BENCHMARK_HOME}/${WORKLOAD_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${WORKLOAD_DIR}
fi

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$BENCHMARK_HOME/${outdir}/run.txt

if [ ! -d $outdir ]
then
	mkdir -p $BENCHMARK_HOME/$outdir
fi

#start report file
date="$(date --rfc-3339=seconds)"
printf "\n$date $METHOD $cache_size " >> ${OVERALL_FILE}



echo "Run YCSB ..."
cd $YCSB_HOME
${YCSB_HOME}/bin/ycsb run ${YCSB_MONGODB_ASYNC_RUN} -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p maxexecutiontime=${YCSB_MAX_TIME} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT} -p fieldlength=${YCSB_DOC_SIZE}  -p mongodb.url=mongodb://${YCSB_HOST}/ycsb?${YCSB_MONGODBURL_RUN_OPTION} -threads ${THREADS}  2>&1 | tee ${outfile} 

echo "YCSB finished. End background processes"

cd $BENCHMARK_HOME

echo "Get benchmark result"
${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.usertable.stats({indexDetails : true}))' > ${outdir}/ycsb_usertable_stats.txt
${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.serverStatus())' > ${outdir}/ycsb_serverStatus.txt

#awk '/COMPLETED/ {printf("num_req_completed %s ",$8)}' ${outfile} >> ${OVERALL_FILE}
awk '/RunTime/ {printf("\t%s\t%s\t%s\t%s\t%s\t%s","'"${DEVICE}"'","'"${YCSB_WORKLOAD}"'","'"${YCSB_REC_COUNT}"'","'"${YCSB_OP_COUNT}"'","'"${THREADS}"'",$3)}' \
	    ${outfile}  >> ${OVERALL_FILE}
#ops
awk '/Throughput/ {printf("ops/s \t%s",$3)}' ${outfile}  >> ${OVERALL_FILE}


#number of checkpoint generate
printf " num_ckpts " >> ${OVERALL_FILE} 
grep "btree checkpoint generation" ${outdir}/ycsb_usertable_stats.txt | awk -F"[:,]" '{printf(" %s \t",$2)}' >> ${OVERALL_FILE}
#echo "Print output results"
#awk '{sum1+=$2; count+=1} END {printf(" runtime = %s (s) \t avg OPS/s = %s \t \n", count*60, ((sum1*1.0)/count))}' $LB_IOPS_TEM2_OUT >> ${OVERALL_FILE}

#amount of coll, idx data written
#amount of coll, idx data written
cat ${outdir}/ycsb_usertable_stats.txt | grep "bytes written from cache" | awk -F"[:,]" '{printf("written_from_cached: %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
#amount of log data written
cat ${outdir}/ycsb_serverStatus.txt | grep "log bytes written" | awk -F"[:,]" '{printf("log_written: %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}

#Read avg latency, 99th latency, pattern 1: READ, pattern2: 99thPercentileLatency
awk '/READ.*AverageLatency/ {printf("\tREAD_avg_lat: %s",$3)}' ${outfile}  >> ${OVERALL_FILE} 
awk '/READ.*99thPercentileLatency/ {printf("\tREAD_99th_lat: %s",$3)}' ${outfile}  >> ${OVERALL_FILE} 
awk '/UPDATE.*AverageLatency/ {printf("\tUPDATE_avg_lat: %s",$3)}' ${outfile}  >> ${OVERALL_FILE} 
awk '/UPDATE.*99thPercentileLatency/ {printf("\tUPDATE_99th_lat: %s",$3)}' ${outfile}  >> ${OVERALL_FILE} 


echo "Finished."

