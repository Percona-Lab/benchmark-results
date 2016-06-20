---

title: "Percona Server for MongoDB: CPU and I/O scalability for
WiredTiger and RocksDB"
author: "Percona Lab"
generated on:June 20, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.4-1.rc2 - CPU and I/O scalability 

## Setup

* Setup information pending 

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

## CPU Scalability tests 

![plot of chunk cpu](figure/cpu-1.png)![plot of chunk cpu](figure/cpu-2.png)![plot of chunk cpu](figure/cpu-3.png)![plot of chunk cpu](figure/cpu-4.png)

## Memory Scalability tests

The memory scalability tests were all done using 100 client threads.
All graphs faceted by memory and configuration. 

![plot of chunk mem](figure/mem-1.png)

```
## Error: Faceting variables must have at least one value
```

![plot of chunk mem](figure/mem-2.png)

## Throughput detail 

### Thread scalability 

![plot of chunk tps_ts](figure/tps_ts-1.png)![plot of chunk tps_ts](figure/tps_ts-2.png)![plot of chunk tps_ts](figure/tps_ts-3.png)![plot of chunk tps_ts](figure/tps_ts-4.png)![plot of chunk tps_ts](figure/tps_ts-5.png)![plot of chunk tps_ts](figure/tps_ts-6.png)![plot of chunk tps_ts](figure/tps_ts-7.png)![plot of chunk tps_ts](figure/tps_ts-8.png)![plot of chunk tps_ts](figure/tps_ts-9.png)![plot of chunk tps_ts](figure/tps_ts-10.png)![plot of chunk tps_ts](figure/tps_ts-11.png)![plot of chunk tps_ts](figure/tps_ts-12.png)![plot of chunk tps_ts](figure/tps_ts-13.png)![plot of chunk tps_ts](figure/tps_ts-14.png)![plot of chunk tps_ts](figure/tps_ts-15.png)![plot of chunk tps_ts](figure/tps_ts-16.png)![plot of chunk tps_ts](figure/tps_ts-17.png)![plot of chunk tps_ts](figure/tps_ts-18.png)![plot of chunk tps_ts](figure/tps_ts-19.png)![plot of chunk tps_ts](figure/tps_ts-20.png)![plot of chunk tps_ts](figure/tps_ts-21.png)![plot of chunk tps_ts](figure/tps_ts-22.png)![plot of chunk tps_ts](figure/tps_ts-23.png)![plot of chunk tps_ts](figure/tps_ts-24.png)![plot of chunk tps_ts](figure/tps_ts-25.png)![plot of chunk tps_ts](figure/tps_ts-26.png)![plot of chunk tps_ts](figure/tps_ts-27.png)![plot of chunk tps_ts](figure/tps_ts-28.png)![plot of chunk tps_ts](figure/tps_ts-29.png)![plot of chunk tps_ts](figure/tps_ts-30.png)![plot of chunk tps_ts](figure/tps_ts-31.png)![plot of chunk tps_ts](figure/tps_ts-32.png)![plot of chunk tps_ts](figure/tps_ts-33.png)![plot of chunk tps_ts](figure/tps_ts-34.png)![plot of chunk tps_ts](figure/tps_ts-35.png)![plot of chunk tps_ts](figure/tps_ts-36.png)![plot of chunk tps_ts](figure/tps_ts-37.png)![plot of chunk tps_ts](figure/tps_ts-38.png)![plot of chunk tps_ts](figure/tps_ts-39.png)![plot of chunk tps_ts](figure/tps_ts-40.png)![plot of chunk tps_ts](figure/tps_ts-41.png)![plot of chunk tps_ts](figure/tps_ts-42.png)![plot of chunk tps_ts](figure/tps_ts-43.png)![plot of chunk tps_ts](figure/tps_ts-44.png)![plot of chunk tps_ts](figure/tps_ts-45.png)![plot of chunk tps_ts](figure/tps_ts-46.png)![plot of chunk tps_ts](figure/tps_ts-47.png)![plot of chunk tps_ts](figure/tps_ts-48.png)![plot of chunk tps_ts](figure/tps_ts-49.png)![plot of chunk tps_ts](figure/tps_ts-50.png)![plot of chunk tps_ts](figure/tps_ts-51.png)![plot of chunk tps_ts](figure/tps_ts-52.png)![plot of chunk tps_ts](figure/tps_ts-53.png)![plot of chunk tps_ts](figure/tps_ts-54.png)![plot of chunk tps_ts](figure/tps_ts-55.png)![plot of chunk tps_ts](figure/tps_ts-56.png)![plot of chunk tps_ts](figure/tps_ts-57.png)![plot of chunk tps_ts](figure/tps_ts-58.png)![plot of chunk tps_ts](figure/tps_ts-59.png)![plot of chunk tps_ts](figure/tps_ts-60.png)![plot of chunk tps_ts](figure/tps_ts-61.png)![plot of chunk tps_ts](figure/tps_ts-62.png)![plot of chunk tps_ts](figure/tps_ts-63.png)![plot of chunk tps_ts](figure/tps_ts-64.png)![plot of chunk tps_ts](figure/tps_ts-65.png)![plot of chunk tps_ts](figure/tps_ts-66.png)![plot of chunk tps_ts](figure/tps_ts-67.png)![plot of chunk tps_ts](figure/tps_ts-68.png)![plot of chunk tps_ts](figure/tps_ts-69.png)![plot of chunk tps_ts](figure/tps_ts-70.png)![plot of chunk tps_ts](figure/tps_ts-71.png)![plot of chunk tps_ts](figure/tps_ts-72.png)

### Memory scalability

![plot of chunk tps_ms](figure/tps_ms-1.png)![plot of chunk tps_ms](figure/tps_ms-2.png)![plot of chunk tps_ms](figure/tps_ms-3.png)![plot of chunk tps_ms](figure/tps_ms-4.png)![plot of chunk tps_ms](figure/tps_ms-5.png)![plot of chunk tps_ms](figure/tps_ms-6.png)![plot of chunk tps_ms](figure/tps_ms-7.png)![plot of chunk tps_ms](figure/tps_ms-8.png)![plot of chunk tps_ms](figure/tps_ms-9.png)![plot of chunk tps_ms](figure/tps_ms-10.png)![plot of chunk tps_ms](figure/tps_ms-11.png)

```
## Error: Faceting variables must have at least one value
```

![plot of chunk tps_ms](figure/tps_ms-12.png)

