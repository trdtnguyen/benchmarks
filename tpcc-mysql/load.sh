#!/bin/bash

#usage: ./load.sh

source const.sh

#DBNAME=$1
#WH=$2
#HOST=localhost


STEP=100

if [ ! -d $OUT_DIR ]; then
	mkdir $OUT_DIR
fi

echo "DROP and CREATE databases"
$MYSQL -u $USER  -e "DROP DATABASE IF EXISTS $DBNAME"
$MYSQL -u $USER  -e "CREATE DATABASE $DBNAME"
$MYSQL -u $USER  $DBNAME < $TABLESQL
$MYSQL -u $USER  $DBNAME < $CONSTRAINTSQL


echo "Load database with $WH warehouses..."
#            host       dbname	user	passw	warehouses part min_wh max_wh
#* [part]: 1=ITEMS 2=WAREHOUSE 3=CUSTOMER 4=ORDERS

echo 'Loading item ...'
#./tpcc_load -h$HOST -d$DBNAME -u$USER -p"" -w$WH -l1 -m1 -n$WH >> 1.out &
$TPCC_LOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l1 -m1 -n$WH > $OUT_DIR/1.out &

x=1

while [ $x -le $WH ]
do
	 echo $x $(( $x + $STEP - 1 ))
	# warehouse, stock, district
	$TPCC_LOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l2 -m$x -n$(( $x + $STEP - 1 ))  > $OUT_DIR/2_$x.out &
	# customer, history
	$TPCC_LOAD -h$HOST -d$DBNAME -u$USER -w$WH -l3 -m$x -n$(( $x + $STEP - 1 ))  > $OUT_DIR/3_$x.out &
	# orders, new_orders, order_line
	$TPCC_LOAD -h$HOST -d$DBNAME -u$USER -w$WH -l4 -m$x -n$(( $x + $STEP - 1 ))  > $OUT_DIR/4_$x.out &

	 x=$(( $x + $STEP ))
done

