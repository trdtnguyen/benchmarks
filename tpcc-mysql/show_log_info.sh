#!/bin/bash
source const.sh
#show log info from the InnoDB

mysql -u vldb -e "show engine innodb status \g" > dummy.txt && sed -i -e 's|\\n|\n|g' dummy.txt && cat dummy.txt | grep "log" && rm dummy.txt
