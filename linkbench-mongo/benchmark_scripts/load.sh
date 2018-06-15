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


${LINKBENCH_HOME}/bin/linkbench  -c ${LINKBENCH_CONFIG_FILE} -l -csvstats ${LB_CSVSTATS_LOAD_FILE} -csvstream ${LB_CSVSTREAM_LOAD_FILE} -D maxid1=${LB_NUM_REC} -D loaders=${LB_LOAD_THREADS} -D debuglevel=${LB_DEBUG_LEVEL}  2>&1 | tee ${outfile} 

#echo "YCSB finished. End blktrace process."
pid=$(ps -opid= -C blktrace)
sudo kill -15  $pid
#${BENCHMARK_HOME}/run.sh
${MONGO_HOME}/mongo --host=${HOST} --quiet ${LB_DB_NAME} --eval 'printjson(db.node.stats({indexDetails : true}))' > ${outdir}/$LB_NODE_LOAD 
${MONGO_HOME}/mongo --host=${HOST} --quiet ${LB_DB_NAME} --eval 'printjson(db.link.stats({indexDetails : true}))' > ${outdir}/$LB_LINK_LOAD 
${MONGO_HOME}/mongo --host=${HOST} --quiet ${LB_DB_NAME} --eval 'printjson(db.count.stats({indexDetails : true}))' > ${outdir}/$LB_COUNT_LOAD 

if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Build blkparse plot..."
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${PLOT_OUT_INS}
fi
${BENCHMARK_HOME}/stop_server.sh
