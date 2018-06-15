#! /bin/bash                                                                                                                                                                           

source const.sh


outdir=$1
cache_size=$2
outfile=${outdir}/run.txt
ops_tem=ops_tem
nosafile=${outdir}/$NOSA_NAME
streamfile=${outdir}/$STREAM_NAME
linuxstat=${outdir}/$LINUX_STAT_FILE



echo "Get benchmark result"

${BENCHMARK_HOME}/get_coll_stats.sh ${outdir}

#track nosa plot
${BENCHMARK_HOME}/build_graph_nosa.sh ${nosafile} ${outdir}/nosa

#format========================
# date method cache_size node_coll_read node_idx1_read
# link_coll_read link_idx1_read link_idx2_read link_idx3_read
# count_coll_read count_idx1_read count_idx2_read
# 

#GC information, only available with Samsung NVME Multi-stream SSD e.g. PM953
#${NVME_TOOLS}/my_report.sh ${NVME_DEV}
grep "maximum bytes configured" ${outdir}/$TPCC_SERVER_STATUS_RUN | awk -F"[:,]" '{printf(" WT_cache %s ",$2*1.0/(1024^3))}'  >> ${OVERALL_FILE}

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
grep "btree checkpoint generation" ${outdir}/${TPCC_CUSTOMER_RUN} | awk -F"[:,]" '{printf(" %s \t",$2)}' >> ${OVERALL_FILE}
#echo "Print output results"
#awk '{sum1+=$2; count+=1} END {printf(" runtime = %s (s) \t avg OPS/s = %s \t \n", count*60, ((sum1*1.0)/count))}' $LB_IOPS_TEM2_OUT >> ${OVERALL_FILE}



#amount of coll, idx data written
printf "data_reads [ " >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_CUSTOMER_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_DISTRICT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_ITEM_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_NEW_ORDER_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_STOCK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes read into cache" ${outdir}/${TPCC_WAREHOUSE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
printf " ] " >> ${OVERALL_FILE}

printf "data_written [ " >> ${OVERALL_FILE}

grep "bytes write from cache" ${outdir}/${TPCC_CUSTOMER_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes write from cache" ${outdir}/${TPCC_DISTRICT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes write from cache" ${outdir}/${TPCC_ITEM_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes write from cache" ${outdir}/${TPCC_NEW_ORDER_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes write from cache" ${outdir}/${TPCC_STOCK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}
grep "bytes write from cache" ${outdir}/${TPCC_WAREHOUSE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}

printf " ] " >> ${OVERALL_FILE}


#amount of data written from blktrace
sudo grep 'W\|WS\|WSM\|WM' ${BLKTRACE_OUT} | awk '/C/ { sum+=$10 } END { printf("\tw_in_%s: %d MB","'"${DEVICE}"'", (sum*512)/(1024*1024)) }' >> ${OVERALL_FILE}

#amount of log data written
cat ${outdir}/${TPCC_SERVER_STATUS_RUN} | grep "log bytes written" | awk -F"[:,]" '{printf("log_written: %s \t",$2/(1024*1024))}' >> ${OVERALL_FILE}


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

echo "Finished."

