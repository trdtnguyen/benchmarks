#! /bin/bash                                                                                                                                                                           

source const.sh

if [ ! -d ${BENCHMARK_HOME}/${BLK_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${BLK_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${PLOT_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${PLOT_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${BTT_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${BTT_DIR}
fi

if [ ! -d ${BENCHMARK_HOME}/${WORKLOAD_DIR} ]
then
	mkdir ${BENCHMARK_HOME}/${WORKLOAD_DIR}
fi

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=${outdir}/run.txt
ops_tem=ops_tem
nosafile=${outdir}/$NOSA_NAME
streamfile=${outdir}/$STREAM_NAME
linuxstat=${outdir}/$LINUX_STAT_FILE

if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Run blktrace"
	${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE} ${BLKTRACE_OUT} &
	${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE2} ${BLKTRACE_OUT2} &
	if [ -n "${DEVICE3}"  ]; then
		${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE3} ${BLKTRACE_OUT3} &
	fi
	if [ -n "${DEVICE4}"  ]; then
		${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE4} ${BLKTRACE_OUT4} &
	fi
fi


#start report file
date="$(date --rfc-3339=seconds)"
printf "\n$date $METHOD $cache_size " >> ${OVERALL_FILE}

#GC information, only available with Samsung NVME Multi-stream SSD e.g. PM953
#Call the full report

printf " ] " >> ${OVERALL_FILE}
##############      BEGIN RUN THE BENCHMARK HERE ##################
echo "Run SB ..."
#choose run normally (sync) or async
#current implementation of pytpcc has an error if you run the tpcc.py from another location that is not hte its installed directory
${BENCHMARK_HOME}/run.simple.bash ${SB_CONFIG_FILE} 2 ${outdir}
echo "See the output result in ${out_file}"

#############      END THE BENCHMARK HERE   #########################

echo "SB finished. End background processes"
pid=$(ps -opid= -C blktrace)
sudo kill -15 $pid

${BENCHMARK_HOME}/post_processing.sh $1 $2


echo "Finished."

