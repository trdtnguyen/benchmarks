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

if [ $IS_NVME_SSD -eq 1 ]; then
#reset and open streams
${BENCHMARK_HOME}/reset_and_open_stream.sh $NUM_OPEN_STREAM 
sleep 5
fi

n=1
if [ -n "$3" ]; then
	n=$3
fi	
echo "=============== Repeat $n time(s)"
for (( i=1; i<=$n; i++ ))
do
	echo "========================== Bench mark $i th runs... ============="
	${BENCHMARK_HOME}/start_server.sh $cache_size
	${BENCHMARK_HOME}/run.sh $outdir $cache_size
	${BENCHMARK_HOME}/stop_server.sh
	sleep 5 
done
i=$(($i-1))
echo "=============================  Finish $i times.====================="
