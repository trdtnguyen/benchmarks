import re
import os
import sys
import datetime

#set this value False to debug
#is_rm_tem_files=False
is_rm_tem_files=True

if (len(sys.argv) != 2):
    print("Wrong syntax\nusage: re.py <input_file>")
    sys.exit(0)

infile=sys.argv[1]
outfile="detail_perf.txt"
all_perf_file='all_perf.txt'

date = datetime.datetime.today().strftime('%Y-%m-%d')

## Remove files if existed
if (not is_rm_tem_files):
    os.system("rm mtem")
    os.system("rm wttem")
    os.system("rm othertem")
    
    
    os.system("rm tem_m1")
    os.system("rm tem_m2")
    os.system("rm tem_m3")
    os.system("rm tem_m4")
    os.system("rm tem_mo")
    
    os.system("rm tem1")
    os.system("rm tem2")
    os.system("rm tem3")
    os.system("rm tem4")
    os.system("rm tem5")
    os.system("rm tem6")
    os.system("rm tem7")
    os.system("rm tem8")

## List of patterns with the priority. If a line match with parttern re1 it will not apear in the result of re2

#mongo
re_mongo=r'_Z'
#Query processing
re_m1=r'field|item|table|join|tuple|command|BSON|exec|plan|parse'
#Replica, Sharding, OpLog
re_m2=r'ops|repl|shard'

#Memory, Compression
re_m3=r'snappy|alloc|mem'
#Service: ServiceState
re_m4=r'Service'

#WiredTiger: __wt, __realloc_, __rec_write
re_wt=r'__'

#Buffer pool
re1=r'buf|block|lru|evict|reconcile'

#Log management
re2=r'_log|oplog|logger|undo|redo'

# File system, AIO, os_event, Space management(page, cell, block
re3=r'block|page|cell|checksum|wt_struct|file'

#B+Tree, Indexing
re4=r'btr|bt_|row|rec|cursor|btcur|search|index|tree|hash|hazard'

#Transaction Processing
re5=r'commi|trx|txn|transaction'

#lock
re6=r'mutex|lock|latch'

#Memory: alloc/free, snappy compress, pack/unpack
re7=r'mem|alloc|free|snappy|strcm|strncm|qsort|dtoa|strtod|pack|unpack'


#open temp files

## Use re.I for case-Intensive search
#Step 1: Distinguish mongo, WT, and others
with open (infile) as f:
    for line in f:
        searchObj = re.search(re_mongo, line, re.I | re.M)
        if searchObj:
            with open('mtem', 'a') as fm:
                fm.write(line)
        else:
            searchObj = re.search(re_wt, line, re.I | re.M)
            if searchObj:
                with open('wttem', 'a') as fw:
                  fw.write(line)
            else:
                with open('othertem', 'a') as fo:
                    fo.write(line)

#Step 2: Investigate Mongo
with open ('mtem') as f:
    for line in f:
        searchObj = re.search(re_m1, line, re.I | re.M)
        if searchObj:
            with open('tem_m1', 'a') as f1:
                f1.write(line) 
        else:
            searchObj = re.search(re_m2, line, re.I | re.M)
            if searchObj:
                with open('tem_m2', 'a') as f2:
                    f2.write(line) 
            else:
                searchObj = re.search(re_m3, line, re.I | re.M)
                if searchObj:
                    with open('tem_m3', 'a') as f3:
                        f3.write(line) 
                else:
                    searchObj = re.search(re_m4, line, re.I | re.M)
                    if searchObj:
                        with open('tem_m4', 'a') as f4:
                            f4.write(line) 
                    else:
                        with open('tem_mo', 'a') as fo:
                            fo.write(line)

#Step 3: Investigate WiredTiger 

with open ('wttem') as f:
    for line in f:
        searchObj = re.search(re1, line, re.I | re.M)
        if searchObj:
            with open('tem1', 'a') as f1:
                f1.write(line) 
        else:
            searchObj = re.search(re2, line, re.I | re.M)
            if searchObj:
                with open('tem2', 'a') as f2:
                    f2.write(line) 
            else:
                searchObj = re.search(re3, line, re.I | re.M)
                if searchObj:
                    with open('tem3', 'a') as f3:
                        f3.write(line) 
                else:
                    searchObj = re.search(re4, line, re.I | re.M)
                    if searchObj:
                        with open('tem4', 'a') as f4:
                            f4.write(line) 
                    else:
                        searchObj = re.search(re5, line, re.I | re.M)
                        if searchObj:
                            with open('tem5', 'a') as f5:
                                f5.write(line) 
                        else:
                            searchObj = re.search(re6, line, re.I | re.M)
                            if searchObj:
                                with open('tem6', 'a') as f6:
                                    f6.write(line) 
                            else:
                                searchObj = re.search(re7, line, re.I | re.M)
                                if searchObj:
                                    with open('tem7', 'a') as f7:
                                        f7.write(line) 
                                else:
                                    with open('tem8', 'a') as f8:
                                        f8.write(line) 
    #end for

    ##Step 4: Compute sum overhead for each components
    mongo_sum=0.0
    wt_sum=0.0
    
    sum_m1=0.0
    sum_m2=0.0
    sum_m3=0.0
    sum_m4=0.0
    sum_mo=0.0

    sum1=0.0
    sum2=0.0
    sum3=0.0
    sum4=0.0
    sum5=0.0
    sum6=0.0
    sum7=0.0
    sum8=0.0

    with open('mtem') as fm:
        for line in fm:
            strs=line.split()
            mongo_sum += float(strs[0])

    with open('wttem') as fw:
        for line in fw:
            strs=line.split()
            wt_sum += float(strs[0])

    total_other = 100 - (mongo_sum + wt_sum)

