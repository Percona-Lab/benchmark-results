sync
sysctl -q -w vm.drop_caches=3
echo 3 > /proc/sys/vm/drop_caches
ulimit -n 1000000
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1 numactl --interleave=all bin/mysqld --defaults-file=/etc/my.ps.cnf --datadir=/data/sam/rocks/ --default-tmp-storage-engine=MyISAM --rocksdb --skip-innodb --default-storage-engine=RocksDB --user=root --rocksdb_block_cache_size=100G
