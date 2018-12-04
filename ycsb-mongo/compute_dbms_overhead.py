import re
import os
import sys
import datetime

if (len(sys.argv) != 2):
    print("Wrong syntax\nusage: re.py <input_file>")
    sys.exit(0)

infile=sys.argv[1]
outfile=infile + ".out"

date = datetime.datetime.today().strftime('%Y-%m-%d')

## Remove files if existed
os.system("rm tem1")
os.system("rm tem2")
os.system("rm tem3")
os.system("rm tem4")
os.system("rm tem5")
os.system("rm tem6")
os.system("rm tem7")
os.system("rm tem8")
os.system("rm tem9")

## List of patterns with the priority. If a line match with parttern re1 it will not apear in the result of re2

#Buffer pool
re1=r'buf|block|lru|evict|reconcile'

#Log management
re2=r'_log|oplog|logger|undo|redo'

# File system, AIO, os_event, Space management(page, cell, block
re3=r'block|snappy|page|cell|checksum|wt_struct|file'

#B+Tree, Indexing
re4=r'btr|bt_|row|rec|cursor|btcur|search|index|tree|hash|hazard'

#Transaction Processing
re5=r'commi|trx|txn|transaction'

#lock
re6=r'mutex|lock|latch'

#Query processing
re7=r'field|item|table|join|tuple|commnand|BSON|execu'

#Memory
re8=r'mem|alloc|free|strcmp|qsort|dtoa|strtod'

#open temp files

## Use re.I for case-Intensive search
with open (infile) as f:
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
                                    searchObj = re.search(re8, line, re.I | re.M)
                                    if searchObj:
                                        with open('tem8', 'a') as f8:
                                            f8.write(line) 
                                    else:
                                        with open('tem9', 'a') as f9:
                                            f9.write(line) 
    #end for

    ##Step 2: Compute sum overhead for each components
    sum1=0.0
    sum2=0.0
    sum3=0.0
    sum4=0.0
    sum5=0.0
    sum6=0.0
    sum7=0.0
    sum8=0.0
    sum9=0.0

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

    with open('tem8') as f8:
        for line in f8:
            strs=line.split()
            sum8 +=float(strs[0])
#We can compute other by subtracting 100 to sum of overhead. However, we use this
# method to generate the tem9 file that is useful to know what "other" actually is
    with open('tem9') as f9:
        for line in f9:
            strs=line.split()
            sum9 +=float(strs[0])
   
    other = 100 - (sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7 + sum8)
   
    #Now print the result
    with open(outfile, 'a') as f:
       f.write("================================================\n")
       f.write("Input file: " + infile + ", computed on " + date + "\n")

       f.write("\nBuffer-Manager: \t\t\t" + str(sum1))
       f.write("\nLog-Manager: \t\t\t\t" + str(sum2))
       f.write("\nFile-System: \t\t\t\t" + str(sum3))
       f.write("\nB+Tree,Indexing: \t\t\t" + str(sum4))
       f.write("\nTransaction-Processing: \t" + str(sum5))
       f.write("\nLocking: \t\t\t\t\t" + str(sum6))
       f.write("\nQuery-Processing: \t\t\t" + str(sum7))
       f.write("\nMemory: \t\t\t\t\t" + str(sum8))
       f.write("\nOther_method1: \t\t\t\t\t\t" + str(other))
       f.write("\nOther_method2: \t\t\t\t\t\t" + str(sum9))

       f.write("\n*Note: Other=innodb handler,thread\n")

       f.write("\n================================================\n\n")

    print("Computing finished. See the result in " + outfile + "\n")
