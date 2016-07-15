---

title: "Percona Xtrabackup: Compression and Encryption performance"
author: "Percona Lab"
generated on:July 15, 2016
output:
  html_document:
    self_contained: false 
    lib_dir: libs
<!--  md_document:
    variant: markdown_github -->

---


# Percona Xtrabackup 2.3.4 - Encryption and Compression performance 

## Setup

* Client and server on the same machine 
* Sysbench oltp workload running during all tests
* 21GB datadir (restored between tests)
* CPU: 48 logical CPU threads (Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz). 
* Memory: 120GB. 
* Disk: hdd (HGST HUH728080ALE600), ssd (Intel 3600 nvme) 
* Encryption (E) and Compression (C) tested with 1, 4, 8, 16 and 32 threads


## Backup duration 

Backup duration by type, number of threads, and disk type, faceted by
--parallel threads. The
horizontal line on each graph shows the duration for the baseline (non
compressed, non encrypted) backup. 

![plot of chunk global](figure/global-1.png)

## Impact on throughput

The following graphs show tps for sysbench oltp (16 threads, 10M rows
per table, 16 tables) while xtrabackup runs. Duration is not the same
for all graphs as backups don't all last the same, which is why the
faceting by --parallel threads produces graphs with varying width.  

In all cases, the experiment was run as follows :
- sysbench oltp runs for 10 seconds
- xtrabackup starts
- sysbench oltp continues for 20 seconds after xtrabackup completes

![plot of chunk tps](figure/tps-1.png)![plot of chunk tps](figure/tps-2.png)![plot of chunk tps](figure/tps-3.png)![plot of chunk tps](figure/tps-4.png)![plot of chunk tps](figure/tps-5.png)![plot of chunk tps](figure/tps-6.png)![plot of chunk tps](figure/tps-7.png)![plot of chunk tps](figure/tps-8.png)![plot of chunk tps](figure/tps-9.png)![plot of chunk tps](figure/tps-10.png)![plot of chunk tps](figure/tps-11.png)![plot of chunk tps](figure/tps-12.png)![plot of chunk tps](figure/tps-13.png)![plot of chunk tps](figure/tps-14.png)![plot of chunk tps](figure/tps-15.png)![plot of chunk tps](figure/tps-16.png)![plot of chunk tps](figure/tps-17.png)![plot of chunk tps](figure/tps-18.png)![plot of chunk tps](figure/tps-19.png)

```
## Error: Faceting variables must have at least one value
```

![plot of chunk tps](figure/tps-20.png)


## CPU usage

