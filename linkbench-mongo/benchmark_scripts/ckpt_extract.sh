# !/bin/sh

#extract information from SSDM_OP8 method 
#input: my_mssd_track8.txt
#output: extracted_file

outfile=$2
#filename w1 w2 sid_tem1 sid_tem2 sid1 sid2  local_pct1 local_pct2 global_pct1 global pct2 duration_s wpps1 wpps2 min p1 p2 max
#local_pct1 = (w1 / (w1 + w2) *100)
#global_pct1 for collection
# global_pct1 = (c1_w1
#duration_s: duration of a checkpoint in seconds
#wpps: number of write per 4kb page per second

#grep 'ckpt' $1 | awk '{printf("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n", $3, $7, $9, $11, $13, $15, $17, $19,$21, $23, $25, $27, $29, $31, $33, $35, $37, $39)}' > ${outfile}
#get all and filter in excel
grep 'ckpt' $1 | awk '{printf("%s\n", $0)}' > ${outfile}

#extract for each file 
#sid_tem1: $4 sid_tem2: $5 sid1:$6 sid2:$7 global_pct1:$10 global_pct2:$11 wpps1:$13 wpps2:$14 min:$15 p1:$16 p2:$17 max:$18
awk '{ if (NR % 9 == 1) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $7, $10, $12, $13, $14, $15, $16, $17, $18)}}' ${outfile} > ${outfile}_count_coll 
awk '{ if (NR % 8 == 2) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_link_coll 
awk '{ if (NR % 8 == 3) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_node_coll 
awk '{ if (NR % 8 == 4) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_node_pri 
awk '{ if (NR % 8 == 5) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_link_2nd1 
awk '{ if (NR % 8 == 6) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_link_2nd2 
awk '{ if (NR % 8 == 7) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_link_pri
awk '{ if (NR % 8 == 8) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_count_2nd
awk '{ if (NR % 8 == 0) {printf("%s %s %s %s %s %s %s %s %s %s %s\n", $4, $5, $6, $9, $10, $12, $13, $14, $15, $16, $17)}}' ${outfile} > ${outfile}_count_pri

#awk '{ if (NR % 9 == 1) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_count_coll 
#awk '{ if (NR % 9 == 2) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_link_coll 
#awk '{ if (NR % 9 == 3) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_node_coll 
#awk '{ if (NR % 9 == 4) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_node_pri 
#awk '{ if (NR % 9 == 5) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_link_2nd1 
#awk '{ if (NR % 9 == 6) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_link_2nd2 
#awk '{ if (NR % 9 == 7) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_link_pri 
#awk '{ if (NR % 9 == 8) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_count_2nd 
#awk '{ if (NR % 9 == 0) {printf("%s %s %s %s %s %s %s %s %s\n", $8, $9, $10, $11, $12, $13, $14, $15, $16)}}' ${outfile} > ${outfile}_count_pri
