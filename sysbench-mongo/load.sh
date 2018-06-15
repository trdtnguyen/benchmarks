# !/bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$outdir/load.txt

echo "It will reset your data..."
rm -rf ${MONGO_DATA_PATH} 
mkdir -p ${MONGO_DATA_PATH}
echo "Run blktrace"
#${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE} ${BLKTRACE_OUT} &

${BENCHMARK_HOME}/start_server.sh $cache_size
#pass the 2nd parameter as 1 for load only
${BENCHMARK_HOME}/run.simple.bash ${SB_CONFIG_FILE} 1 $outdir

#echo "YCSB finished. End blktrace process."
pid=$(ps -opid= -C blktrace)
sudo kill -15  $pid
#${BENCHMARK_HOME}/run.sh

${MONGO_HOME}/mongo --host=${HOST} --quiet $DB_NAME --eval 'printjson(db.sbtest1.stats({indexDetails : true}))' > ${outdir}/${DB_NAME}_1

${BENCHMARK_HOME}/stop_server.sh
