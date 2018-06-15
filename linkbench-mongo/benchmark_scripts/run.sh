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
#reset and open streams
${BENCHMARK_HOME}/reset_and_open_stream.sh $NUM_OPEN_STREAM 


if [ $IS_TRACK_LINUX_STAT -eq 1 ]; then
echo "Run linux system stat tools..."
#vmstat 1 > vmstat_track.txt &
#run top to track CPU util
top -d 1 -b > $TOP_FILE &
#run iostat to track device util
iostat -mx 1 $TRACK_DEV > $IOSTAT_FILE &
#run watch to track disk util
fi
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



echo "Run Linkbench ..."
#choose run normally (sync) or async
${LINKBENCH_HOME}/bin/linkbench -c  ${LINKBENCH_CONFIG_FILE} -r  -csvstats ${LB_CSVSTATS_RUN_FILE} -csvstream ${LB_CSVSTREAM_RUN_FILE} -D maxid1=${LB_NUM_REC} -D requesters=${LB_RUN_THREADS} -D requests=${LB_NUM_REQUESTS} -D requestrate=${LB_REQUEST_RATE} -D maxtime=${LB_MAX_TIME} -D debuglevel=${LB_DEBUG_LEVEL} 2>&1 | tee ${outfile}


echo "Linkbench finished. End background processes"
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
#kill -9 $(ps -opid= -C trace_disk_util)
#Compute average information about us,sy, wa, disk util, output fiel is $LINUX_STAT_FILE
${BENCHMARK_HOME}/build_graph_linux_stat.sh $IOSTAT_FILE $TOP_FILE $linuxstat
fi
#echo "End iostat tracking"
#pid2=$(ps -opid= -C iostat)
#sudo kill -9 $pid2

echo "Get benchmark result"

${MONGO_HOME}/mongo --host=${HOST} --quiet $LB_DB_NAME --eval 'printjson(db.node.stats({indexDetails : true}))' > ${outdir}/${LB_NODE_RUN} 
${MONGO_HOME}/mongo --host=${HOST} --quiet  $LB_DB_NAME --eval 'printjson(db.link.stats({indexDetails : true}))' > ${outdir}/${LB_LINK_RUN} 
${MONGO_HOME}/mongo --host=${HOST} --quiet  $LB_DB_NAME --eval 'printjson(db.count.stats({indexDetails : true}))' > ${outdir}/${LB_COUNT_RUN} 

${MONGO_HOME}/mongo --host=${HOST} --quiet $LB_DB_NAME --eval 'printjson(db.serverStatus())' > ${outdir}/${LB_SERVER_STATUS}
#track nosa plot
${BENCHMARK_HOME}/build_graph_nosa.sh ${nosafile} ${outdir}/nosa

#format========================
# date method cache_size node_coll_read node_idx1_read
# link_coll_read link_idx1_read link_idx2_read link_idx3_read
# count_coll_read count_idx1_read count_idx2_read
# 

#GC information, only available with Samsung NVME Multi-stream SSD e.g. PM953
#${NVME_TOOLS}/my_report.sh ${NVME_DEV}
grep "maximum bytes configured" ${outdir}/$LB_SERVER_STATUS | awk -F"[:,]" '{printf(" WT_cache %s ",$2*1.0/(1024^3))}'  >> ${OVERALL_FILE}

printf "after disk_util-noswa-WAFInfo [ " >> ${OVERALL_FILE}
df | grep ${NVME_DEV} | awk '{printf("%s",$5)}' >> ${OVERALL_FILE}
${NVME_TOOLS}/nvme_read_log ${NVME_DEV} 81 | awk -v FS="[():]" '/nosa/ {printf("%s ", $2)}' >> ${OVERALL_FILE}
${NVME_TOOLS}/nvme_smart ${NVME_DEV} | awk -v FS="[():]" '/data_units_written/ {printf("%s ",$3) }' >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}

#number of request complete
awk '/COMPLETED/ {printf("num_req_completed %s ",$8)}' ${outfile} >> ${OVERALL_FILE}

#runtime, ops/s; latencies require run ./build_graph_ops in advanced 
echo "Compute ops"
${BENCHMARK_HOME}/build_graph_ops.sh $outfile ${outdir}/$LB_IOPS_OUT > $ops_tem
grep OPS $ops_tem | awk '{printf(" %s ", $0)}' >> ${OVERALL_FILE}
grep "Total" $ops_tem | awk '{printf(" %s ", $0)}' >> ${OVERALL_FILE}

printf "99th_latencies ["  >> ${OVERALL_FILE}
awk -v FS="[= ]" '{if(NR>1) printf(" %s ",$5)}' $ops_tem >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}
rm $ops_tem

#number of checkpoint generate
printf " num_ckpts " >> ${OVERALL_FILE} 
grep "btree checkpoint generation" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2)}' >> ${OVERALL_FILE}
#echo "Print output results"
#awk '{sum1+=$2; count+=1} END {printf(" runtime = %s (s) \t avg OPS/s = %s \t \n", count*60, ((sum1*1.0)/count))}' $LB_IOPS_TEM2_OUT >> ${OVERALL_FILE}



#amount of coll, idx data written
printf "data_reads [ " >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${LB_LINK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${LB_COUNT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}

printf "data_written [ " >> ${OVERALL_FILE}
grep "bytes written from cache" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes written from cache" ${outdir}/${LB_LINK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes written from cache" ${outdir}/${LB_COUNT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}

#amount of log data written
cat ${outdir}/${LB_SERVER_STATUS} | grep "log bytes written" | awk -F"[:,]" '{printf("log_written: %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}


if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Build blkparse plot..."
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT2} ${PLOT_OUT2}
	if [ -n "${DEVICE3}" ]; then
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT3} ${PLOT_OUT3}
	fi
	if [ -n "${DEVICE4}" ]; then
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT4} ${PLOT_OUT4}
	fi
#call this last for using build_graph_hotpages wtemp 
	#${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${PLOT_OUT}
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${outdir}/${PLOT_OUT}
#build ycsb iops graph
fi

#save the debug file for Multi-streamed based approaches 
cp my_mssd_track8.txt ${outdir}/

echo "Finished."

