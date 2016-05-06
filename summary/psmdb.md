---

title: "Percona Server for MongoDB: Storage Engine comparison"
author: "Percona Lab"
generated on:May 06, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.0-1.0 - data that does not fit in RAM 

## Setup

* Client and server on different (equal) machines.
* Client sofwware is sysbench (https://github.com/Percona-Lab/sysbench/tree/dev-mongodb-support).
* CPU: 56 logical CPU threads (Intel(R) Xeon(R) CPU E5-2683 v3 @ 2.00GHz).
* 20GB RAM (limited via cgroup).
* sysbench with mongodb support, 16 collections x 60M documents (~50G uncompressed), uniform and pareto distributions. 

## Throughput per threads and workload

![plot of chunk global](figure/global-1.png)![plot of chunk global](figure/global-2.png)![plot of chunk global](figure/global-3.png)![plot of chunk global](figure/global-4.png)

## Throughput per threads and workload, summary for engine

![plot of chunk engines](figure/engines-1.png)![plot of chunk engines](figure/engines-2.png)![plot of chunk engines](figure/engines-3.png)

## Throughput per threads and workload, details. 
## Throughput per threads and workload, PerconaFT

![plot of chunk ft](figure/ft-1.png)![plot of chunk ft](figure/ft-2.png)![plot of chunk ft](figure/ft-3.png)![plot of chunk ft](figure/ft-4.png)![plot of chunk ft](figure/ft-5.png)![plot of chunk ft](figure/ft-6.png)![plot of chunk ft](figure/ft-7.png)

## Throughput per threads and workload, WiredTiger

![plot of chunk wt](figure/wt-1.png)![plot of chunk wt](figure/wt-2.png)![plot of chunk wt](figure/wt-3.png)![plot of chunk wt](figure/wt-4.png)![plot of chunk wt](figure/wt-5.png)![plot of chunk wt](figure/wt-6.png)![plot of chunk wt](figure/wt-7.png)

## Throughput per threads and workload, RocksDB

![plot of chunk rocks](figure/rocks-1.png)![plot of chunk rocks](figure/rocks-2.png)![plot of chunk rocks](figure/rocks-3.png)![plot of chunk rocks](figure/rocks-4.png)![plot of chunk rocks](figure/rocks-5.png)![plot of chunk rocks](figure/rocks-6.png)![plot of chunk rocks](figure/rocks-7.png)
