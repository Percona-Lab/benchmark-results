#!/bin/bash

usage()
{
    cat <<EOF>&2

usage: run_sysbench <time> <threads> <size> <distribution> <workload> <tag> <command> [ncols]

where: 
 <time> is benchmark time in seconds 
 <threads> is the number of threads to start 
 <size> is the collection size in # of documents
 <distribution> is one of uniform or pareto
 <workload> is one of oltp or oltp_ro
 <tag> will be used to name the output file, i.e. sysbench-$tag.txt
 <command> is one of prepare, run or cleanup
 [ncols], if provided, is the number of collections to create

EOF

}

[ $# -eq 0 ] && echo "missing args for run_sysbench" && usage && exit 1 
time=$1
threads=$2
size=$3
distribution=$4
workload=$5
tag=$6
command=$7
ncols=16
[ -n "$8" ] && ncols=$8
/home/fipar/src/sysbench/sysbench \
    --mongo-write-concern=1 \
    --mongo-url="mongodb://smblade01" \
    --mongo-database-name=sbtest \
    --test=sysbench-tests/mongodb/$workload.lua \
    --oltp_table_size=$size \
    --oltp_tables_count=$ncols \
    --num-threads=$threads \
    --rand-type=$distribution \
    --report-interval=10 \
    --max-requests=0 \
    --max-time=$time \
    --oltp-point-selects=10 \
    --oltp-simple-ranges=1 \
    --oltp-sum-ranges=1 \
    --oltp-order-ranges=1 \
    --oltp-distinct-ranges=1 \
    --oltp-index-updates=1 \
    --oltp-non-index-updates=1 \
    --oltp-inserts=1 $command 2>&1 | tee sysbench-$tag.txt
