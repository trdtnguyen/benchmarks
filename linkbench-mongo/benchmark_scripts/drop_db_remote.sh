# !/bin/bash

mongo --host 192.168.1.25:27017 ycsb --eval "db.dropDatabase()"
mongo --host 192.168.1.26:27017 ycsb --eval "db.dropDatabase()"
mongo --host 192.168.1.27:27017 ycsb --eval "db.dropDatabase()"

