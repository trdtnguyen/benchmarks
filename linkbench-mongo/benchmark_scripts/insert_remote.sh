#! /bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh


${YCSB_HOME}/bin/ycsb load ${YCSB_MONGODB_ASYNC_RUN} -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p recordcount=${YCSB_REC_COUNT} -p operationcount=${YCSB_OP_COUNT}  -p mongodb.url=mongodb://${YCSB_HOST} -p mongodb.batchsize=100 -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.load
#${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p mongodb.url=mongodb://${HOST}/ycsb?${YCSB_MONGODBURL_LOAD_OPTION} -p mongodb.batchsize=${YCSB_MONGODB_BATCHSIZE} -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.load
#${YCSB_HOME}/bin/ycsb load mongodb -s -P ${YCSB_HOME}/workloads/${YCSB_WORKLOAD} -p mongodb.url=mongodb://${HOST}/ycsb?${YCSB_MONGODBURL_LOAD_OPTION} -p mongodb.batchsize=${YCSB_MONGODB_BATCHSIZE} -threads ${THREADS}  > ${BENCHMARK_HOME}/${WORKLOAD_DIR}/${YCSB_WORKLOAD}.load

