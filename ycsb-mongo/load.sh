#! /bin/bash

#usage: ./load.sh <outdir> <cache_size>
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$outdir/load.txt

#Remove and create the data dir
rm -rf $DES_DIR
mkdir -p $DES_DIR/db

${BENCHMARK_HOME}/start_server.sh $cache_size &
echo "sleep $SLEEP_DB_LOAD seconds before load data"
sleep $SLEEP_DB_LOAD

echo "Load YCSB..."
cd $YCSB_HOME
${YCSB_HOME}/bin/ycsb load ${YCSB_MONGODB_ASYNC_RUN} -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT}  -p mongodb.url=mongodb://${HOST} -p mongodb.batchsize=100 -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.load

${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.usertable.stats({indexDetails : true}))' > ${outdir}/load_ycsb.txt
${MONGO_HOME}/mongo --host=${HOST} --quiet ycsb --eval 'printjson(db.serverStatus())' > ${outdir}/load_ycsb_serverStatus.txt

echo "Load YCSB finished. End background processes"
cd $BENCHMARK_HOME
${BENCHMARK_HOME}/stop_server.sh
