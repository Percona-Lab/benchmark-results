#!/bin/bash

cat <<EOF>rocks.config
#setParameter:
storage.rocksdb.configString: "bytes_per_sync=16m;max_background_flushes=3;max_background_compactions=12;max_write_buffer_number=4;max_bytes_for_level_base=1500m;target_file_size_base=200m;level0_slowdown_writes_trigger=12;write_buffer_size=400m;compression_per_level=kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression;optimize_filters_for_hits=true"

EOF

numactl --interleave=all ./percona-server-mongodb-3.0.8-1.2/bin/mongod \
  $* \
  --dbpath=/mnt/i3600/PERF-15/rocks \
  --storageEngine=rocksdb \
  --config ./rocks.config # \
#  --auth

