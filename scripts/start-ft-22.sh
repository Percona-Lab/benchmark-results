#!/bin/bash -x

cache_size=$1; shift
datadir=/data/sam/PERF-22/
[ -n "$DATADIR" ] && datadir=$DATADIR

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1 
echo "starting from $MONGO_PATH"
numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$datadir \
  --storageEngine=PerconaFT \
  --PerconaFTEngineCacheSize=$((cache_size*1024*1024*1024)) \
  --syncdelay=900 \
  --PerconaFTIndexFanout=16 \
  --PerconaFTCollectionFanout=16 \
  --PerconaFTIndexCompression=snappy \
  --PerconaFTCollectionCompression=snappy \
  --PerconaFTIndexReadPageSize=16384 \
  --PerconaFTCollectionReadPageSize=16384 # \
#  --auth

