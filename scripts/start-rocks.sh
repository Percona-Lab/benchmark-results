#!/bin/bash
cache_size=$1
shift
cat <<EOF>rocks.config
#setParameter:
storage.rocksdb.configString: "bytes_per_sync=16m;max_background_flushes=3;max_background_compactions=12;max_write_buffer_number=4;max_bytes_for_level_base=1500m;target_file_size_base=200m;level0_slowdown_writes_trigger=12;write_buffer_size=400m;compression_per_level=kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression;optimize_filters_for_hits=true"

EOF

datadir=/data/sam/mongod
[ -n "$DATADIR" ] && datadir=$DATADIR

export MONGO_PATH=mongo/percona-server-mongodb-3.2.7-1.1
[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1
ulimit -n 4096
numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$datadir \
  --storageEngine=rocksdb \
  --rocksdbCacheSizeGB=$cache_size \
  --config ./rocks.config # \
#  --auth

