#!/bin/sh                                                                                                                                                                              
# requirement: my_reconcile_track.txt (enable SSDM_OP3 macro)
# for a given workload e.g. YCSB workloada, count how many clean page eviction, how many dirty page eviction
datafile=$1
out1='dirty_pages'
out2='clean_pages'
out3='recno_freq'
#grep '__evict_page_dirty_update' ${datafile} > 'dirty_pages'
grep 'evict_count' ${datafile} > ${out1}
grep '__evict_page_clean_update' ${datafile} > ${out2}
echo 'extract dirty_pages, clean pages to files'
d_count=$(wc -l dirty_pages)
c_count=$(wc -l clean_pages)

echo 'Number of dirty pages eviction'
echo $d_count
echo $c_count

echo 'counting frequency by recno, output is recno_freq'
awk  '{ h[$5]++}; END { for (k in h) printf("%s\t%s\n", k, h[k]) }' ${out1}  > ${out3} 
