#!/bin/bash
export MONGO_PATH=mongo/percona-server-mongodb-3.2.7-1.1
cache_size=$1; shift

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1

datadir=/data/sam/mongod/
[ -n "$DATADIR" ] && datadir=$DATADIR

ulimit -n 4096

numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$datadir \
  --storageEngine=wiredTiger \
  --wiredTigerCacheSizeGB=$cache_size

