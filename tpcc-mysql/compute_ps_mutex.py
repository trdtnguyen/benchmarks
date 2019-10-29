##############
## Collect information from InnoDB's performance schema for tuning system
#############
import re #regular expression lib in Python
import os
import sys
import datetime
import array as arr

#set this value False to debug
is_rm_tem_files=False
#is_rm_tem_files=True

if (len(sys.argv) != 2):
    print("Wrong syntax\nusage: re.py <input_file>")
    sys.exit(0)

infile=sys.argv[1]
outfile_overall="overall_mutex_ps.txt"
outfile_detail="detail_mutex_ps.txt"
outfile_log="overall_log_mutex.txt"
all_perf_file='all_mutex_ps.txt'

date = datetime.datetime.today().strftime('%Y-%m-%d')
#Number of categories. How to determine N is up to your purpose.
N = 11

#fnames = ["tem0", "tem1", ...,,]
fnames = []
for i in range(0,N):
    fnames.append("tem" + str(i))


## Remove files if existed
if (not is_rm_tem_files):
    for f in fnames:
        cmd = "rm " + f
        os.system(cmd)

## Classify PS events into groups. The order of group is important.
## If we check groups in order of A > B, then we don't check pattern P in group B if it apear in group A

# Data file I/O
re0=r'innodb_data_file'

# Bin log
## wait/io/file/sql/binlog, wait/io/file/sql/binlog_index
re1=r'binlog' 

# Log file I/O
re2=r'log_file' #innodb_log_file
log_IO_i=2
#File System, Dictionary
## fil_system_mutex, fil_space_latch, dict_sys_mutex, dict_table_mutex, innodb_temp_file
re3=r'fil_system_mutex|fil_space_latch|dict_sys_mutex|dict_table_mutex|innodb_temp_file'

# Query Processing
## wait/io/table/sql/handler, wait/lock/table/sql/handler
re4=r'handler'

# Transaction Processing
## wait/synch/mutex/trx_mutex, trx_sys_mutex
re5=r'trx_mutex|trx_sys'

# General lock management
## lock_mutex, lock_wait_mutex
re6=r'lock_mutex|lock_wait_mutex'

#REDO logging
## log_checkpointer_mutex, log_writer_mutex, log_write_notifier_mutex, log_flush_notifier_mutex, log_closer_mutex, log_flusher_mutex
re7=r'log_|_log' 
tem_redo_log_file="tem7"

# UNDO logging
## wait/synch/mutex/innodb/undo_space_rseg_mutex, wait/synch/mutex/innodb/trx_undo_mutex
re8=r'undo_space|trx_undo|temp_space_rseg_mutex' 
undo_log_i=8

## Buffer Manager (include double-write buffer and insert-buffer)
# *buf* for: buf_dblwr_mutex, buf_pool_LRU_list_mutex, 
#buf_pool_free_list_mutex, buf_pool_flush_state_mutex

re9=r'buf|flush_list_mutex|page_cleaner_mutex'

# Detail analysis for log overhead
## Events: checkpoint mutex: log_checkpoint_mutex;
## DRAM -> log buffer: log_writer_mutex, log_write_notifier_mutex, log_closer_mutex
## log buffer -> WAL file: log_flusher_mutex, log_flush_notifier_mutex
N_LOG = 6 #Number of sub-catagory in log catagory
log_re1=r'log_checkpointer_mutex'
log_re2=r'log_writer_mutex'
log_re3=r'log_write_notifier_mutex'
log_re4=r'log_closer_mutex'
log_re5=r'log_flusher_mutex'
log_re6=r'log_flush_notifier_mutex'

re_arr=[re0, re1, re2, re3, re4, re5, re6, re7, re8, re9]
log_re_arr=[log_re1, log_re2, log_re3, log_re4, log_re5, log_re6]

skip_line_no = 1
line_count = 0

##### BEGIN OVERALL
#Open the input file, for each line in the input file print the line to the tem file
with open (infile) as f:
    for line in f:
        is_pattern_found = False
        line_count += 1
        if (line_count == skip_line_no):
            continue
        for i in range(0, N-1):
            r = re_arr[i]
            searchObj = re.search(r, line, re.I | re.M)
            if searchObj:
                with open(fnames[i], 'a') as f:
                    f.write(line)
                is_pattern_found = True
                #break on matched pattern
                break
        #end for, if no pattern match, then it is "other" catagory
        if (not is_pattern_found):
            with open(fnames[N-1], 'a') as f:
                f.write(line)

    ##Step 2: Compute sum overhead for each components
    sum_arr = []
    for i in range(0, N):
        sum_arr.append(0.0)
    
    for i in range(0, N):
        with open(fnames[i]) as f:
            for line in f:
                #print ("line %s i= %d"%(line, i))
                strs0=line.split()
                sum_arr[i] += float(strs0[2])

    catagory_arr=  [
            "Data File I/O",
            "Binlog", 
            "Log File I/O",
            "File Sytem",
            "Query Processing",
            "Transaction Processing",
            "General Lock Mngt",
            "REDO logging",
            "UNDO logging",
            "Buffer Manager",
            "Others"
            ]

    #Print one-line-per-file result for drawing graph
    with open(outfile_overall, 'a') as f:
        f.write(date + " " + infile)
        for i in range(0, N):
            val = sum_arr[i] * 1.0 / 1000000
            f.write(" " + ("%.3f" % val) )
            #f.write(" " + str(val))
        f.write("\n")

    #Now print the detail result
    with open(outfile_detail, 'a') as f:
       f.write("================================================\n")
       f.write("Peformance Schema overhead (seconds); \ninput file: " + infile + ";\n computed on " + date + "\n")
       for i in range(0, N):
           #convert from us to s
           val = sum_arr[i] * 1.0 / 1000000 
           f.write("\n" + catagory_arr[i] + ": " + str(val))
       f.write("\n================================================\n\n")
##### End overall 

##### Begin Log Detail

log_val_arr = [0, 0, 0, 0, 0, 0]
with open (tem_redo_log_file) as f:
    for line in f:
        for i in range(0, N_LOG):
            val = 0
            r = log_re_arr[i]
            searchObj = re.search(r, line, re.I | re.M)
            if searchObj:
                strs0 = line.split()
                log_val_arr[i] = float(strs0[2])
                break

with open(outfile_log, 'a') as fout:
    # Header
    fout.write(date + " " + infile)

    # Log file I/O
    val = sum_arr[log_IO_i] * 1.0 / 1000000
    fout.write(" " + ("%.3f" % val) )
    #fout.write(" " + str(val))

    # UNDO log
    val = sum_arr[undo_log_i] * 1.0 / 1000000
    fout.write(" " + ("%.3f" % val) )
    #fout.write(" " + str(val))
    
    # REDO log
    for i in range(0, N_LOG):
        val = log_val_arr[i] * 1.0 /1000000
        fout.write(" " + ("%.3f" % val) )
        #fout.write(" " + str(log_val_arr[i] * 1.0 /1000000))

    fout.write("\n")

##### End Log Detal
print("Computing finished. See result in " + str(outfile_detail) + ", " + str(outfile_overall) + ", and " + str(outfile_log))

if (is_rm_tem_files):
    for f in fnames:
        cmd = "rm " + f
        os.system(cmd)
