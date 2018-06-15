# !/bin/bash

mongo --host 115.145.173.215:27017 | tee profile.txt
use ycsb;
db.system.profile.find({millis: {$gt:100}})
