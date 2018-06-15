#!/bin/bash
source const.sh

query1="UPDATE performance_schema.setup_consumers SET enabled = 'YES' WHERE name like 'events_waits%';"

query2=" SELECT EVENT_NAME, COUNT_STAR, SUM_TIMER_WAIT/1000000000 SUM_TIMER_WAIT_MS 
		FROM performance_schema.events_waits_summary_global_by_event_name
		WHERE SUM_TIMER_WAIT > 0 AND EVENT_NAME LIKE 'wait/synch/mutex/innodb/%'
		ORDER BY SUM_TIMER_WAIT_MS DESC;
		"

$MYSQL -u $USER -e "$query1"
$MYSQL -u $USER -e "$query2"
