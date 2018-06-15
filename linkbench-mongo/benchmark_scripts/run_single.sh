# !/bin/sh

#repeat the benchmark $1 time
#call this after finishing loading data
source const.sh


#cache_arr=(30 25 20 15 10 5)
#cache_arr=(5 10 15 20 25 30)
cache_arr=(5 15 25)
#cache_arr=(25 30)
echo "cache_arr[@] = $cache_arr[@]"

for cache in "${cache_arr[@]}"; do
echo "========  Cache = $cache GB ============" 

outdir=${METHOD}_${cache}

#rm -rf /ssd1/data/db
#umount /ssd1
#mkfs.ext4 /dev/sda4
#mount /dev/sda4 /ssd1 -o noatime -o nobarrier
#mkdir -p /ssd1/data/db

#rm -rf $outdir
#mkdir $outdir
#./load.sh $outdir $cache
#sleep 60
#./autorun.sh $outdir $cache

#rm -rf /ssd1/data
#cp -R /ssd3/data /ssd1/
rm -rf /nvme1/data
cp -R /ssd3/data /nvme1/
echo "sleep after cp..."
sleep 120
rm -rf $outdir
mkdir $outdir
./autorun.sh $outdir $cache
sleep 60
done

exit
