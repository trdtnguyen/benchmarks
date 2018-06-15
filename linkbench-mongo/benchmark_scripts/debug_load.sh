#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$outdir/load.txt

#mongod already started by gdb 
#${BENCHMARK_HOME}/start_server.sh $cache_size


${LINKBENCH_HOME}/bin/linkbench  -c ${LINKBENCH_CONFIG_FILE} -l -csvstats ${LB_CSVSTATS_LOAD_FILE} -csvstream ${LB_CSVSTREAM_LOAD_FILE} -D maxid1=${LB_NUM_REC} -D loaders=${LB_LOAD_THREADS} -D debuglevel=${LB_DEBUG_LEVEL}  2>&1 | tee ${outfile} 

#${BENCHMARK_HOME}/stop_server.sh
