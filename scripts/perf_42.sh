#!/bin/bash

export TIME=120
export COLSIZE=6000000
export COLNUM=8
export DBPATH_ROOT=/mnt/i3600/PERF-42
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
    /home/fipar/PERF-22/transparent_huge_pages.sh disable
    export MONGO_PATH=$mongo_path
    export DBPATH=$DBPATH_ROOT/$distribution/
    stop_mongod
    memory=16
    [ -n "$MEMORY" ] && memory=$MEMORY
    [ "$engine" == "inmemory" ] && export DBPATH=$DBPATH_ROOT/im/
    nohup /home/fipar/PERF-22/start-$engine-42.sh $memory &> $engine.log &
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
    /home/fipar/bin/sysbench \
        --mongo-write-concern=1 \
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
        --oltp-index-updates=1 \
        --oltp-non-index-updates=1 \
        --oltp-inserts=1 run 2>&1 | tee sysbench-$tag.txt
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
    [ -z "$1" ] && echo "usage: restore_inmemory_datadir <uniform|pareto>">&2 && return 1
    restart_mongod $distribution $MONGOPATH_INMEMORY inmemory 
    for i in $(seq $COLNUM); do
	$MONGOC localhost/sbtest --eval "db.createCollection(\"sbtest$i\",{storageEngine: {wiredTiger: {configString: 'cache_resident=1'}}})"
    done
    mongorestore -j $COLNUM --noOptionsRestore --numInsertionWorkersPerCollection 4 $BACKUPS_PATH/inmemory-$1/ 
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


second_benchmark(){
    for workload in oltp write_only; do # insert too
	for engine in wt inmemory; do
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

repeat_all_inmemory()
{
    for workload in oltp oltp_ro; do
	for engine in inmemory; do
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

repeat_all_wt()
{
    for workload in oltp oltp_ro; do
	for engine in wt; do
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

# sysbench-inmemory-pareto-512-oltp.txt
current_repeat()
{
    tag=inmemory-pareto-512-oltp
    restart_as_inmemory pareto
    run_sysbench $TIME 512 $COLSIZE oltp uniform $tag
}

long_benchmark()
{
    for workload in oltp write_only; do
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
    done # for workload in ...
}
