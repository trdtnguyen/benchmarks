#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$outdir/load.txt

echo "Run blktrace"
#${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE} ${BLKTRACE_OUT} &

${BENCHMARK_HOME}/start_server.sh $cache_size
${YCSB_HOME}/bin/ycsb load ${YCSB_MONGODB_ASYNC_RUN} -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT}  -p mongodb.url=mongodb://${HOST} -p mongodb.batchsize=100 -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.load

#echo "YCSB finished. End blktrace process."
pid=$(ps -opid= -C blktrace)
sudo kill -15  $pid
#${BENCHMARK_HOME}/run.sh
${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.usertable.stats({indexDetails : true}))' > ${outdir}/load_ycsb.txt
${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.serverStatus())' > ${outdir}/load_ycsb_serverStatus.txt

if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Build blkparse plot..."
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${PLOT_OUT_INS}
fi
${BENCHMARK_HOME}/stop_server.sh
