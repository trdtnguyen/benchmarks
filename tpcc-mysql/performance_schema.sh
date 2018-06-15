#!/bin/bash
source const.sh

#Periodic cally get info from mysql performance_schema


#interval in second
INTERVAL=10
count=0

#This query enable only important events
#query1=
#	"UPDATE performance_schema.setup_instruments 
#	SET ENABLED = 'YES', TIMED = 'YES' 
#	WHERE ( 
#	name like 'wait/synch/mutex/innodb/buf_pool_mutex'
#	);
#	"
query1="UPDATE performance_schema.setup_instruments
	SET ENABLED = 'YES', TIMED = 'YES'
	WHERE (
	name like 'wait/synch/mutex/innodb/buf_pool_mutex' OR
	name like 'wait/synch/mutex/innodb/buf_pool_zip_mutex' OR
	name like 'wait/synch/mutex/innodb/cache_last_read_mutex' OR
	name like 'wait/synch/mutex/innodb/flush_list_mutex' OR
	name like 'wait/synch/mutex/innodb/hash_table_mutex' OR
	name like 'wait/synch/mutex/innodb/page_cleaner_mutex' OR

	name like 'wait/synch/mutex/innodb/log_sys_mutex' OR
	name like 'wait/synch/mutex/innodb/log_sys_write_mutex' OR
	name like 'wait/synch/mutex/innodb/log_flush_order_mutex' OR
	name like 'wait/synch/mutex/innodb/log_cmdq_mutex' OR
	
	name like 'wait/synch/mutex/innodb/trx_mutex' OR
	name like 'wait/synch/mutex/innodb/trx_undo_mutex' OR
	name like 'wait/synch/mutex/innodb/trx_sys_mutex' OR
	
	name like 'wait/synch/mutex/innodb/buf_dblwr_mutex' OR
	
	name like 'wait/synch/mutex/innodb/lock_mutex' OR
	name like 'wait/synch/mutex/innodb/lock_wait_mutex' OR
	name like 'wait/synch/mutex/innodb/rw_lock_mutex' OR
	name like 'wait/synch/mutex/innodb/rw_lock_list_mutex' OR
	
	name like 'wait/synch/mutex/innodb/recv_sys_mutex' OR
	name like 'wait/synch/mutex/innodb/recv_writer_mutex' OR
	
	name like 'wait/synch/mutex/innodb/ibuf_mutex' OR
	name like 'wait/synch/mutex/innodb/ibuf_bitmap_mutex' OR
	
	name like 'wait/synch/mutex/innodb/thread_mutex' OR
	
	name like 'wait/synch/mutex/innodb/fil_system_mutex' OR
	
	name like 'wait/synch/sxlock/innodb/btr_search_latch' OR
	name like 'wait/synch/sxlock/innodb/fil_space_latch' OR
	name like 'wait/synch/sxlock/innodb/checkpoint_mutex' OR
	
	name like 'wait/synch/cond/innodb/commit_cond'
	);
	"
#Filter by InnoDB mutex overhead
#query2=" SELECT EVENT_NAME, 
#			COUNT_STAR,
#		   	SUM_TIMER_WAIT/1000000 SUM_TIMER_WAIT_US,
#			AVG_TIMER_WAIT/1000000 AVG_TIMER_WAIT_US,
#			MAX_TIMER_WAIT/1000000 MAX_TIMER_WAIT_US
#		FROM performance_schema.events_waits_summary_global_by_event_name
#		WHERE SUM_TIMER_WAIT > 0 AND EVENT_NAME LIKE 'wait/synch/mutex/innodb/%'
#		ORDER BY SUM_TIMER_WAIT_US DESC;
#		"
query2=" SELECT EVENT_NAME, 
			COUNT_STAR,
		   	SUM_TIMER_WAIT/1000000 SUM_TIMER_WAIT_US,
			AVG_TIMER_WAIT/1000000 AVG_TIMER_WAIT_US,
			MAX_TIMER_WAIT/1000000 MAX_TIMER_WAIT_US
		FROM performance_schema.events_waits_summary_global_by_event_name
		WHERE SUM_TIMER_WAIT > 0 
		ORDER BY SUM_TIMER_WAIT_US DESC;
		"


$MYSQL -u $USER -e "$query1"

date="$(date --rfc-3339=seconds)"

echo "Report date:$date" > $OUT_DIR/$PERF_SCHEMA_FILE
printf "=====================\n" >> $OUT_DIR/$PERF_SCHEMA_FILE

####### Begin of the loop
while [ $count -lt $RUNTIME ]; do
	$MYSQL -u $USER -e "$query2" >> $OUT_DIR/$PERF_SCHEMA_FILE
	printf "====\n" >> $OUT_DIR/$PERF_SCHEMA_FILE

	sleep $INTERVAL
	count=$[$count+$INTERVAL]
done
####### End of the loop

######### PERFORMANCE SCHEMA ##############
#$MYSQL -u $USER -e "$query1"
#####################################

