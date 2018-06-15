#!/bin/bash

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

sudo sysctl vm.drop_caches=3 
sudo sysctl vm.drop_caches=3 

outfile=load.txt

## Create the database
$MYSQL -u $USER -e "DROP DATABASE IF EXISTS $DBNAME;" 
$MYSQL -u $USER -e "CREATE DATABASE $DBNAME;" 
$MYSQL -u $USER -e "USE $DBNAME;" 

#$MYSQL -u $USER $DBNAME < $TABLESQL 

$MYSQL -u $USER $DBNAME -e "DROP TABLE IF EXISTS $LB_LINK_TB"
$MYSQL -u $USER $DBNAME -e " CREATE TABLE $LB_LINK_TB (
id1 bigint(20) unsigned NOT NULL DEFAULT '0',
id2 bigint(20) unsigned NOT NULL DEFAULT '0',
link_type bigint(20) unsigned NOT NULL DEFAULT '0',
visibility tinyint(3) NOT NULL DEFAULT '0',
data varchar(255) NOT NULL DEFAULT '',
time bigint(20) unsigned NOT NULL DEFAULT '0',
version int(11) unsigned NOT NULL DEFAULT '0',
PRIMARY KEY (link_type, id1,id2),
KEY id1_type (id1,link_type,visibility,time,id2,version,data)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 PARTITION BY key(id1) PARTITIONS 16; "

$MYSQL -u $USER $DBNAME -e "DROP TABLE IF EXISTS $LB_COUNT_TB"
$MYSQL -u $USER $DBNAME -e "CREATE TABLE $LB_COUNT_TB (
id bigint(20) unsigned NOT NULL DEFAULT '0',
link_type bigint(20) unsigned NOT NULL DEFAULT '0',
count int(10) unsigned NOT NULL DEFAULT '0',
time bigint(20) unsigned NOT NULL DEFAULT '0',
version bigint(20) unsigned NOT NULL DEFAULT '0',
PRIMARY KEY (id,link_type)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

$MYSQL -u $USER $DBNAME -e "DROP TABLE IF EXISTS $LB_NODE_TB"
$MYSQL -u $USER $DBNAME -e "CREATE TABLE $LB_NODE_TB (
id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
type int(10) unsigned NOT NULL,
version bigint(20) unsigned NOT NULL,
time int(10) unsigned NOT NULL,
data mediumtext NOT NULL,
PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

#Set those temporary changes for speed up load phase
$MYSQL -u $USER $DBNAME -e "alter table $LB_LINK_TB drop key id1_type;"
$MYSQL -u $USER $DBNAME -e "set global innodb_flush_log_at_trx_commit = 2;"
$MYSQL -u $USER $DBNAME -e "set global sync_binlog = 0;"


### Now run the load data 
${LINKBENCH_HOME}/bin/linkbench  -c ${LINKBENCH_CONFIG_FILE} -l -csvstats ${LB_CSVSTATS_LOAD_FILE} -csvstream ${LB_CSVSTREAM_LOAD_FILE} -D host=$HOST -D user=$USER -D port=$PORT -D maxid1=${LB_NUM_REC} -D loaders=${LB_LOAD_THREADS} -D debuglevel=${LB_DEBUG_LEVEL}  2>&1 | tee ${outfile}

#Revert the changes
$MYSQL -u $USER $DBNAME -e "set global sync_binlog = 1;"
$MYSQL -u $USER $DBNAME -e "set global innodb_flush_log_at_trx_commit = 1;"
$MYSQL -u $USER $DBNAME -e "alter table linktable add key id1_type
  (id1,link_type,visibility,time,id2,version,data);"