################################################
    with open('tem_m1') as f1:
        for line in f1:
            strs1=line.split()
            sum_m1 +=float(strs1[0])
    with open('tem_m2') as f2:
        for line in f2:
            strs2=line.split()
            sum_m2 +=float(strs2[0])
    with open('tem_m3') as f3:
        for line in f3:
            strs3=line.split()
            sum_m3 +=float(strs3[0])
    with open('tem_m4') as f4:
        for line in f4:
            strs4=line.split()
            sum_m4 +=float(strs4[0])

    mongo_other = mongo_sum - (sum_m1 + sum_m2 + sum_m3 + sum_m4)
###########################################
    with open('tem1') as f1:
        for line in f1:
            strs1=line.split()
            sum1 +=float(strs1[0])

    with open('tem2') as f2:
        for line in f2:
            strs2=line.split()
            sum2 +=float(strs2[0])

    with open('tem3') as f3:
        for line in f3:
            strs=line.split()
            sum3 +=float(strs[0])

    with open('tem4') as f4:
        for line in f4:
            strs=line.split()
            sum4 +=float(strs[0])

    with open('tem5') as f5:
        for line in f5:
            strs=line.split()
            sum5 +=float(strs[0])

    with open('tem6') as f6:
        for line in f6:
            strs=line.split()
            sum6 +=float(strs[0])

    with open('tem7') as f7:
        for line in f7:
            strs=line.split()
            sum7 +=float(strs[0])

#We can compute other by subtracting 100 to sum of overhead. However, we use this
# method to generate the tem9 file that is useful to know what "other" actually is
    with open('tem8') as f8:
        for line in f8:
            strs=line.split()
            sum8 +=float(strs[0])
   
    wt_other = wt_sum - (sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7)
   
    #Now print the result
    with open(outfile, 'a') as f:
       f.write("================================================\n")
       f.write("Input file: " + infile + ", computed on " + date + "\n")

       f.write("\nTotal-mongo: \t\t\t\t\t\t" + str(mongo_sum))
       f.write("\nTotal-WT: \t\t\t\t\t\t\t" + str(wt_sum))
       f.write("\nTotal-Other: \t\t\t\t\t\t" + str(total_other))
       f.write("\n")

       f.write("\nmongo-Query-Processing: \t\t\t" + str(sum_m1) + "\t" + str(100 / mongo_sum * sum_m1))
       f.write("\nmongo-Replicate-sharding-OPlog: \t" + str(sum_m2) + "\t" + str(100 / mongo_sum * sum_m2 ))
       f.write("\nmongo-Memory-Compress: \t\t\t\t" + str(sum_m3) + "\t" + str(100 / mongo_sum * sum_m3 ))
       f.write("\nmongo-Service: \t\t\t\t\t\t" + str(sum_m4) + "\t" + str(100 / mongo_sum * sum_m4 ))
       f.write("\nmongo-Others: \t\t\t\t\t\t" + str(mongo_other) + "\t" + str(100 / mongo_sum * mongo_other))
       f.write("\n")
       
       f.write("\nWT-Buffer-Manager: \t\t\t\t\t" + str(sum1) + "\t" + str(100 / wt_sum * sum1))
       f.write("\nWT-Log-Manager: \t\t\t\t\t" + str(sum2) + "\t" + str(100 / wt_sum * sum2))
       f.write("\nWT-File-System: \t\t\t\t\t" + str(sum3) + "\t" + str(100 / wt_sum * sum3))
       f.write("\nWT-B+Tree,Indexing: \t\t\t\t" + str(sum4) + "\t" + str(100 / wt_sum * sum4))
       f.write("\nWT-Transaction-Processing: \t\t\t" + str(sum5) + "\t" + str(100 / wt_sum * sum5))
       f.write("\nWT-Locking: \t\t\t\t\t\t" + str(sum6) + "\t" + str(100 / wt_sum * sum6))
       f.write("\nWT-Memory: \t\t\t\t\t\t\t" + str(sum7) + "\t" + str(100 / wt_sum * sum7))
       f.write("\nWT-Other: \t\t\t\t\t\t\t" + str(wt_other) + "\t" + str(100 / wt_sum * wt_other))

       f.write("\n================================================\n")
    #This print for gnuplot stacked bar 
    is_not_exist=False
    if (not os.path.isfile(all_perf_file)):
        is_not_exist=True
    with open(all_perf_file, 'a') as f:
        if(is_not_exist):
            f.write("File Date Buffer-Manager Logging FileSystem Indexing TP Locking Memory Other\n")
        f.write(infile + "\t" + date + "\t" + str(100 / wt_sum * sum1)
                + " " + str(100 / wt_sum * sum2)
                + " " + str(100 / wt_sum * sum3)
                + " " + str(100 / wt_sum * sum4)
                + " " + str(100 / wt_sum * sum5)
                + " " + str(100 / wt_sum * sum6)
                + " " + str(100 / wt_sum * sum7)
                + " " + str(100 / wt_sum * wt_other)
                + "\n"
                )
    print("Computing finished. See the result in " + outfile + "\n")

if (is_rm_tem_files):

    ## Remove files if existed
    os.system("rm mtem")
    os.system("rm wttem")
    os.system("rm othertem")
    
    os.system("rm tem_m1")
    os.system("rm tem_m2")
    os.system("rm tem_m3")
    os.system("rm tem_m4")
    os.system("rm tem_mo")
    
    os.system("rm tem1")
    os.system("rm tem2")
    os.system("rm tem3")
    os.system("rm tem4")
    os.system("rm tem5")
    os.system("rm tem6")
    os.system("rm tem7")
    os.system("rm tem8")
