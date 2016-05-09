#!/bin/bash
shift
cat <<EOF>rocks.config
#setParameter:
storage.rocksdb.configString: "bytes_per_sync=16m;max_background_flushes=3;max_background_compactions=12;max_write_buffer_number=4;max_bytes_for_level_base=1500m;target_file_size_base=200m;level0_slowdown_writes_trigger=12;write_buffer_size=400m;compression_per_level=kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression;optimize_filters_for_hits=true"

EOF

[ -z "$MONGO_PATH" ] && echo "MONGO_PATH not set, exiting">&2 && exit 1
[ -z "$DBPATH" ] && echo "DBPATH not set, exiting">&2 && exit 1

numactl --interleave=all ./${MONGO_PATH}/bin/mongod \
  $* \
  --dbpath=$DBPATH \
  --storageEngine=rocksdb \
  --config ./rocks.config # \
#  --auth

