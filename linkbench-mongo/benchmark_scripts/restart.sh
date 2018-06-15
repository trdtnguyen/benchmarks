# !/bin/bash
echo "stop mongod..."
mongod --shutdown --dbpath=/ssd1/data/db
#mongod --shutdown --dbpath=/hdd1/data/db
sudo sysctl vm.drop_caches=3
sudo sysctl vm.drop_caches=3

echo "start mongod"
mongod -f mongod.conf
