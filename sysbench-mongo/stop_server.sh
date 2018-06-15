# !/bin/sh                                                                                                                                                                             

#BENCHMARK_HOME=/home/vldb/benchmark/mongodb
source const.sh

#sudo ${MONGO_HOME}/mongod --shutdown --dbpath=/ssd1/data/db
sudo ${MONGO_HOME}/mongod --shutdown --dbpath=${MONGO_DATA_PATH}
sudo sysctl vm.drop_caches=3
sudo sysctl vm.drop_caches=3

