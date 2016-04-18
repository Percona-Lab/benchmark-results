#!/bin/bash
time=600
for engine in rocks wt ft; do 
    size=2000000
    for paths in "mongodb-linux-x86_64-ubuntu1404-3.0.11:3.0-$engine" "mongodb-linux-x86_64-ubuntu1404-3.0.11:pareto_mongodb30-$engine" "mongodb-linux-x86_64-ubuntu1404-3.2.4:3.2-$engine" "mongodb-linux-x86_64-ubuntu1404-3.2.4:pareto_mongodb32-$engine" "percona-server-mongodb-3.0.10-1.5:3.0-$engine" "percona-server-mongodb-3.0.10-1.5:pareto_ps30-$engine" "percona-server-mongodb-3.2.0-1.0:3.2-$engine" "percona-server-mongodb-3.2.0-1.0:pareto_ps32-$engine"; do 
	for threads in 512 256 128 64 48 40 32 24 16 8 4 2 1; do
           path="mongo/$(echo $paths|awk -F: '{print $1}')"
           distribution=uniform
           echo $paths|grep pareto>/dev/null && distribution=pareto
           datapath=$(echo $paths|awk -F: '{print $2}')
           echo $path|grep 'mongodb-linux'>/dev/null && [ "$engine" != "wt" ] && continue
           server="psmdb"
           echo $path|grep 'mongodb-linux'>/dev/null && server="upstream"
	   for workload in oltp oltp_ro; do
	   version=3.0
	   echo $path | grep 3.2>/dev/null && version=3.2 
	   echo "Workload: $workload, threads: $threads, engine: $engine, time: $time"
	   echo -n "restoring datadir ..."
	   ssh smblade04 "sudo env engine=$engine /home/fipar/PERF-22/restore_datadir.sh $path $datapath"
	   echo "Done"
	   echo "Sending SIGHUP to mongo-response-time-exporter"
	   ssh smblade04 "sudo kill -s SIGHUP $(pidof mongo-response-time-exporter)"
	   echo -n "Waiting 30 seconds ... "
	   sleep 30
	   echo "Done"
	   echo "Starting benchmark"
	       /home/fipar/bin/sysbench \
		   --mongo-write-concern=1 \
		   --mongo-url="mongodb://smblade04" \
		   --mongo-database-name=sbtest \
		   --test=sysbench/sysbench/tests/mongodb/$workload.lua \
		   --oltp_table_size=$size \
		   --oltp_tables_count=16 \
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
		   --oltp-inserts=1 run 2>&1 | tee sysbench-$distribution-$server-$version-$engine-$size-$threads-$workload.txt
	    echo "Benchmark complete"
	   done
       done
    done
done
