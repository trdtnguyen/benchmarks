# !/bin/sh
mongod --configsvr --dbpath=/data/configdb --port=27019 -f mongod_configsvr.conf
