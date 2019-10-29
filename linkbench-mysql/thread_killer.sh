# !/bin/bash
source const.sh

sleep $THREAD_KILLER_SLEEP
echo "kill the benchmark process and mysqld process ..."
#sudo kill -9 $(ps -opid= -C linkbench)
sudo kill -9 $(ps -opid= -C java)
sudo kill -9 $(ps -opid= -C mysqld)

#$BENCHMARK_HOME/recovery_trace.sh
