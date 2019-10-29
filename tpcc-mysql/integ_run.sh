#!/bin/bash
source const.sh

#integrate run.sh with other works that should be start at the same time
# Example: in recovery test, we run the thread_killer (daemon kill mysqld after T seconds)

#usage: ./integ_run.sh <method> <threads>

if [ -n $1 ]; then
	METHOD=$1
fi

if [ -n $2 ]; then
	CONN=$2
fi

$BENCHMARK_HOME/thread_killer.sh &
$BENCHMARK_HOME/run.sh ${METHOD} ${CONN}
