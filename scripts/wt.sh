#!/bin/bash
[ -z "$VERSION" ] && VERSION=3.0.8-1.2

numactl --interleave=all ./percona-server-mongodb-$VERSION/bin/mongod \
  $* \
  --dbpath=/mnt/i3600/PERF-15/wt \
  --storageEngine=wiredTiger \
  --config ./wt.config #\
#  --auth
