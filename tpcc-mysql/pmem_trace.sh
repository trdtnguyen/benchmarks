#!/bin/bash
source const.sh

#trace stat info from innodb statistical schema by time interval

#interval in second
INTERVAL=10
count=0

# sample: 37508687 OS file reads, 28287671 OS file writes, 4046423 OS fsyncs

date="$(date --rfc-3339=seconds)"

echo "Report date:$date" > $OUT_DIR/$TRACE_FILE
printf "reads/s\t\t write/s\t\t fsyncs/s\n" >> $OUT_DIR/$TRACE_FILE

while [ $count -lt $RUNTIME ]; do

mysql -u vldb -e "show engine innodb status \g" > dummy.txt &&
   	sed -i -e 's|\\n|\n|g' dummy.txt &&
	sudo cat dummy.txt | grep 'fsyncs/s' | awk -F' ' '{printf("%s\t\t%s\t\t%s\n", $1, $6, $8)}' >> $OUT_DIR/$TRACE_FILE

	sleep $INTERVAL
	count=$[$count+$INTERVAL]
done

echo "===Total ==================="
$MYSQL -u $USER -e "show engine innodb status \g" > dummy.txt &&
   	sed -i -e 's|\\n|\n|g' dummy.txt &&
	sudo cat dummy.txt | grep 'fsyncs' | awk -F' ' '{printf("%s\n", $0)}' >> $OUT_DIR/$TRACE_FILE
   	rm dummy.txt
