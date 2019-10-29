#!/bin/bash
source const.sh

#Periodic cally get info from mysql performance_schema
#psi_collector = Performance Schema Information Collector

# Input: The output performance_schema in the run.sh

infile=$OUT_DIR/${date}_${METHOD}_${LB_DB_SIZE}_BP${BUFFER_POOL}_T${CONN}.perf

if [ -n $1 ]; then
infile=$1
fi

#This is the global file, contains information of top latency events
# innodb_data_file fil_space_latch buf_pool_mutex innodb_log_file
outfile=$perffile

## Processing to compute our desired information
# (1) Print the info about the method and benchmark config
printf "$infile " >> $outfile

### (2) Process information, collection only the SUM_TIMER_WAIT_US

#File Sytem IO
cat $infile | grep innodb_data_file | awk '{printf(" %s ",$3)}' >> $outfile
cat $infile | grep innodb_log_file | awk '{printf(" %s ",$3)}' >> $outfile
cat $infile | grep fil_system_mutex | awk '{printf(" %s ",$3)}' >> $outfile
cat $infile | grep fil_space_latch | awk '{printf(" %s ",$3)}' >> $outfile

#Buffer Pool
cat $infile | grep buf_pool_mutex | awk '{printf(" %s ",$3)}' >> $outfile
cat $infile | grep flush_list_mutex | awk '{printf(" %s ",$3)}' >> $outfile
cat $infile | grep buf_dblwr_mutex | awk '{printf(" %s ",$3)}' >> $outfile

#Log, TRX 
cat $infile | grep log_sys_mutex | awk '{printf(" %s ",$3)}' >> $outfile 
cat $infile | grep log_sys_write_mutex | awk '{printf(" %s ",$3)}' >> $outfile 
cat $infile | grep log_flush_order_mutex | awk '{printf(" %s ",$3)}' >> $outfile 
cat $infile | grep trx_mutex | awk '{printf(" %s ",$3)}' >> $outfile 
cat $infile | grep trx_sys_mutex | awk '{printf(" %s ",$3)}' >> $outfile 
cat $infile | grep trx_undo_mutex | awk '{printf(" %s ",$3)}' >> $outfile 

#Lock
cat $infile | grep lock_mutex | awk '{printf(" %s ",$3)}' >> $outfile 

#ibuf
cat $infile | grep ibuf_bitmap_mutex | awk '{printf(" %s ",$3)}' >> $outfile 



############
printf "\n" >> $outfile
echo "collect performance schema info done!"


