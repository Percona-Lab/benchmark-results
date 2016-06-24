---

title: "MySQL Community Server 5.7: General Tablespaces performance"
author: "Percona Lab"
generated on:June 23, 2016
output:
  md_document:
    variant: markdown_github

---


# MySQL Community Edition 5.7.13: General Tablespaces performance 

## Setup

* Client and server on the same machine 
* Client sofwware is sysbench, 500 active threads, varying number of
active (i.e. used) schemas. Total schemas on server are 40k. 
* CPU: 48 logical CPU threads (Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz). 
* Memory: 100GB Buffer Pool. 130GB RAM.  
* Disk: Intel 3600 nvme
* Standard test: innodb_file_per_table. 
* GT test: one general tablespace per schema. 

## Throughput per test and active_schemas 

![plot of chunk global](figure/global-1.png)
