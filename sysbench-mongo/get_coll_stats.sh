# !/bin/bash

#usage ./get_coll_stats.sh <outdir>

outdir=$1

source const.sh
${MONGO_HOME}/mongo --host=${HOST} --quiet $DB_NAME --eval 'printjson(db.serverStatus())' > ${outdir}/${SERVER_STATUS_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $DB_NAME --eval 'printjson(db.sbtest1.stats({indexDetails : true}))' > ${outdir}/${SBTEST_RUN}
