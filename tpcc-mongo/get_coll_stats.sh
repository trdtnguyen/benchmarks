# !/bin/bash

#usage ./get_coll_stats.sh <outdir>

outdir=$1

source const.sh
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.serverStatus())' > ${outdir}/${TPCC_SERVER_STATUS_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.CUSTOMER.stats({indexDetails : true}))' > ${outdir}/${TPCC_CUSTOMER_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.DISTRICT.stats({indexDetails : true}))' > ${outdir}/${TPCC_DISTRICT_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.ITEM.stats({indexDetails : true}))' > ${outdir}/${TPCC_ITEM_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.NEW_ORDER.stats({indexDetails : true}))' > ${outdir}/${TPCC_NEW_ORDER_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.STOCK.stats({indexDetails : true}))' > ${outdir}/${TPCC_STOCK_RUN}
${MONGO_HOME}/mongo --host=${HOST} --quiet $TPCC_DB_NAME --eval 'printjson(db.WAREHOUSE.stats({indexDetails : true}))' > ${outdir}/${TPCC_WAREHOUSE_RUN}
