#!/bin/bash

export TIME=120
export THREADS="128 64 32 16"
export COLSIZE=6000000
export COLNUM=8
export DBPATH_ROOT=/mnt/i3600/PERF-42
export DBPATH_ROOT_SLOW=/mnt/storage/PERF-42/
export DBPATH_RSET_WT=/mnt/i3600/rset-perf-42/wt
export DBPATH_RSET_INMEMORY=/mnt/i3600/rset-perf-42/inmemory
export MONGOPATH_WT=percona-server-mongodb-3.2.7-1.1
export MONGOC=/home/fipar/PERF-22/percona-server-mongodb-3.2.7-1.1/bin/mongo
export MONGOPATH_INMEMORY=psmdb-inmemory
export BACKUPS_PATH=/mnt/storage/backup-perf-42

stop_mongod()
{
    [ -n "$(pidof mongod)" ] && {
	echo -n "Stopping mongod ..."
	kill $(pidof mongod)
	i=0
	while [ -n "$(pidof mongod)" ]; do
	    i=$((i+1))
	    [ $i -ge 60 ] && break
	    sleep 1
	done
	echo "Done"
	[ $i -ge 60 ] && kill -9 $(pidof mongod) && echo "Sleeping 120 seconds after SIGKILLing mongod" && sleep 120
    }
}

