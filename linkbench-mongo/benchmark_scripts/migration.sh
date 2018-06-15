# !/bin/sh
#call this after finish insert data
#seperate data dir and journal dir and the others in seperate device
SOURCE_DIR=/ssd1
DEST_DIR=/hdd1

DATA_DIR=/ssd1
INDEX_DIR=/ssd2
JOURNAL_DIR=/ssd3

echo "move data from ${SOURCE_DIR} to ${DATA_DIR}, journal from ${SOURCE_DIR} to ${JOURNAL_DIR}, run dir is ${DEST_DIR}" 
rm -rf ${DATA_DIR}/collection
rm -rf ${INDEX_DIR}/index
rm -rf ${JOURNAL_DIR}/journal
rm -rf ${DEST_DIR}/data

mv ${SOURCE_DIR}/data/db/ycsb/collection ${DATA_DIR}/
mv ${SOURCE_DIR}/data/db/ycsb/index ${INDEX_DIR}/
mv ${SOURCE_DIR}/data/db/journal ${JOURNAL_DIR}/
mv ${SOURCE_DIR}/data/ ${DEST_DIR}/

ln -s ${DATA_DIR}/collection ${DEST_DIR}/data/db/ycsb/
ln -s ${INDEX_DIR}/index ${DEST_DIR}/data/db/ycsb/
ln -s ${JOURNAL_DIR}/journal ${DEST_DIR}/data/db/

