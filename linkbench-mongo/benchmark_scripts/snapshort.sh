#! /bin/bash                                                                                                                                                                           

source const.sh


outdir=$1
outfile=$2
infile=${outdir}/run.txt


#Compute average information about us,sy, wa, disk util, output fiel is $LINUX_STAT_FILE
${BENCHMARK_HOME}/build_graph_linux_stat.sh $IOSTAT_FILE $TOP_FILE $outfile

echo "Get benchmark result"

${MONGO_HOME}/mongo --host=${HOST} --quiet $LB_DB_NAME --eval 'printjson(db.node.stats({indexDetails : true}))' > ${outdir}/${LB_NODE_RUN} 
${MONGO_HOME}/mongo --host=${HOST} --quiet  $LB_DB_NAME --eval 'printjson(db.link.stats({indexDetails : true}))' > ${outdir}/${LB_LINK_RUN} 
${MONGO_HOME}/mongo --host=${HOST} --quiet  $LB_DB_NAME --eval 'printjson(db.count.stats({indexDetails : true}))' > ${outdir}/${LB_COUNT_RUN} 

${MONGO_HOME}/mongo --host=${HOST} --quiet $LB_DB_NAME --eval 'printjson(db.serverStatus())' > ${outdir}/lb_serverStatus.txt

#format========================
# date method cache_size node_coll_read node_idx1_read
# link_coll_read link_idx1_read link_idx2_read link_idx3_read
# count_coll_read count_idx1_read count_idx2_read
# 

#GC information, only available with Samsung NVME Multi-stream SSD e.g. PM953
printf "after disk_util-noswa-WAFInfo [ " >> $outfile
df | grep ${NVME_DEV} | awk '{printf("%s",$5)}' >> $outfile
${NVME_TOOLS}/nvme_read_log ${NVME_DEV} 81 | awk -v FS="[():]" '/nosa/ {printf("%s ", $2)}' >> $outfile
${NVME_TOOLS}/nvme_smart ${NVME_DEV} | awk -v FS="[():]" '/data_units_written/ {printf("%s ",$3) }' >> $outfile
printf " ] " >> $outfile

#number of request complete
awk '/COMPLETED/ {printf("num_req_completed %s ",$8)}' ${infile} >> $outfile

#runtime, ops/s; latencies require run ./build_graph_ops in advanced 
echo "Compute ops"
${BENCHMARK_HOME}/build_graph_ops.sh $infile ${outdir}/ops  > ops_tem1
grep OPS ops_tem1 | awk '{printf(" %s ", $0)}' >> $outfile
printf "99th_latencies ["  >> $outfile
awk -v FS="[= ]" '{if(NR>1) printf(" %s ",$5)}' ops_tem1 >> $outfile
printf " ] " >> $outfile
rm ops_tem1

#number of checkpoint generate
printf " num_ckpts " >> $outfile 
grep "btree checkpoint generation" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2)}' >> $outfile
#echo "Print output results"
#awk '{sum1+=$2; count+=1} END {printf(" runtime = %s (s) \t avg OPS/s = %s \t \n", count*60, ((sum1*1.0)/count))}' $LB_IOPS_TEM2_OUT >> $outfile



#amount of coll, idx data written
printf "data_reads [ " >> $outfile
grep "bytes read into cache" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
grep "bytes read into cache" ${outdir}/${LB_LINK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
grep "bytes read into cache" ${outdir}/${LB_COUNT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
printf " ] " >> $outfile

printf "data_written [ " >> $outfile
grep "bytes written from cache" ${outdir}/${LB_NODE_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
grep "bytes written from cache" ${outdir}/${LB_LINK_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
grep "bytes written from cache" ${outdir}/${LB_COUNT_RUN} | awk -F"[:,]" '{printf(" %s \t",$2/(1024*1024))}' >> $outfile
printf " ] " >> $outfile

#amount of log data written
cat ${outdir}/lb_serverStatus.txt | grep "log bytes written" | awk -F"[:,]" '{printf("log_written: %s \t",$2/(1024*1024))}' >> $outfile


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