![plot of chunk cpu](figure/cpu-1.png)![plot of chunk cpu](figure/cpu-2.png)![plot of chunk cpu](figure/cpu-3.png)![plot of chunk cpu](figure/cpu-4.png)![plot of chunk cpu](figure/cpu-5.png)![plot of chunk cpu](figure/cpu-6.png)![plot of chunk cpu](figure/cpu-7.png)![plot of chunk cpu](figure/cpu-8.png)![plot of chunk cpu](figure/cpu-9.png)![plot of chunk cpu](figure/cpu-10.png)![plot of chunk cpu](figure/cpu-11.png)![plot of chunk cpu](figure/cpu-12.png)![plot of chunk cpu](figure/cpu-13.png)![plot of chunk cpu](figure/cpu-14.png)![plot of chunk cpu](figure/cpu-15.png)![plot of chunk cpu](figure/cpu-16.png)![plot of chunk cpu](figure/cpu-17.png)![plot of chunk cpu](figure/cpu-18.png)![plot of chunk cpu](figure/cpu-19.png)![plot of chunk cpu](figure/cpu-20.png)![plot of chunk cpu](figure/cpu-21.png)![plot of chunk cpu](figure/cpu-22.png)![plot of chunk cpu](figure/cpu-23.png)![plot of chunk cpu](figure/cpu-24.png)![plot of chunk cpu](figure/cpu-25.png)![plot of chunk cpu](figure/cpu-26.png)![plot of chunk cpu](figure/cpu-27.png)![plot of chunk cpu](figure/cpu-28.png)![plot of chunk cpu](figure/cpu-29.png)![plot of chunk cpu](figure/cpu-30.png)![plot of chunk cpu](figure/cpu-31.png)![plot of chunk cpu](figure/cpu-32.png)![plot of chunk cpu](figure/cpu-33.png)![plot of chunk cpu](figure/cpu-34.png)![plot of chunk cpu](figure/cpu-35.png)![plot of chunk cpu](figure/cpu-36.png)![plot of chunk cpu](figure/cpu-37.png)![plot of chunk cpu](figure/cpu-38.png)![plot of chunk cpu](figure/cpu-39.png)![plot of chunk cpu](figure/cpu-40.png)![plot of chunk cpu](figure/cpu-41.png)![plot of chunk cpu](figure/cpu-42.png)![plot of chunk cpu](figure/cpu-43.png)![plot of chunk cpu](figure/cpu-44.png)![plot of chunk cpu](figure/cpu-45.png)![plot of chunk cpu](figure/cpu-46.png)![plot of chunk cpu](figure/cpu-47.png)![plot of chunk cpu](figure/cpu-48.png)![plot of chunk cpu](figure/cpu-49.png)![plot of chunk cpu](figure/cpu-50.png)![plot of chunk cpu](figure/cpu-51.png)![plot of chunk cpu](figure/cpu-52.png)![plot of chunk cpu](figure/cpu-53.png)![plot of chunk cpu](figure/cpu-54.png)![plot of chunk cpu](figure/cpu-55.png)![plot of chunk cpu](figure/cpu-56.png)![plot of chunk cpu](figure/cpu-57.png)![plot of chunk cpu](figure/cpu-58.png)![plot of chunk cpu](figure/cpu-59.png)![plot of chunk cpu](figure/cpu-60.png)![plot of chunk cpu](figure/cpu-61.png)![plot of chunk cpu](figure/cpu-62.png)![plot of chunk cpu](figure/cpu-63.png)![plot of chunk cpu](figure/cpu-64.png)![plot of chunk cpu](figure/cpu-65.png)![plot of chunk cpu](figure/cpu-66.png)![plot of chunk cpu](figure/cpu-67.png)![plot of chunk cpu](figure/cpu-68.png)![plot of chunk cpu](figure/cpu-69.png)![plot of chunk cpu](figure/cpu-70.png)![plot of chunk cpu](figure/cpu-71.png)![plot of chunk cpu](figure/cpu-72.png)![plot of chunk cpu](figure/cpu-73.png)![plot of chunk cpu](figure/cpu-74.png)![plot of chunk cpu](figure/cpu-75.png)![plot of chunk cpu](figure/cpu-76.png)![plot of chunk cpu](figure/cpu-77.png)![plot of chunk cpu](figure/cpu-78.png)![plot of chunk cpu](figure/cpu-79.png)![plot of chunk cpu](figure/cpu-80.png)![plot of chunk cpu](figure/cpu-81.png)![plot of chunk cpu](figure/cpu-82.png)![plot of chunk cpu](figure/cpu-83.png)![plot of chunk cpu](figure/cpu-84.png)![plot of chunk cpu](figure/cpu-85.png)![plot of chunk cpu](figure/cpu-86.png)![plot of chunk cpu](figure/cpu-87.png)![plot of chunk cpu](figure/cpu-88.png)![plot of chunk cpu](figure/cpu-89.png)![plot of chunk cpu](figure/cpu-90.png)![plot of chunk cpu](figure/cpu-91.png)![plot of chunk cpu](figure/cpu-92.png)![plot of chunk cpu](figure/cpu-93.png)![plot of chunk cpu](figure/cpu-94.png)![plot of chunk cpu](figure/cpu-95.png)![plot of chunk cpu](figure/cpu-96.png)![plot of chunk cpu](figure/cpu-97.png)![plot of chunk cpu](figure/cpu-98.png)![plot of chunk cpu](figure/cpu-99.png)![plot of chunk cpu](figure/cpu-100.png)![plot of chunk cpu](figure/cpu-101.png)![plot of chunk cpu](figure/cpu-102.png)![plot of chunk cpu](figure/cpu-103.png)![plot of chunk cpu](figure/cpu-104.png)![plot of chunk cpu](figure/cpu-105.png)![plot of chunk cpu](figure/cpu-106.png)![plot of chunk cpu](figure/cpu-107.png)![plot of chunk cpu](figure/cpu-108.png)![plot of chunk cpu](figure/cpu-109.png)![plot of chunk cpu](figure/cpu-110.png)![plot of chunk cpu](figure/cpu-111.png)![plot of chunk cpu](figure/cpu-112.png)![plot of chunk cpu](figure/cpu-113.png)![plot of chunk cpu](figure/cpu-114.png)![plot of chunk cpu](figure/cpu-115.png)![plot of chunk cpu](figure/cpu-116.png)![plot of chunk cpu](figure/cpu-117.png)![plot of chunk cpu](figure/cpu-118.png)![plot of chunk cpu](figure/cpu-119.png)![plot of chunk cpu](figure/cpu-120.png)![plot of chunk cpu](figure/cpu-121.png)![plot of chunk cpu](figure/cpu-122.png)![plot of chunk cpu](figure/cpu-123.png)![plot of chunk cpu](figure/cpu-124.png)![plot of chunk cpu](figure/cpu-125.png)![plot of chunk cpu](figure/cpu-126.png)![plot of chunk cpu](figure/cpu-127.png)![plot of chunk cpu](figure/cpu-128.png)![plot of chunk cpu](figure/cpu-129.png)![plot of chunk cpu](figure/cpu-130.png)![plot of chunk cpu](figure/cpu-131.png)![plot of chunk cpu](figure/cpu-132.png)![plot of chunk cpu](figure/cpu-133.png)![plot of chunk cpu](figure/cpu-134.png)![plot of chunk cpu](figure/cpu-135.png)![plot of chunk cpu](figure/cpu-136.png)![plot of chunk cpu](figure/cpu-137.png)![plot of chunk cpu](figure/cpu-138.png)![plot of chunk cpu](figure/cpu-139.png)![plot of chunk cpu](figure/cpu-140.png)
