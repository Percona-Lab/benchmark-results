---

title: "Percona Server for MongoDB: Storage Engine comparison"
author: "Percona Lab"
generated on:April 24, 2016
output:
  md_document:
    variant: markdown_github

---


# Percona Server for MongoDB 3.2.0-1.0 - data that does not fit in RAM 

## Setup

* Client (sysbench) and server are on the same machine
* CPU: 48 logical CPU threads servers Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
* 12GB RAM (limited via cgroup)
* sysbench with mongodb support, 16 collections x 10m documents (~30G compressed), uniform and pareto distributions. 

## Throughput per threads and workload

![plot of chunk global](figure/global-1.png)![plot of chunk global](figure/global-2.png)![plot of chunk global](figure/global-3.png)![plot of chunk global](figure/global-4.png)

## Throughput per threads and workload, summary for engine


```
## Error: Faceting variables must have at least one value
```

![plot of chunk engines](figure/engines-1.png)![plot of chunk engines](figure/engines-2.png)

## Throughput per threads and workload, details. 
## Throughput per threads and workload, PerconaFT


```
## Error: Faceting variables must have at least one value
```

![plot of chunk ft](figure/ft-1.png)

## Throughput per threads and workload, WiredTiger

![plot of chunk wt](figure/wt-1.png)![plot of chunk wt](figure/wt-2.png)![plot of chunk wt](figure/wt-3.png)![plot of chunk wt](figure/wt-4.png)![plot of chunk wt](figure/wt-5.png)![plot of chunk wt](figure/wt-6.png)![plot of chunk wt](figure/wt-7.png)![plot of chunk wt](figure/wt-8.png)![plot of chunk wt](figure/wt-9.png)![plot of chunk wt](figure/wt-10.png)![plot of chunk wt](figure/wt-11.png)![plot of chunk wt](figure/wt-12.png)![plot of chunk wt](figure/wt-13.png)

## Throughput per threads and workload, RocksDB

![plot of chunk rocks](figure/rocks-1.png)![plot of chunk rocks](figure/rocks-2.png)![plot of chunk rocks](figure/rocks-3.png)![plot of chunk rocks](figure/rocks-4.png)![plot of chunk rocks](figure/rocks-5.png)![plot of chunk rocks](figure/rocks-6.png)![plot of chunk rocks](figure/rocks-7.png)![plot of chunk rocks](figure/rocks-8.png)![plot of chunk rocks](figure/rocks-9.png)![plot of chunk rocks](figure/rocks-10.png)![plot of chunk rocks](figure/rocks-11.png)![plot of chunk rocks](figure/rocks-12.png)![plot of chunk rocks](figure/rocks-13.png)
