#!/bin/bash

cat <<EOF>wt.config
# setParameter:
#     storage.wiredTiger.collectionConfig.configString:"type=lsm"
#     storage.wiredTiger.indexConfig.configString:"type=lsm"
EOF

numactl --interleave=all ./percona-server-mongodb-3.0.8-1.2/bin/mongod \
  $* \
  --dbpath=/mnt/i3600/PERF-15/wt \
  --storageEngine=wiredTiger \
  --config ./wt.config #\
#  --auth

