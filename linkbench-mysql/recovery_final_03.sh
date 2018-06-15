# !/bin/bash
source const.sh

#require: the recovery trace file that capture the output of recovery text lines from innodb

#./recovery_final_03.sh $RECV_FILE

infile=$RECV_FILE
str1="past the checkpoint"
str2="was not shutdown"
str3="Starting an apply"
str4="Apply batch completed"
str5="ready for connections"

#start time: hour, minute, second
start_rec=$(cat $infile | grep "$str1" | awk -v FS="[T: Z]" '{printf("%d", $2*3600+$3*60+$4)}')

#log scan
end_log=$(cat $infile | grep "$str2" | awk -v FS="[T: Z]" '{printf("%d", $2*3600+$3*60+$4)}')

#REDO
cat $infile | grep "$str3" | awk -v FS="[T: Z]" '{printf("%d\n", $2*3600+$3*60+$4)}' > redo_start.tem
cat $infile | grep "$str4" | awk -v FS="[T: Z]" '{printf("%d\n", $2*3600+$3*60+$4)}' > redo_end.tem
paste redo_start.tem redo_end.tem > redo_combined.tem

#end time: hour, minute, second
end_rec=$(cat $infile | grep "$str5" | awk -v FS="[T: Z]" '{printf("%d", $2*3600+$3*60+$4)}')


rec_time=$(( $end_rec-$start_rec ))
redo_time=$(awk '{r=r+($2-$1)} END {printf("%d",r)}' redo_combined.tem)
#log_scan_time=$(( $end_log-$start_rec ))
log_scan_time=$(( $rec_time-$redo_time ))

printf "===================================\n"
printf "(Scan logs time, REDO time, recovery time) second(s) = ( $log_scan_time  $redo_time  $rec_time )\n"
printf "===================================\n"
