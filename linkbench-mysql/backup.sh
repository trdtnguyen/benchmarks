#!/bin/bash
source const.sh

DIRBK=bk1
rm -rf $DIRBK
mkdir $DIRBK
SRC_HOME=/home/vldb/mysql-pmem

cp $SRC_HOME/storage/innobase/btr/btr0cur.cc $DIRBK/btr0cur.cc
cp $SRC_HOME/storage/innobase/buf/buf0flu.cc $DIRBK/buf0flu.cc
cp $SRC_HOME/storage/innobase/buf/buf0rea.cc $DIRBK/buf0rea.cc
cp $SRC_HOME/storage/innobase/fil/fil0fil.cc $DIRBK/fil0fil.cc
cp $SRC_HOME/storage/innobase/fsp/fsp0file.cc $DIRBK/fsp0file.cc
cp $SRC_HOME/storage/innobase/include/my_pmem_common.h $DIRBK/my_pmem_common.h
cp $SRC_HOME/storage/innobase/include/my_pmemobj.h $DIRBK/my_pmemobj.h
cp $SRC_HOME/storage/innobase/pmem/pmem0buf.cc $DIRBK/pmem0buf.cc
cp $SRC_HOME/storage/innobase/pmem/pmem0wrapper.cc $DIRBK/pmem0wrapper.cc
cp $SRC_HOME/storage/innobase/srv/srv0start.cc $DIRBK/srv0start.cc
