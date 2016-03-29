#!/bin/bash

numactl --interleave=all ./percona-server-mongodb-3.0.8-1.2/bin/mongod \
  $* \
  --dbpath=/mnt/i3600/PERF-15/ft \
  --storageEngine=PerconaFT \
  --PerconaFTEngineCacheSize=$((64*1024*1024*1024)) \
  --syncdelay=900 \
  --PerconaFTIndexFanout=16 \
  --PerconaFTCollectionFanout=128 \
  --PerconaFTIndexCompression=quicklz \
  --PerconaFTCollectionCompression=quicklz \
  --PerconaFTIndexReadPageSize=16384 \
  --PerconaFTCollectionReadPageSize=16384 # \
#  --auth

