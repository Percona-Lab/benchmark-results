#!/bin/bash
#This uses the dev-mongodb-support branch Percona-Lab's sysbench fork: https://github.com/Percona-Lab/sysbench/tree/dev-mongodb-support
#To use this script, a binary backup of the datadir was prepared for each engine under, by using sysbench prepare, then cleanly shutting down mongod, and copying the datadir.  
#This is provided as a reference for how to reproduce the results. 

time=720
for engine in rocks ft wt; do
restore_datadir()
{
kill -SIGTERM $(pidof mongod)
    echo -n "Waiting for mongod to shutdown ..."
    while [ -n "$(pidof mongod)" ]; do 
       sleep 0.3
    done
    echo " Done"
rm -rf /mnt/i3600/PERF-15/$engine/
'cp' -rv /mnt/storage/PERF-15/$engine /mnt/i3600/PERF-15/
pushd /mnt/storage/PERF-15/fipar/
#./$engine.sh --quiet &> $engine.log &
[ "$engine" == "ft" ] && ./transparent_huge_pages.sh disable || ./transparent_huge_pages.sh enable
./$engine.sh --quiet --slowms=100000000 &> $engine.log &
   echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | /mnt/storage/PERF-15/fipar/percona-server-mongodb-3.0.8-1.2/bin/mongo 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
       sleep 0.3
    done
    echo " Done"
popd
}
 

    size=2000000
    for threads in 512 256 128 64 48 40 32 24 16 8 4 2 1; do
       for workload in oltp_ro oltp; do
       echo "Workload: $workload, threads: $threads, engine: $engine"
       echo -n "restoring datadir ..."
       restore_datadir
       echo "Done"
       echo "Sending SIGHUP to mongo-response-time-exporter"
       sudo kill -SIGHUP $(pidof mongo-response-time-exporter)
       echo -n "Waiting 30 seconds ... "
       sleep 30
       echo "Done"
       echo "Starting benchmark"
	   /home/fipar/bin/sysbench \
	       --mongo-url="mongodb://localhost" \
	       --mongo-database-name=sbtest \
	       --test=sysbench/tests/mongodb/$workload.lua \
	       --oltp_table_size=$size \
	       --oltp_tables_count=16 \
	       --num-threads=$threads \
	       --report-interval=10 \
	       --max-requests=0 \
	       --max-time=$time \
	       --oltp-point-selects=10 \
	       --oltp-simple-ranges=3 \
	       --oltp-sum-ranges=3 \
	       --oltp-order-ranges=3 \
	       --oltp-distinct-ranges=3 \
	       --oltp-index-updates=4 \
	       --oltp-non-index-updates=4 \
	       --oltp-inserts=6 run 2>&1 | tee sysbench-$engine-$size-$threads-$workload.txt
        echo "Benchmark complete"
       done
    done
done
