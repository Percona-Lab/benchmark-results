#!/bin/bash

cache_size=$1; shift

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1
[ -z "$DBPATH" ] && echo "DBPATH not set, exiting">&2 && exit 1

numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$DBPATH \
  --storageEngine=inMemory \
  --inMemorySizeGB=$cache_size
