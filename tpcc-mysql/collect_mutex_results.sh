#!/bin/bash
#usage: ./collec_mutex_results.sh

outfile_ori=mutex_ori.txt
outfile=mutex.txt
runtime=300 #runtime in second

rm $outfile_ori
rm $outfile

echo "collect result from output/*.mutex files, % time wait to doing sth over total run time $runtime seconds ..."
#########################################
#for MySQL 5.7
##########################################
for file in output/*.mutex; do
	echo "$(basename "$file") " >> $outfile_ori
	cat $file | grep "log_file" >> $outfile_ori
	cat $file | grep "log_sys_mutex" >> $outfile_ori
	cat $file | grep "log_sys_write_mutex" >> $outfile_ori
	cat $file | grep "log_flush_order_mutex" >> $outfile_ori 
	printf "\n" >> $outfile_ori
done

for file in output/*.mutex; do
	printf "$(basename "$file") " >> $outfile
	cat $file | grep "log_file" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_sys_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_sys_write_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_flush_order_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 

	printf "\n" >> $outfile
done

#########################################
#for MySQL 8.0
##########################################

for file in output/*.mutex; do
	printf "$(basename "$file") " >> $outfile
	cat $file | grep "log_file" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_checkpointer_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_writer_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_write_notifier_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_closer_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_flusher_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 
	cat $file | grep "log_flush_notifier_mutex" | awk -v n="$runtime" '{printf("%s ", $3/1000000)}' >> $outfile 

	printf "\n" >> $outfile
done

echo "collecting finished. see mutex.txt"
