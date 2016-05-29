---

title: "Percona Xtrabackup: Compression and Encryption performance"
author: "Percona Lab"
generated on:May 28, 2016
output:
  md_document:
    variant: markdown_github

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

![plot of chunk tps](figure/tps-1.png)![plot of chunk tps](figure/tps-2.png)![plot of chunk tps](figure/tps-3.png)![plot of chunk tps](figure/tps-4.png)![plot of chunk tps](figure/tps-5.png)![plot of chunk tps](figure/tps-6.png)![plot of chunk tps](figure/tps-7.png)![plot of chunk tps](figure/tps-8.png)![plot of chunk tps](figure/tps-9.png)![plot of chunk tps](figure/tps-10.png)


## CPU usage

![plot of chunk cpu](figure/cpu-1.png)![plot of chunk cpu](figure/cpu-2.png)![plot of chunk cpu](figure/cpu-3.png)![plot of chunk cpu](figure/cpu-4.png)![plot of chunk cpu](figure/cpu-5.png)![plot of chunk cpu](figure/cpu-6.png)![plot of chunk cpu](figure/cpu-7.png)![plot of chunk cpu](figure/cpu-8.png)![plot of chunk cpu](figure/cpu-9.png)![plot of chunk cpu](figure/cpu-10.png)![plot of chunk cpu](figure/cpu-11.png)![plot of chunk cpu](figure/cpu-12.png)![plot of chunk cpu](figure/cpu-13.png)![plot of chunk cpu](figure/cpu-14.png)![plot of chunk cpu](figure/cpu-15.png)![plot of chunk cpu](figure/cpu-16.png)![plot of chunk cpu](figure/cpu-17.png)![plot of chunk cpu](figure/cpu-18.png)![plot of chunk cpu](figure/cpu-19.png)![plot of chunk cpu](figure/cpu-20.png)![plot of chunk cpu](figure/cpu-21.png)![plot of chunk cpu](figure/cpu-22.png)![plot of chunk cpu](figure/cpu-23.png)![plot of chunk cpu](figure/cpu-24.png)![plot of chunk cpu](figure/cpu-25.png)![plot of chunk cpu](figure/cpu-26.png)![plot of chunk cpu](figure/cpu-27.png)![plot of chunk cpu](figure/cpu-28.png)![plot of chunk cpu](figure/cpu-29.png)![plot of chunk cpu](figure/cpu-30.png)![plot of chunk cpu](figure/cpu-31.png)![plot of chunk cpu](figure/cpu-32.png)![plot of chunk cpu](figure/cpu-33.png)![plot of chunk cpu](figure/cpu-34.png)![plot of chunk cpu](figure/cpu-35.png)![plot of chunk cpu](figure/cpu-36.png)![plot of chunk cpu](figure/cpu-37.png)![plot of chunk cpu](figure/cpu-38.png)![plot of chunk cpu](figure/cpu-39.png)![plot of chunk cpu](figure/cpu-40.png)
