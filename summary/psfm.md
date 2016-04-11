---

title: "Percona Server for MongoDB: Storage Engine comparison"
author: "Percona Lab"
generated on:April 10, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.0-1.0 - data set that fits in RAM 

## Setup

* Client (sysbench) and server are on the same machine
* CPU: 48 logical CPU threads servers Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
* 128GB RAM (64GB storage engine cache)
* sysbench with mongodb support, 16 collections x 2M documents (~6GB compressed), uniform distribution. 

## Throughput per threads and workload

![plot of chunk summary](figure/summary-1.png)![plot of chunk summary](figure/summary-2.png)

## Throughput per threads and workload, summary for each engine

![plot of chunk engines](figure/engines-1.png)![plot of chunk engines](figure/engines-2.png)![plot of chunk engines](figure/engines-3.png)

## Throughput per threads and workload, details. 

![plot of chunk ft](figure/ft-1.png)![plot of chunk ft](figure/ft-2.png)![plot of chunk ft](figure/ft-3.png)![plot of chunk ft](figure/ft-4.png)![plot of chunk ft](figure/ft-5.png)![plot of chunk ft](figure/ft-6.png)![plot of chunk ft](figure/ft-7.png)![plot of chunk ft](figure/ft-8.png)![plot of chunk ft](figure/ft-9.png)![plot of chunk ft](figure/ft-10.png)![plot of chunk ft](figure/ft-11.png)![plot of chunk ft](figure/ft-12.png)![plot of chunk ft](figure/ft-13.png)

## Throughput per threads and workload, WiredTiger

![plot of chunk wt](figure/wt-1.png)![plot of chunk wt](figure/wt-2.png)![plot of chunk wt](figure/wt-3.png)![plot of chunk wt](figure/wt-4.png)![plot of chunk wt](figure/wt-5.png)![plot of chunk wt](figure/wt-6.png)![plot of chunk wt](figure/wt-7.png)![plot of chunk wt](figure/wt-8.png)![plot of chunk wt](figure/wt-9.png)![plot of chunk wt](figure/wt-10.png)![plot of chunk wt](figure/wt-11.png)![plot of chunk wt](figure/wt-12.png)![plot of chunk wt](figure/wt-13.png)

## Throughput per threads and workload, RocksDB

![plot of chunk rocks](figure/rocks-1.png)![plot of chunk rocks](figure/rocks-2.png)![plot of chunk rocks](figure/rocks-3.png)![plot of chunk rocks](figure/rocks-4.png)![plot of chunk rocks](figure/rocks-5.png)![plot of chunk rocks](figure/rocks-6.png)![plot of chunk rocks](figure/rocks-7.png)![plot of chunk rocks](figure/rocks-8.png)![plot of chunk rocks](figure/rocks-9.png)![plot of chunk rocks](figure/rocks-10.png)![plot of chunk rocks](figure/rocks-11.png)![plot of chunk rocks](figure/rocks-12.png)![plot of chunk rocks](figure/rocks-13.png)
