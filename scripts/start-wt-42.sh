#!/bin/bash

cache_size=$1; shift

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1
[ -z "$DBPATH" ] && echo "DBPATH not set, exiting">&2 && exit 1
port=27017
[ -n "$MONGO_PORT" ] && port=$MONGO_PORT


numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$DBPATH \
  --storageEngine=wiredTiger \
  --wiredTigerCacheSizeGB=$cache_size \
  --port=$port