restart_mongod()
{
    [ $# -eq 0 ] && echo "missing args for restore_datadir" && return 
    distribution=$1
    mongo_path=$2
    engine=$3
    mongo_port=27017
    [ -n "$4" ] && mongo_port=$4
    /home/fipar/PERF-22/transparent_huge_pages.sh disable
    export MONGO_PATH=$mongo_path
    export DBPATH=$DBPATH_ROOT/$distribution/
    [ -n "$BENCH_HDD" ] && export DBPATH=$DBPATH_ROOT_SLOW/$distribution/
    export MONGO_PORT=$mongo_port
    stop_mongod
    memory=16
    [ -n "$MEMORY" ] && memory=$MEMORY
    
    [ "$engine" == "inmemory" ] && export DBPATH=$DBPATH_ROOT/im/
    [ "$engine" == "inmemory" -a -n "$BENCH_HDD" ] && export DBPATH=$DBPATH_ROOT_SLOW/im/
    nohup /home/fipar/PERF-22/start-$engine-42.sh $memory --slowms=10000 &> $engine.log &
    echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | $MONGOC 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
	sleep 0.3
    done
    echo "Done. "
}

run_sysbench()
{
    [ $# -eq 0 ] && echo "missing args for run_benchmark" && return
    time=$1
    threads=$2
    size=$3
    workload=$4
    distribution=$5
    tag=$6
    write_concern=1
    benchmark_ok=0
    benchmark_attempts=1
    while [ $benchmark_ok -eq 0 -a $benchmark_attempts -le 5 ]; do
	[ -n "$WRITE_CONCERN" ] && write_concern=$WRITE_CONCERN
	benchmark_attempts=$((benchmark_attempts+1))
	/home/fipar/bin/sysbench \
	    --mongo-write-concern=$write_concern \
	    --mongo-url="mongodb://localhost" \
	    --mongo-database-name=sbtest \
	    --test=sysbench/sysbench/tests/mongodb/$workload.lua \
	    --oltp_table_size=$size \
	    --oltp_tables_count=16 \
	    --num-threads=$threads \
	    --rand-type=$distribution \
	    --report-interval=2 \
	    --max-requests=0 \
	    --max-time=$time \
	    --oltp-point-selects=10 \
	    --oltp-simple-ranges=1 \
	    --oltp-sum-ranges=1 \
	    --oltp-order-ranges=1 \
	    --oltp-distinct-ranges=1 \
	    --oltp-index-updates=8 \
	    --oltp-non-index-updates=8 \
	    --oltp-inserts=4 run 2>&1 | tee sysbench-$tag.txt
	[ $(grep -c FATAL sysbench-$tag.txt) -le 100 ] && benchmark_ok=1 
    done
}

generate_data()
{
    for distribution in uniform pareto; do
	stop_mongod
	rm -rf $DBPATH_ROOT/$distribution/*
	restart_mongod $distribution $MONGOPATH_WT wt 
	/home/fipar/bin/sysbench \
	    --mongo-write-concern=1 \
	    --mongo-url="mongodb://localhost" \
	    --mongo-database-name=sbtest \
	    --test=sysbench/sysbench/tests/mongodb/parallel_prepare.lua \
	    --oltp_table_size=$COLSIZE \
	    --oltp_tables_count=$COLNUM \
	    --rand-type=$distribution \
	    --max-requests=$COLNUM \
	    --num-threads=$COLNUM run | tee sysbench-prepare-$distribution.txt
	stop_mongod
	rm -rf $BACKUPS_PATH/$distribution/*
	cp -rv $DBPATH_ROOT/$distribution/* $BACKUPS_PATH/$distribution/
    done
}

restore_wt_datadir()
{
    [ -z "$1" ] && echo "usage: restore_wt_datadir <uniform|pareto>">&2 && return 1
    distribution=$1
    rm -rf $DBPATH_ROOT/$distribution/*
    cp -r $BACKUPS_PATH/$distribution/* $DBPATH_ROOT/$distribution/
    du -hcd1 $DBPATH_ROOT
}


cleanup_wt_datadir()
{
    [ -z "$1" ] && echo "usage: cleanup_wt_datadir <uniform|pareto>">&2 && return 1
    distribution=$1
    rm -rf $DBPATH_ROOT/$distribution/*
}

create_dumps_for_inmemory()
{
    stop_mongod
    for distribution in uniform pareto; do
	restore_wt_datadir $distribution
	restart_mongod $distribution $MONGOPATH_WT wt
	test -d $BACKUPS_PATH/inmemory-$distribution || mkdir $BACKUPS_PATH/inmemory-$distribution
	rm -rf $BACKUPS_PATH/inmemory-$distribution/*
	mongodump -o $BACKUPS_PATH/inmemory-$distribution/
    done
}

restart_as_inmemory()
{
    [ -z "$1" ] && echo "usage: restore_inmemory_datadir <uniform|pareto> [noload]">&2 && return 1
    noload=0
    [ "$2" == "noload" ] && noload=1 
    restart_mongod $distribution $MONGOPATH_INMEMORY inmemory 
    cgclassify -g memory:DBLimitedGroup `pidof mongod`
    [ $noload -eq 0 ] && mongorestore -j $COLNUM --noOptionsRestore --numInsertionWorkersPerCollection 4 $BACKUPS_PATH/inmemory-$1/ 
}

first_benchmark()
{
    for workload in oltp oltp_ro; do
	for engine in wt inmemory; do
	    for distribution in uniform pareto; do
		for threads in 512 128 48 32; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
		    else
			restart_as_inmemory $distribution
		    fi
		    tag=$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}


emulate_sysbench_mongodb(){
    workload=oltp
	for engine in inmemory wt; do
	    for distribution in uniform pareto; do
		for threads in 32 24 16; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    echo $(( $MEMORY * 1024 * 1024 * 1024 * 2 )) > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    cat /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
			cgclassify -g memory:DBLimitedGroup `pidof mongod`
		    else
			restart_as_inmemory $distribution
		    fi
		    drive=ssd
		    [ -n "$BENCH_HDD" ] && drive=hdd
		    tag=$drive-$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...

}

second_benchmark(){
    for workload in oltp write_only; do 
	for engine in inmemory wt; do
	    for distribution in uniform pareto; do
		for threads in $THREADS; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    echo $(( $MEMORY * 1024 * 1024 * 1024 * 2 )) > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    cat /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
			cgclassify -g memory:DBLimitedGroup `pidof mongod`
		    else
			restart_as_inmemory $distribution
		    fi
		    drive=ssd
		    [ -n "$BENCH_HDD" ] && drive=hdd
		    tag=$drive-$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}


oltp_flamegraphs(){
    threads=128; distribution=uniform; workload=oltp
    saved_time=$TIME; export TIME=60
    for engine in inmemory wt; do
	stop_mongod
	echo $(( $MEMORY * 1024 * 1024 * 1024 * 2 )) > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
	if [ "$engine" == "wt" ]; then
	    restore_wt_datadir $distribution
	    restart_mongod $distribution $MONGOPATH_WT $engine
	    cgclassify -g memory:DBLimitedGroup `pidof mongod`
	else
	    restart_as_inmemory $distribution
	fi
	(perf record -F 99 -a -g -- sleep 60; perf script > $tag.perf) &
	tag=fg-$engine-$distribution-$threads-$workload
	run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
    done # for engine in ...
    export TIME=$saved_time
}

ssd_and_hdd_second_benchmark()
{
    unset BENCH_HDD
    second_benchmark
    export BENCH_HDD=1
    second_benchmark
    unset BENCH_HDD
}

ssd_and_hdd_inserts_second_benchmark()
{
    unset BENCH_HDD
    inserts_second_benchmark
    export BENCH_HDD=1
    inserts_second_benchmark
    unset BENCH_HDD
}

ssd_and_hdd_short_benchmarks()
{
    unset BENCH_HDD
    second_benchmark; inserts_second_benchmark
    export BENCH_HDD=1
    second_benchmark; inserts_second_benchmark
    unset BENCH_HDD
}

inserts_second_benchmark(){
    for workload in insert; do # insert too
	for engine in inmemory wt; do
	    for distribution in uniform pareto; do
		for threads in $THREADS; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    echo $(( $MEMORY * 1024 * 1024 * 1024 * 2 )) > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    cat /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
		    if [ "$engine" == "wt" ]; then
			cleanup_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
			cgclassify -g memory:DBLimitedGroup `pidof mongod`
		    else
			restart_as_inmemory $distribution noload
		    fi
		    drive=ssd
		    [ -n "$BENCH_HDD" ] && drive=hdd
		    tag=$drive-$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}

repeat_all_inmemory()
{
    for workload in write_only oltp; do
	for engine in inmemory; do
	    for distribution in uniform pareto; do
		for threads in 256 128 48; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
		    else
			restart_as_inmemory $distribution
		    fi
		    tag=$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}

repeat_all_wt()
{
    for workload in oltp write_only; do
	for engine in wt; do
	    for distribution in uniform pareto; do
		for threads in 256 128 48; do
		    stop_mongod # then it will be stopped again by restart_mongod ... 
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
		    else
			restart_as_inmemory $distribution
		    fi
		    tag=$engine-$distribution-$threads-$workload
		    run_sysbench $TIME $threads $COLSIZE $workload $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}

# sysbench-wt-uniform-128-write_only.txt 
current_repeat()
{
    tag=wt-uniform-128-write_only
    stop_mongod
    restore_wt_datadir uniform
    restart_mongod uniform $MONGOPATH_WT wt
    run_sysbench $TIME 128 $COLSIZE write_only uniform $tag
}

long_benchmark()
{
    workload=oltp 
    for workload in oltp insert; do
	for engine in wt inmemory; do
	    for distribution in uniform pareto; do # insert too
		for threads in 24; do
		    stop_mongod
			if [ "$engine" == "wt" ]; then
			    if [ "$workload" == "insert" ]; then
				cleanup_wt_datadir $distribution
				restart_mongod $distribution $MONGOPATH_WT $engine
				#cgclassify -g memory:DBLimitedGroup `pidof mongod`
			    else
				restore_wt_datadir $distribution
				restart_mongod $distribution $MONGOPATH_WT $engine
			    fi
			else
			    [ "$workload" == "insert" ] && restart_as_inmemory $distribution noload || restart_as_inmemory $distribution
			fi
			tag=long-$engine-$distribution-$threads-$workload
			run_sysbench 1200 $threads $COLSIZE oltp $distribution $tag
		done # for threads in ...
	    done # for distribution in ...
	done # for engine in ...
    done # for workload in ...
}

inserts_long_benchmark()
{
    workload=insert 
    for engine in wt inmemory; do
	for distribution in uniform pareto; do # insert too
	    for threads in 128; do
		stop_mongod
		    if [ "$engine" == "wt" ]; then
			restore_wt_datadir $distribution
			restart_mongod $distribution $MONGOPATH_WT $engine
		    else
			restart_as_inmemory $distribution
		    fi
		    tag=long-$engine-$distribution-$threads-$workload
		    run_sysbench 3600 $threads $COLSIZE oltp $distribution $tag
	    done # for threads in ...
	done # for distribution in ...
    done # for engine in ...
}

create_cgroup()
{
    cgcreate -g memory:DBLimitedGroup
}


start_rset_env()
{
    memory=24
    [ -n  "$MEMORY" ] && memory=$MEMORY
    env MONGO_PATH=$MONGOPATH_INMEMORY DBPATH=$DBPATH_RSET_INMEMORY ./start-inmemory-42.sh $memory --replSet sysbench &> rset_inmemory.log & 
    env MONGO_PATH=$MONGOPATH_WT DBPATH=$DBPATH_RSET_WT MONGO_PORT=27018 ./start-wt-42.sh $memory --replSet sysbench &> rset_wt.log & 
}

sigterm_all_mongo()
{
ps -ef|grep mongod|awk '{print $2}'|xargs kill
}
