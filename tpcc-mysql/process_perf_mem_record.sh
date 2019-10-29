#!/bin/bash
source const.sh
#Input: the output file of perf record command
#Output: The overhead (%) of only user space (Those with [.])

in_file=perf.data
#is_debug=0
is_debug=1

if [ -n $1 ]; then
	in_file=$1
	echo "input file is $1"
fi

out_file=${in_file}_result.txt
echo "1. Run perf-mem report ..."
sudo perf report -i $in_file -f -s symbol > temp1

echo "2. Process the result of perf report..."

#Filter out the line with "[.]"
us_per=$(cat temp1 | grep -w "[[\.]]" | awk '{sum1+=$1} END {printf("%s",sum1)}')
pmem_per=$(cat temp1 | grep pm | awk '{sum1+=$1} END {printf("%f",sum1)}')
echo "total user space overhead $us_per"
echo "total pmem overhead $pmem_per"

cat temp1 | grep -w "[[\.]]" | awk -v sum_us="$us_per" '{printf("%s %s %s\n",$1/sum_us*100, $2, $3)}' > $out_file

#integrate python
#echo "3. Process dbms overhead"
python compute_dbms_overhead.py $out_file

if [ $is_debug -eq 0 ]; then
	rm temp1
	rm $out_file
fi
