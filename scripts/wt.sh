#!/bin/bash

numactl --interleave=all ./percona-server-mongodb-3.0.8-1.2/bin/mongod \
  $* \
  --dbpath=/mnt/i3600/PERF-15/wt \
  --storageEngine=wiredTiger \
  --wiredTigerCacheSizeGB=64
#  --config ./wt.config #\
#  --auth

