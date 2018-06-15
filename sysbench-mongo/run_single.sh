# !/bin/sh

#repeat the benchmark $1 time
#call this after finishing loading data
source const.sh


#cache_arr=(30 25 20 15 10 5)
#cache_arr=(10 15 20 25 30)
#cache_arr=(30 25 20)
#cache_arr=(5)
#cache_arr=(20)
cache_arr=(5 15 20)
#cache_arr=(30 15 5)
#sleep_time=60 #sleep time in second
sleep_time=15 #sleep time in second
echo "cache_arr[@] = $cache_arr[@]"

for cache in "${cache_arr[@]}"; do
echo "========  Cache = $cache GB ============" 

outdir=${BENCHMARK_HOME}/${METHOD}_${cache}

if [ $IS_RESET -eq 1 ]; then
umount /ssd1
mkfs.ext4 /dev/sda4
mount /dev/sda4 /ssd1 -o noatime -o nobarrier
mkdir -p /ssd1/data/db
else
rm -rf /ssd1/data
fi

rm -rf $outdir
mkdir $outdir
#./load.sh $outdir $cache
#sleep 60
#./autorun.sh $outdir $cache

cp -R /ssd3/data /ssd1/
#rm -rf /nvme1/data
#cp -R /ssd3/data /nvme1/
echo "sleep after cp..."
sleep $sleep_time 
./autorun.sh $outdir $cache
sleep $sleep_time 
done

exit
