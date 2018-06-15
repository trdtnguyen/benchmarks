# !/bin/bash #author: Trong-Dat Nguyen 
# Evaluate effect of buffer pool size in WiredTiger MongoDB, standalone server 
# Input: $1 size of dataset (GB) # The script will run YCSB benchmark with WiredTiger's buffer pool size = 2%, 4%, 6%, ..., 20% of dataset 
#BENCHMARK_HOME=/home/vldb/benchmark/mongodb

source const.sh 
TOP_FILE=top.txt
TRACK_DEV=sda1
dram_size=32000
# size is total database size in disk
#10M => 24000, 50M => 71000, 100M => 132
size=59000
#size=71000
LAST_PER=20


if [ -n "$1" ]; then
	size=$1
fi	
two_percent=$((($size/100)*2))
last_val=$((($size/100)*$LAST_PER))
max=$((($dram_size*60/100)-1000))

prev=0
echo $max

echo "=============== Repeat"
for (( cur=$two_percent; cur<=$last_val; cur=$(($cur+$two_percent)) ))
do
	#valid value: 1 ~ 0.6 * D-RAM - 1
	val=$cur
	if [ $cur -lt 1000 ];then
		val=1000
	fi
	if [ $cur -gt $max ];then
		break
	fi
	
	#all checking finished, run the benchmark
	val=$(($val/1000))
	echo "Val=$val, Prev = $prev"
	if [ $prev -eq $val ];then
		echo "Skip $val..."
		continue
	fi

	if [ $prev -eq 0 ];then
		prev=$val
	fi

	echo "========================== Run with buffer pool size= $val ... ============="
	#run top to track CPU util
	top -b > tem &
	#run iostat to track device util
	iostat -mx 1 $TRACK_DEV > tem2 &
	${MONGO_HOME}/mongod --wiredTigerCacheSizeGB=$val -f ${MONGO_CONFIG_FILE} ${MONGO_OPTION_JOURNAL} &
	${BENCHMARK_HOME}/run.sh
	${BENCHMARK_HOME}/stop_server.sh

	kill -9 $(ps -opid= -C top)
	kill -9 $(ps -opid= -C iostat)

	awk -v date="$(date --rfc-3339=seconds)" '/RunTime/ {printf("%s\t%s\t%s\t%s\t%s\t%s",date ,"'"$val"'","'"${YCSB_WORKLOAD}"'","'"${YCSB_REC_COUNT}"'","'"${THREADS}"'",$3)}' \
		${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> $TOP_FILE
	awk '/Throughput/ {printf("\t%s",$3)}' ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.txt  >> $TOP_FILE
	#compute avg value from tem file of top command
	awk '/%Cpu/ {count+=1; us_sum+=$2; sy_sum+=$4; id_sum+=$8; wa_sum+=$10} END \
	  	{printf("\tavg_us %s\tavg_sy %s\tavg_id %s\tavg_wa %s", us_sum/count, sy_sum/count, id_sum/count, wa_sum/count)}' tem >> $TOP_FILE
	rm tem
	#compute avg value from tem2 file of iostat command
	grep $TRACK_DEV tem2 | awk '{count+=1; util_sum+=$14} END {printf("\tavg_dev_util %s\n", util_sum/count)}' tem2 >> $TOP_FILE
#	rm tem2
	rm tem2

	prev=$val
done
echo "=============================  Finish.====================="
