# !/bin/bash
source const.sh

echo "kill the benchmark process and mysqld process in $THREAD_KILLER_SLEEP seconds ..."
sleep $THREAD_KILLER_SLEEP
sudo kill -9 $(ps -opid= -C tpcc_start)
sudo kill -9 $(ps -opid= -C mysqld)

#$BENCHMARK_HOME/recovery_trace.sh
