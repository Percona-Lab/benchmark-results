#!/bin/bash

awk -F "," '{print $1 "," $2 "," $3 "," $7 "," $8 "," $9 "," $10 "," $11}' < ../alldata.csv > /tmp/alldata.csv.$$

cat <<EOF | mysql 

drop database if exists perf39;
create database perf39;
use perf39;
create table alldata (
  \`test\` enum('gt','standard') not null,
  \`threads\` smallint unsigned not null, 
  \`active_schemas\` smallint unsigned not null,
  \`ts\` smallint unsigned not null, 
  \`writes\` double not null,
  \`reads\` double not null,
  \`response_time\` double not null,
  \`tps\` smallint unsigned not null
) engine=innodb;

load data infile "/tmp/alldata.csv.$$" into table alldata fields terminated by ',' 

EOF


rm -f /tmp/alldata.csv.$$
