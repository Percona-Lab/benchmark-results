---

title: "Percona Server for MongoDB 3.2.7: WiredTiger vs InMemory sysbench oltp performance"

author: "Percona Lab"
generated on:July 28, 2016
output:
  md_document:
    variant: markdown_github

---



# Percona Server for MongoDB 3.2.7-1.1 - WiredTiger vs InMemory sysbench oltp performance

## Setup

* WiredTiger: psmdb 3.2.7-1.1 
* InMemory: built from source, v3.2 percona-server-mongodb branch
* sysbench with mongodb support, oltp and oltp_ro scripts
* inMemorySizeGB / wiredTigerCacheSizeGB set to 32GB
* Data set: 8 collections, 6M documents per collection (12GB compressed)

## Benchmark procedure

* For WiredTiger: restore the datadir from binary backup before each experiment
* For InMemory: restore the datadir with mongorestore (taken with mongodump from the same data set used to create the binary backup for WiredTiger) before each experiment
* Sysbench runs of 60 seconds


![plot of chunk short](figure/short-1.png)![plot of chunk short](figure/short-2.png)![plot of chunk short](figure/short-3.png)![plot of chunk short](figure/short-4.png)


