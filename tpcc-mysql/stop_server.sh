#!/bin/bash

#get const from const.sh file
source const.sh

sudo $MYSQL_BIN/mysqladmin -h$HOST -u$USER shutdown
#$MYSQL_BIN/mysqladmin  -u$USER  shutdown
