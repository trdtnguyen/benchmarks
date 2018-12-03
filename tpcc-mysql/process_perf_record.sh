#!/bin/bash
source const.sh
#Input: the output file of perf record command
#Output: The overhead (%) of only user space (Those with [.])

in_file=perf.data

if [ -n $1 ]; then
	in_file=$1
	echo "input file is $1"
fi

out_file=${in_file}_result.txt
echo "1. Run perf report ..."
sudo perf report -i $in_file -f -s symbol > temp1

echo "2. Process the result of perf report..."

#Filter out the line with "[.]"
us_per=$(cat temp1 | grep -w "[[\.]]" | awk '{sum1+=$1} END {printf("%s",sum1)}')
echo "total user space overhead $us_per"

cat temp1 | grep -w "[[\.]]" | awk -v sum_us="$us_per" '{printf("%s %s %s\n",$1/sum_us*100, $2, $3)}' > $out_file

echo "3. End process perf record. See the result in $out_file"
