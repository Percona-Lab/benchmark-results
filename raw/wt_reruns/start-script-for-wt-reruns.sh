#!/bin/bash

cache_size=$1; shift

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1

numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=/mnt/storage/PERF-28/wt \
  --storageEngine=wiredTiger \
  --syncdelay=900 \
  --wiredTigerJournalCompressor=none \
  --wiredTigerCacheSizeGB=$cache_size
