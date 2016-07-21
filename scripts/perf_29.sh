#!/bin/bash

hdd=/mnt/storage/PERF-29
slowssd=/mnt/ct960/PERF-29
fastssd=/mnt/i3600/PERF-29

mongoc=/home/fipar/PERF-22/mongo/mongodb-linux-x86_64-ubuntu1404-3.2.4/bin/mongo

stop_mongod()
{
    [ -n "$(pidof mongod)" ] && {
	echo -n "Stopping mongod ..."
	kill $(pidof mongod)
	i=0
	while [ -n "$(pidof mongod)" ]; do
	    i=$((i+1))
	    [ $i -ge 20 ] && break
	    sleep 0.3
	done
	echo "Done"
	[ $i -ge 20 ] && kill -9 $(pidof mongod) && echo "Sleeping 120 seconds after SIGKILLing mongod" && sleep 120
    }
}

restore_datadir()
{
    [ $# -eq 0 ] && echo "missing args for restore_datadir" && return 
    mongopath=$1
    datapath=$2
    dbpath=$3
    engine=$4
    size=$5
    distribution=$6
    stop_mongod
    rm -rf $dbpath/data/$engine-$size
    mkdir $dbpath/data/$engine-$size
    'cp' -rv $datapath/$engine/ $dbpath/data/$engine-$size-$distribution
    echo "Restored datadir from $datapath"
}

restart_mongod()
{
    [ $# -eq 0 ] && echo "missing args for restore_datadir" && return 
    mongopath=$1
    dbpath=$2
    engine=$3
    memory=$4
    size=$5
    distribution=$6
    cache=64
    [ $memory -eq 20 ] && cache=10
    [ "$engine" == "ft" -o "$engine" == "wt" ] && /home/fipar/PERF-22/transparent_huge_pages.sh disable || /home/fipar/PERF-22/transparent_huge_pages.sh enable
    export MONGO_PATH=$mongopath
    export DBPATH=$dbpath/data/$engine-$size-$distribution/$engine
    stop_mongod
    nohup /home/fipar/PERF-22/start-$engine-29.sh $cache &> $engine.log &
    echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | $mongoc 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
	sleep 0.3
    done
    echo "Done. SIGHUPing mongo-response-time-exporter and waiting 30 seconds"
    [ $memory -eq 20 ] && cgclassify -g memory:PERF22_20 $(pidof mongod)
    kill -s SIGHUP $(pidof mongo-response-time-exporter)
    sleep 30
}

run_benchmark()
{
    [ $# -eq 0 ] && echo "missing args for run_benchmark" && return
    time=$1
    threads=$2
    size=$3
    range_size=$4
    distribution=$5
    tag=$6
    /home/fipar/bin/sysbench \
        --mongo-write-concern=1 \
        --mongo-url="mongodb://localhost" \
        --mongo-database-name=sbtest \
        --test=sysbench/sysbench/tests/mongodb/ranges_ro.lua \
        --oltp_table_size=$size \
        --oltp_tables_count=16 \
        --num-threads=$threads \
        --rand-type=$distribution \
        --report-interval=10 \
        --max-requests=0 \
        --max-time=$time \
	--oltp-range-size=$range_size \
        --oltp-point-selects=10 \
        --oltp-simple-ranges=1 \
        --oltp-sum-ranges=1 \
        --oltp-order-ranges=1 \
        --oltp-distinct-ranges=1 \
        --oltp-index-updates=1 \
        --oltp-non-index-updates=1 \
        --oltp-inserts=1 run 2>&1 | tee sysbench-$tag.txt
}

time=300

for engine in rocks wt; do
    for workload in iobound iobound_heavy cpubound; do
	for distribution in uniform pareto; do
	    for dev in $hdd $slowssd $fastssd; do
		drive=fastssd
		dbpath=$fastssd
		size=small
		datapath=/mnt/storage/PERF-15/${distribution}_ps32-$engine
		if [ "$workload" == "cpubound" -a "$dev" != "$fastssd" ]; then
		    continue
		fi # if workload is cpubound and dev is not fastssd
		if [ "$workload" == "iobound" -o "$workload" == "iobound_heavy" ]; then
		    datapath=/mnt/storage/PERF-22/backups_large/${distribution}_3.2-$engine
		    size=large
		fi # if workload is iobound or iobound_heavy
		dbpath=$dev
		[ "$dbpath" == "$hdd" ] && drive=hdd
		[ "$dbpath" == "$slowssd" ] && drive=slowssd
		restore_datadir  mongo/percona-server-mongodb-3.2.4-1.0rc2 $datapath $dbpath $engine $size $distribution
	    done
	done
    done
done
#restore_datadir $mongopath $datapath $dbpath $engine 

for engine in rocks wt; do
    for workload in iobound iobound_heavy cpubound; do
        size=10000000
	memory=0
        [ "$workload" == "iobound_heavy" -o "$workload" == "iobound" ] && size=60000000
        [ "$workload" == "ibound_heavy" ] && memory=20 
	for range_size in 1000 10000; do
	    for threads in 512 128 48 32 16 4 1; do
		for distribution in uniform pareto; do
		    for dev in $hdd $slowssd $fastssd; do
		        size=small
			drive=fastssd
			dbpath=$fastssd
			datapath=/mnt/storage/PERF-15/${distribution}_ps32-$engine
			if [ "$workload" == "cpubound" -a "$dev" != "$fastssd" ]; then
			    continue
			fi # if workload is cpubound and dev is not fastssd
			if [ "$workload" == "iobound" -o "$workload" == "iobound_heavy" ]; then
			    datapath=/mnt/storage/PERF-22/backups_large/${distribution}_3.2-$engine
			    size=large
			fi # if workload is iobound or iobound_heavy
			dbpath=$dev
			[ "$dbpath" == "$hdd" ] && drive=hdd
			[ "$dbpath" == "$slowssd" ] && drive=slowssd
			restart_mongod mongo/percona-server-mongodb-3.2.4-1.0rc2 $dbpath $engine $memory $size $distribution
			echo -17 > /proc/$(pidof mongod)/oom_adj
			tag="$workload-$range_size-$drive-$distribution-psfm32-$engine-$size-$threads-ranges_ro"
			run_benchmark $time $threads $size $range_size $distribution $tag
		    done #for dev
		done # for distribution
	    done # for threads
	done # for range_size
    done # for workload
done # for engine

