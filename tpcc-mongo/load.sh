# !/bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outdir=$1
cache_size=$2
outfile=$outdir/load.txt

echo "It will reset your data..."
rm -rf ${MONGO_DATA_PATH} 
mkdir -p ${MONGO_DATA_PATH}
echo "Run blktrace"
#${BENCHMARK_HOME}/run_blktrace.sh  /dev/${DEVICE} ${BLKTRACE_OUT} &

${BENCHMARK_HOME}/start_server.sh $cache_size

cd ${TPCC_HOME}
python ${TPCC_HOME}/tpcc.py --no-execute --config=${TPCC_CONFIG_FILE} --warehouses=${TPCC_WAREHOUSE} --clients=${TPCC_LOAD_THREADS} mongodb 2>&1 | tee ${outfile}
cd ${BENCHMARK_HOME}

#echo "YCSB finished. End blktrace process."
pid=$(ps -opid= -C blktrace)
sudo kill -15  $pid
#${BENCHMARK_HOME}/run.sh

${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.CUSTOMER.stats({indexDetails : true}))' > ${outdir}/${TPCC_CUSTOMER_LOAD}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.DISTRICT.stats({indexDetails : true}))' > ${outdir}/${TPCC_DISTRICT_LOAD}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.ITEM.stats({indexDetails : true}))' > ${outdir}/${TPCC_ITEM_LOAD}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.NEW_ORDER.stats({indexDetails : true}))' > ${outdir}/${TPCC_NEW_ORDER_LOAD}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.STOCK.stats({indexDetails : true}))' > ${outdir}/${TPCC_STOCK_LOAD}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.WAREHOUSE.stats({indexDetails : true}))' > ${outdir}/${TPCC_WAREHOUSE_LOAD}

if [ $IS_BUILD_GRAPH -eq 1 ]
then
	echo "Build blkparse plot..."
	${BENCHMARK_HOME}/build_graph.sh ${BLKTRACE_OUT} ${PLOT_OUT_INS}
fi
${BENCHMARK_HOME}/stop_server.sh
