---

title: "Percona Server for MongoDB: Range Queries performance on RocksDB and WiredTiger"
author: "Percona Lab"
generated on:May 14, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.0-1.0 - Range queries performance 

## Setup

* Client and server on the same machine 
* Client sofwware is sysbench (https://github.com/Percona-Lab/sysbench/tree/dev-mongodb-support).
* CPU: 48 logical CPU threads (Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz). 
* Memory: 120GB or 20GB (the latter limited via cgroup).
* Disk: hdd (HGST HUH728080ALE600), slowssd (Crucial CT960M500SSD1), fastssd (Intel 3600 nvme) 
* sysbench with mongodb support, 16 collections x 10M or 60M documents (~35GB or ~200G uncompressed), uniform and pareto distributions. 
* Workloads are labeled as:
- cpubound (10M documents per collection, fastssd storage)
- iobound (60M documents per collection, fastssd and slowssd storage, 120GB RAM)
- iobound_heavy (same as previous, but with 20GB RAM)

## Throughput per threads and workload

![plot of chunk global](figure/global-1.png)![plot of chunk global](figure/global-2.png)![plot of chunk global](figure/global-3.png)![plot of chunk global](figure/global-4.png)![plot of chunk global](figure/global-5.png)![plot of chunk global](figure/global-6.png)

## Throughput per threads and workload, summary per engine


```
## Error: Faceting variables must have at least one value
```

```
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
## 
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
```

![plot of chunk engines](figure/engines-1.png)

```
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
```

![plot of chunk engines](figure/engines-2.png)

```
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
```

![plot of chunk engines](figure/engines-3.png)

```
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
```

![plot of chunk engines](figure/engines-4.png)

```
## The following objects are masked from data_wt_10000:
## 
##     disk, distribution, engine, range_size, reads, response_time,
##     size, threads, tps, ts, user_provided_threads, workload,
##     writes
```

![plot of chunk engines](figure/engines-5.png)![plot of chunk engines](figure/engines-6.png)

## Throughput per threads and workload, details. 
## Throughput per threads and workload, WiredTiger


```
## Error: Faceting variables must have at least one value
```

![plot of chunk wt](figure/wt-1.png)

## Throughput per threads and workload, RocksDB

![plot of chunk rocks](figure/rocks-1.png)![plot of chunk rocks](figure/rocks-2.png)![plot of chunk rocks](figure/rocks-3.png)![plot of chunk rocks](figure/rocks-4.png)![plot of chunk rocks](figure/rocks-5.png)![plot of chunk rocks](figure/rocks-6.png)![plot of chunk rocks](figure/rocks-7.png)
