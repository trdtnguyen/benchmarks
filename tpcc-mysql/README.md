## 1. Build binaries
   * `cd src ; make`
   ( you should have mysql_config available in $PATH)
	
[trdtnguyen added]
	To add mysql server libraries to the shared library cache:
```
   touch /etc/ld.so.conf.d/mysql.conf
   echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
   ldconfig
```

## 2. Load data
   * create database
     `$ mysqladmin create tpcc1000`
   * create tables
     `$ mysql tpcc1000 < create_table.sql`
   * create indexes and FK ( this step can be done after loading data)
     `$ mysql tpcc1000 < add_fkey_idx.sql`
   * populate data
     - simple step
       `$ tpcc_load -h127.0.0.1 -d tpcc1000 -u root -p "" -w 1000`
                 |hostname:port| |dbname| |user| |password| |WAREHOUSES|
       ref. tpcc_load --help for all options
     - load data in parallel 
       check `load.sh` script

[trdtnguyen added]
To help you save time to run `./tpcc_load --help`, I added that info in here
```
$ tpcc_load -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouses -l part -m min_wh -n max_wh
```
* [part]: 1=ITEMS 2=WAREHOUSE 3=CUSTOMER 4=ORDERS


## 3. Start benchmark
   * `$ ./tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w1000 -c32 -r10 -l10800`
   * |hostname| |port| |dbname| |user| |WAREHOUSES| |CONNECTIONS| |WARMUP TIME| |BENCHMARK TIME|
   * ref. tpcc_start --help for all options 

[trdtnguyen added]
To help you save time to run `./tpcc_run --help`, I add that info in here

Usage: 

```
$ tpcc_start -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouses
 -c connections -r warmup_time -l running_time -i report_interval -f report_file -t trx_file
```

## 4. Using script files
	There are some script files from original source code (folked from Percona) that I found useful.
	I also added other script files for my purpose

	* const.sh: global variables

	* load.sh: wrapper for loading data, call tpcc_load (modifed)

	`$ ./load.sh`

	* tpcc_load_parallel.sh: load data parallelism (I modified this file to work with my system)

	`$ ./tpcc_load_parallel.sh`


	* kill_tpcc_load.sh: very simple file that kill all processes that have name tpcc_load

	`$ ./kill_tpcc_load.sh`

	* run.sh: wrapper for run the benchmark
	`$ run.sh method_name number_of_threads`
	
	* tpcc-graph-build.sh: build the benchmark result, using gnuplot
	* start_server.sh / stop_server.sh: simple start/stop mysql server
	`$ ./stop_server.sh`
	

Output
===================================

With the defined interval (-i option), the tool will produce the following output:
```
  10, trx: 12920, 95%: 9.483, 99%: 18.738, max_rt: 213.169, 12919|98.778, 1292|101.096, 1293|443.955, 1293|670.842
  20, trx: 12666, 95%: 7.074, 99%: 15.578, max_rt: 53.733, 12668|50.420, 1267|35.846, 1266|58.292, 1267|37.421
  30, trx: 13269, 95%: 6.806, 99%: 13.126, max_rt: 41.425, 13267|27.968, 1327|32.242, 1327|40.529, 1327|29.580
  40, trx: 12721, 95%: 7.265, 99%: 15.223, max_rt: 60.368, 12721|42.837, 1271|34.567, 1272|64.284, 1272|22.947
  50, trx: 12573, 95%: 7.185, 99%: 14.624, max_rt: 48.607, 12573|45.345, 1258|41.104, 1258|54.022, 1257|26.626
```

Where: 
* 10 - the seconds from the start of the benchmark
* trx: 12920 - New Order transactions executed during the gived interval (in this case, for the previous 10 sec). Basically this is the throughput per interval. The more the better
* 95%: 9.483: - The 95% Response time of New Order transactions per given interval. In this case it is 9.483 sec
* 99%: 18.738: - The 99% Response time of New Order transactions per given interval. In this case it is 18.738 sec
* max_rt: 213.169: - The Max Response time of New Order transactions per given interval. In this case it is 213.169 sec
* the rest: `12919|98.778, 1292|101.096, 1293|443.955, 1293|670.842` is throughput and max response time for the other kind of transactions and can be ignored

Analysis
===================================

`$ ./tpcc-output-analyze.sh output/ori_W1000_BP5.out > output/ori_W1000_BP5_analy.txt`
`$ ./tpcc-output-analyze.sh output/method1_W1000_BP5.out > output/method1_W1000_BP5_analy.txt`

Build gnuplot
===================================
Combine two file
`$ paste output/ori_W1000_BP5_analy.txt output/method1_W1000_BP5_analy.txt > combined_W1000_BP5_analy.txt`

`$ ./tpcc-graph-build.sh combine_W1000_BP5_analy.txt combined_W1000_BP5_graph.jpg`
