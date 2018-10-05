#!/bin/bash

#usage: ./start_server [buffer_pool_size]
#buffer_pool_size: default/ommited 1

source const.sh

BPSIZE=5

if [ -n $1 ]; then
	BPSIZE=$1
fi


#if [ $IS_USE_DBW -eq 1 ]; then
#echo "Start mysqld with buffer pool size is $BPSIZE GB, DBW is enable..."
#$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}G 
#$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}G &
#$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}G --debug
#else
#echo "Start mysqld with buffer pool size is $BPSIZE GB, DBW is disable..."
#$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}G  --skip-innodb_doublewrite
#fi

#$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}G

PARAM="--defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}M"

if [ $mode -eq 1 ]; then
	printf "===========================\n"
	echo "Mode $mode: $METHOD"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "===========================\n"
elif [ $mode -eq 2 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: $METHOD"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE"
elif [ $mode -eq 3 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: $METHOD"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "WAL file location:\t%s \n" "${PMEM_HOME_DIR}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_log_group_home_dir=$PMEM_HOME_DIR"
elif [ $mode -eq 4 ]; then
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	printf "\n===========================\n"
	printf "Mode $mode: $METHOD\n"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD"
elif [ $mode -eq 7 ]; then
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	printf "\n===========================\n"
	printf "Mode $mode: $METHOD\n"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD"
elif [ $mode -eq 5 ]; then
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	PMEM_PAGE_PER_BUCKET_BITS=31
	printf "\n===========================\n"
	echo "Mode $mode: $METHOD"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
elif [ $mode -eq 6 ]; then
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	printf "\n===========================\n"
	echo "Mode $mode: $METHOD"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
else
	PMEM_BUF_SIZE=$2
	PMEM_BUF_N_BUCKETS=$3
	PMEM_BUF_BUCKET_SIZE=$4
	PMEM_FLUSH_THRESHOLD=$5
	printf "\n===========================\n"
	echo "Mode $mode: $METHOD (WAL + LESS)"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "WAL file location:\t%s \n" "${PMEM_HOME_DIR}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS --innodb_log_group_home_dir=$PMEM_HOME_DIR"
fi

echo "Last PARAM is $PARAM"

$MYSQL_BIN/mysqld $PARAM

