# !/bin/sh

#repeat the benchmark $1 time
#call this after finishing loading data

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb 
#usage: ./autorun.sh <cache_size>
# You can run this file by call ./single_run
source const.sh

rm my_mssd_track6.txt
rm my_mssd_track8.txt
rm my_mssd_track9.txt

outdir=$1
cache_size=$2

${BENCHMARK_HOME}/start_server.sh $cache_size
${BENCHMARK_HOME}/run.sh $outdir $cache_size
${BENCHMARK_HOME}/stop_server.sh

#./start_server.sh $cache_size
#./run.sh $outdir $cache_size
#./stop_server.sh
