---

title: "Percona Server for MongoDB: CPU and I/O scalability for
WiredTiger and RocksDB"
author: "Percona Lab"
generated on:June 03, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.4-1.rc2 - CPU and I/O scalability 

## Configuration reference

### rocks0

storage.rocksdb.configString:
"bytes_per_sync=16m;max_background_flushes=3;max_background_compactions=12;max_write_buffer_number=4;max_bytes_for_level_base=1500m;target_file_size_base=200m;level0_slowdown_writes_trigger=12;write_buffer_size=400m;compression_per_level=kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression:kSnappyCompression;optimize_filters_for_hits=true"

### wt0

--syncdelay=900 --wiredTigerJournalCompressor=none --wiredTigerCacheSizeGB=$cache_size

### wt1

--syncdelay=900 --wiredTigerJournalCompressor=zlib --wiredTigerCacheSizeGB=$cache_size

### wt2

--syncdelay=900 --wiredTigerJournalCompressor=snappy --wiredTigerCacheSizeGB=$cache_size

## Memory Scalability tests

The memory scalability tests were all done using 100 client threads.
All graphs faceted by memory and configuration. 

![plot of chunk mem](figure/mem-1.png)![plot of chunk mem](figure/mem-2.png)

## Throughput detail 

### Memory scalability

![plot of chunk tps_ms](figure/tps_ms-1.png)![plot of chunk tps_ms](figure/tps_ms-2.png)![plot of chunk tps_ms](figure/tps_ms-3.png)![plot of chunk tps_ms](figure/tps_ms-4.png)![plot of chunk tps_ms](figure/tps_ms-5.png)![plot of chunk tps_ms](figure/tps_ms-6.png)![plot of chunk tps_ms](figure/tps_ms-7.png)![plot of chunk tps_ms](figure/tps_ms-8.png)![plot of chunk tps_ms](figure/tps_ms-9.png)![plot of chunk tps_ms](figure/tps_ms-10.png)![plot of chunk tps_ms](figure/tps_ms-11.png)![plot of chunk tps_ms](figure/tps_ms-12.png)![plot of chunk tps_ms](figure/tps_ms-13.png)![plot of chunk tps_ms](figure/tps_ms-14.png)![plot of chunk tps_ms](figure/tps_ms-15.png)![plot of chunk tps_ms](figure/tps_ms-16.png)![plot of chunk tps_ms](figure/tps_ms-17.png)![plot of chunk tps_ms](figure/tps_ms-18.png)![plot of chunk tps_ms](figure/tps_ms-19.png)![plot of chunk tps_ms](figure/tps_ms-20.png)![plot of chunk tps_ms](figure/tps_ms-21.png)![plot of chunk tps_ms](figure/tps_ms-22.png)![plot of chunk tps_ms](figure/tps_ms-23.png)![plot of chunk tps_ms](figure/tps_ms-24.png)![plot of chunk tps_ms](figure/tps_ms-25.png)![plot of chunk tps_ms](figure/tps_ms-26.png)![plot of chunk tps_ms](figure/tps_ms-27.png)![plot of chunk tps_ms](figure/tps_ms-28.png)![plot of chunk tps_ms](figure/tps_ms-29.png)![plot of chunk tps_ms](figure/tps_ms-30.png)![plot of chunk tps_ms](figure/tps_ms-31.png)![plot of chunk tps_ms](figure/tps_ms-32.png)![plot of chunk tps_ms](figure/tps_ms-33.png)![plot of chunk tps_ms](figure/tps_ms-34.png)![plot of chunk tps_ms](figure/tps_ms-35.png)![plot of chunk tps_ms](figure/tps_ms-36.png)![plot of chunk tps_ms](figure/tps_ms-37.png)![plot of chunk tps_ms](figure/tps_ms-38.png)![plot of chunk tps_ms](figure/tps_ms-39.png)![plot of chunk tps_ms](figure/tps_ms-40.png)![plot of chunk tps_ms](figure/tps_ms-41.png)![plot of chunk tps_ms](figure/tps_ms-42.png)![plot of chunk tps_ms](figure/tps_ms-43.png)![plot of chunk tps_ms](figure/tps_ms-44.png)![plot of chunk tps_ms](figure/tps_ms-45.png)![plot of chunk tps_ms](figure/tps_ms-46.png)![plot of chunk tps_ms](figure/tps_ms-47.png)![plot of chunk tps_ms](figure/tps_ms-48.png)![plot of chunk tps_ms](figure/tps_ms-49.png)![plot of chunk tps_ms](figure/tps_ms-50.png)![plot of chunk tps_ms](figure/tps_ms-51.png)![plot of chunk tps_ms](figure/tps_ms-52.png)![plot of chunk tps_ms](figure/tps_ms-53.png)![plot of chunk tps_ms](figure/tps_ms-54.png)![plot of chunk tps_ms](figure/tps_ms-55.png)![plot of chunk tps_ms](figure/tps_ms-56.png)![plot of chunk tps_ms](figure/tps_ms-57.png)![plot of chunk tps_ms](figure/tps_ms-58.png)![plot of chunk tps_ms](figure/tps_ms-59.png)![plot of chunk tps_ms](figure/tps_ms-60.png)![plot of chunk tps_ms](figure/tps_ms-61.png)![plot of chunk tps_ms](figure/tps_ms-62.png)![plot of chunk tps_ms](figure/tps_ms-63.png)![plot of chunk tps_ms](figure/tps_ms-64.png)![plot of chunk tps_ms](figure/tps_ms-65.png)![plot of chunk tps_ms](figure/tps_ms-66.png)![plot of chunk tps_ms](figure/tps_ms-67.png)![plot of chunk tps_ms](figure/tps_ms-68.png)![plot of chunk tps_ms](figure/tps_ms-69.png)![plot of chunk tps_ms](figure/tps_ms-70.png)![plot of chunk tps_ms](figure/tps_ms-71.png)![plot of chunk tps_ms](figure/tps_ms-72.png)![plot of chunk tps_ms](figure/tps_ms-73.png)![plot of chunk tps_ms](figure/tps_ms-74.png)![plot of chunk tps_ms](figure/tps_ms-75.png)![plot of chunk tps_ms](figure/tps_ms-76.png)![plot of chunk tps_ms](figure/tps_ms-77.png)![plot of chunk tps_ms](figure/tps_ms-78.png)![plot of chunk tps_ms](figure/tps_ms-79.png)![plot of chunk tps_ms](figure/tps_ms-80.png)

