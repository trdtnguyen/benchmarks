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

echo "(1) PARAM is $PARAM"

if [ $mode -eq 1 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: original"
	printf "\n===========================\n"
elif [ $mode -eq 2 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: DWB"
	printf "\n===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE"
elif [ $mode -eq 3 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: WAL"
	printf "\n===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_log_group_home_dir=$PMEM_HOME_DIR"
elif [ $mode -eq 4 ]; then
PMEM_BUF_SIZE=$2
PMEM_BUF_N_BUCKETS=$3
PMEM_BUF_BUCKET_SIZE=$4
PMEM_FLUSH_THRESHOLD=$5
	printf "\n===========================\n"
	printf "Mode $mode: PMEM_BUF with EVEN Parition\n"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "\n===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD"
elif [ $mode -eq 5 ]; then
	printf "\n===========================\n"
	echo "Mode $mode: PMEM_BUF with SINGLE Parition"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "\n===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
else
	printf "\n===========================\n"
	echo "Mode $mode: PMEM_BUF with LESS Parition"
	printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
	printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
	printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
	printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
	printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
	printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
	printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
	printf "\n===========================\n"
	PARAM="$PARAM --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS"
fi

echo "Last PARAM is $PARAM"

exit

if [ $IS_PMEM_APP -eq 1 ]; then
PMEM_BUF_SIZE=$2
PMEM_BUF_N_BUCKETS=$3
PMEM_BUF_BUCKET_SIZE=$4
PMEM_FLUSH_THRESHOLD=$5
printf "\n===========================\n"
printf "Innodb Buffer size:\t%s MB\n" "${BPSIZE}"
printf "PMEM buf size:\t%s MB\n" "${PMEM_BUF_SIZE}"
printf "n_buckets:\t%s \n" "${PMEM_BUF_N_BUCKETS}"
printf "bucket_size:\t%s \n" "${PMEM_BUF_BUCKET_SIZE}"
printf "flush_threshold:\t%s \n" "${PMEM_FLUSH_THRESHOLD}"
if [ $IS_PMEM_PARTITION -eq 1 ]; then
printf "pmem_n_space_bits:\t%s \n" "${PMEM_N_SPACE_BITS}"
printf "pmem_page_per_bucket_bits:\t%s \n" "${PMEM_PAGE_PER_BUCKET_BITS}"
fi
printf "\n===========================\n"

if [ $IS_PMEM_PARTITION -eq 1 ]; then
#Note that PMEM_N_SPACE_BITS and PMEM_PAGE_PER_BUCKET_BITS values are set in const.sh rather than by parameters
$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}M --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD --innodb_pmem_n_space_bits=$PMEM_N_SPACE_BITS --innodb_pmem_page_per_bucket_bits=$PMEM_PAGE_PER_BUCKET_BITS
else # EVEN partition
$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}M --innodb_pmem_home_dir=$PMEM_HOME_DIR --innodb_pmem_pool_size=$PMEM_POOL_SIZE --innodb_pmem_buf_size=$PMEM_BUF_SIZE --innodb_pmem_buf_n_buckets=$PMEM_BUF_N_BUCKETS --innodb_pmem_buf_bucket_size=$PMEM_BUF_BUCKET_SIZE --innodb_pmem_buf_flush_pct=1 --innodb_pmem_n_flush_threads=$PMEM_N_FLUSH_THREADS --innodb_pmem_flush_threshold=$PMEM_FLUSH_THRESHOLD
fi

else #The others not PMEMOBJ_BUF
printf "\n===========================\n"
printf "Innodb Buffer size:\t%s MB\n" "${BP_SIZE}"
printf "\n===========================\n"
$MYSQL_BIN/mysqld --defaults-file=$CONFIG -u $USER --innodb_buffer_pool_size=${BPSIZE}M
fi
