#!/bin/bash

cache_size=$1; shift

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1

datadir=/data/sam/PERF-22/
[ -n "$DATADIR" ] && datadir=$DATADIR

numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$datadir \
  --storageEngine=wiredTiger \
  --wiredTigerCacheSizeGB=$cache_size

