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


if [ $IS_TRACK_LINUX_STAT -eq 1 ]; then
echo "Run linux system stat tools..."
#vmstat 1 > vmstat_track.txt &
#run top to track CPU util
top -d 1 -b > $TOP_FILE &
#run iostat to track device util
iostat -mx 1 $TRACK_DEV > $IOSTAT_FILE &
#run watch to track disk util
fi #if [ $IS_TRACK_LINUX_STAT -eq 1 ]; then

#when interup autorun.sh by Ctl+C, trace_disk_util.sh is still running.
#Kill it before starting the new one 
kill -9 $(ps -opid= -C trace_disk_util)
#rm disk_util.txt
${BENCHMARK_HOME}/trace_disk_util.sh &

if [ $IS_NVME_SSD -eq 1 ]; then
#trace nosa info
kill -9 $(ps -opid= -C trace_nvme_nosa)
rm $nosafile 
${BENCHMARK_HOME}/trace_nvme_nosa.sh  ${nosafile}  ${NVME_DEV} &

#trace multi stream write
kill -9 $(ps -opid= -C trace_stream_write)
rm $streamfile
${BENCHMARK_HOME}/trace_stream_write.sh  ${streamfile} &
fi
#start report file
date="$(date --rfc-3339=seconds)"
printf "\n$date $METHOD $cache_size " >> ${OVERALL_FILE}

#GC information, only available with Samsung NVME Multi-stream SSD e.g. PM953
#Call the full report
#${NVME_TOOLS}/my_report.sh ${NVME_DEV}
printf "before disk_util-noswa-WAFInfo [ " >> ${OVERALL_FILE}
df | grep ${NVME_DEV} | awk '{printf("%s ",$5)}' >> ${OVERALL_FILE}
${NVME_TOOLS}/nvme_read_log ${NVME_DEV} 81 | awk -v FS="[():]" '/nosa/ {printf("%s ", $2)}' >> ${OVERALL_FILE}
${NVME_TOOLS}/nvme_smart ${NVME_DEV} | awk -v FS="[():]" '/data_units_written/ {printf("%s ",$3) }' >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}


##############      BEGIN RUN THE BENCHMARK HERE ##################
echo "Run TPCC ..."
#choose run normally (sync) or async
#current implementation of pytpcc has an error if you run the tpcc.py from another location that is not hte its installed directory
cd ${TPCC_HOME}
python ${TPCC_HOME}/tpcc.py --config=${TPCC_CONFIG_FILE} --warehouses=${TPCC_WAREHOUSE} --clients=${TPCC_RUN_THREADS} --no-load --duration=${TPCC_DURATION}  mongodb 2>&1 | tee ${outfile} 
echo "See the output result in ${out_file}"
cd ${BENCHMARK_HOME}

#############      END THE BENCHMARK HERE   #########################

echo "TPCC finished. End background processes"
pid=$(ps -opid= -C blktrace)
sudo kill -15 $pid

kill -9 $(ps -opid= -C trace_disk_util)

if [ $IS_NVME_SSD -eq 1 ]; then
kill -9 $(ps -opid= -C trace_nvme_nosa)
kill -9 $(ps -opid= -C trace_stream_write)
fi

if [ $IS_TRACK_LINUX_STAT -eq 1 ]; then
kill -9 $(ps -opid= -C vmstat)
kill -9 $(ps -opid= -C top)
kill -9 $(ps -opid= -C iostat)
fi

${BENCHMARK_HOME}/post_processing.sh $1 $2


echo "Finished."

