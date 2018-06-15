#!/bin/bash

source const.sh
# Configration


if [ ! -d $OUT_DIR ]; then
	mkdir $OUT_DIR
fi

DEGREE=$(getconf _NPROCESSORS_ONLN)

# Load

echo "DROP and CREATE databases"

set -e
$MYSQL -u $USER -h $HOST -e "DROP DATABASE IF EXISTS $DBNAME"
$MYSQL -u $USER  -h $HOST -e "CREATE DATABASE $DBNAME"
$MYSQL -u $USER -h $HOST $DBNAME < $TABLESQL
$MYSQL -u $USER -h $HOST $DBNAME < $CONSTRAINTSQL

echo 'Loading item ...'
#$TPCCLOAD -h$HOST -d$DBNAME -u$USER -p$PASS -w$WH -l1 -m1 -n$WH > /dev/null
$TPCCLOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l1 -m1 -n$WH > $OUT_DIR/1.out

set +e
STATUS=0
trap 'STATUS=1; kill 0' INT TERM

for ((WID = 1; WID <= WH; WID++)); do
	echo "Loading warehouse id $WID ..."

	(
	set -e

	# warehouse, stock, district
	$TPCCLOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l2 -m$WID -n$WID > /dev/null

	# customer, history
	$TPCCLOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l3 -m$WID -n$WID > /dev/null

	# orders, new_orders, order_line
	$TPCCLOAD -h$HOST -d$DBNAME -u$USER  -w$WH -l4 -m$WID -n$WID > /dev/null
	) &

	PIDLIST=(${PIDLIST[@]} $!)

	if [ $(($WID % $DEGREE)) -eq 0 ]; then
		for PID in ${PIDLIST[@]}; do
			wait $PID

			if [ $? -ne 0 ]; then
				STATUS=1
			fi
		done

		if [ $STATUS -ne 0 ]; then
			exit $STATUS
		fi

		PIDLIST=()
	fi
done

for PID in ${PIDLIST[@]}; do
	wait $PID

	if [ $? -ne 0 ]; then
		STATUS=1
	fi
done

if [ $STATUS -eq 0 ]; then
	echo 'Completed.'
fi

exit $STATUS
