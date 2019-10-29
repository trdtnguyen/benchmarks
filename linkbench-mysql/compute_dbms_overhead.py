import re
import os
import sys
import datetime

#set this value False to debug
is_rm_tem_files=False
#is_rm_tem_files=True

if (len(sys.argv) != 2):
    print("Wrong syntax\nusage: re.py <input_file>")
    sys.exit(0)

infile=sys.argv[1]
outfile="detail_perf.txt"
all_perf_file='all_perf.txt'

date = datetime.datetime.today().strftime('%Y-%m-%d')

## Remove files if existed
if (not is_rm_tem_files):
    os.system("rm tem0")
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

#PMEM
re0=r'pm_'
#Buffer pool
re1=r'buf|block|lru'

#Log management
re2=r'log|undo|redo'

#lock
re3=r'mutex|lock|latch'

#B+Tree, Indexing
re4=r'btr|row|search|index|tree|hash'

#Transaction Processing
re5=r'mtr|commi|trx'

# File system, AIO, os_event
re6=r'pfs|file|fil_|AIO|io_|fsp|os_event'

#Query processing
re7=r'field|item|table|join|tuple|mysql|command'

#Memory
re8=r'mem|alloc|free|strcmp|qsort|dtoa|strtod'

#open temp files

## Use re.I for case-Intensive search
with open (infile) as f:
    for line in f:
        searchObj = re.search(re0, line, re.I | re.M)
        if searchObj:
            with open('tem0', 'a') as f0:
                f0.write(line) 
        else:
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
    sum0=0.0
    sum1=0.0
    sum2=0.0
    sum3=0.0
    sum4=0.0
    sum5=0.0
    sum6=0.0
    sum7=0.0
    sum8=0.0
    sum9=0.0

    with open('tem0') as f0:
        for line in f0:
            strs0=line.split()
            sum0 +=float(strs0[0])
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

       f.write("\nPMEM: \t\t\t" + str(sum0))
       f.write("\nBuffer-Manager: \t\t\t" + str(sum1))
       f.write("\nLog-Manager: \t\t\t\t" + str(sum2))
       f.write("\nLocking: \t\t\t\t\t" + str(sum3))
       f.write("\nB+Tree,Indexing: \t\t\t" + str(sum4))
       f.write("\nTransaction-Processing: \t" + str(sum5))
       f.write("\nFile-System: \t\t\t\t" + str(sum6))
       f.write("\nQuery-Processing: \t\t\t" + str(sum7))
       f.write("\nMemory: \t\t\t\t\t" + str(sum8))
       f.write("\nOther_method1: \t\t\t\t" + str(other))

       f.write("\n*Note: Other=innodb handler,thread\n")

       f.write("\n================================================\n\n")

    #This print for gnuplot stacked bar 
    is_not_exist=False
    if (not os.path.isfile(all_perf_file)):
        is_not_exist=True
    with open(all_perf_file, 'a') as f:
        if(is_not_exist):
            f.write("File Date BM Logging Locking Indexing TP FileSystem QueryProcessing Memory Other\n")
        f.write(infile + "\t" + date + "\t" + str(sum0)
                + " " + str(sum1)
                + " " + str(sum2)
                + " " + str(sum3)
                + " " + str(sum4)
                + " " + str(sum5)
                + " " + str(sum6)
                + " " + str(sum7)
                + " " + str(sum8)
                + " " + str(other)
                + "\n"
                )

    print("Computing finished. See the result in " + outfile + "\n")

if (is_rm_tem_files):
    os.system("rm tem0")
    os.system("rm tem1")
    os.system("rm tem2")
    os.system("rm tem3")
    os.system("rm tem4")
    os.system("rm tem5")
    os.system("rm tem6")
    os.system("rm tem7")
    os.system("rm tem8")
    os.system("rm tem9")
