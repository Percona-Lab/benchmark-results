#!/bin/bash

#export DATADIR=/mnt/storage/PERF-31/
export HDD_DATADIR=/mnt/storage/PERF-31/
export SSD_DATADIR=/mnt/i3600
current_datadir()
{
  [ -z "$DATADIR" ] && echo $HDD_DATADIR || echo $DATADIR
}


export BACKUP_DIR=/mnt/storage/backup-PERF-31/
export XB_DIR=/mnt/storage/xb-PERF-31/
export PID_DIR=/home/fipar/PERF-31/
export IB="innobackupex --defaults-file=/home/fipar/PERF-31/my.cnf --host=127.0.0.1 --user=root" 
export TIME=3600
export SIZE=10000000
export SB_THREADS=16
export XB_THREADS="1 4 8 16 32"
export PARALLEL_THREADS="1 4 8 16"
export TRACE=0

sysbench_cmd()
{
    [ -z "$1" ] && echo "usage: sysbench_cmd <command> # where command is a valid sysbench command like prepare or run">&2 && return 1
    sysbench \
	--mysql-host=127.0.0.1 \
	--mysql-user=sbuser \
	--mysql-password=sbuser \
	--report-interval=1 \
	--num-threads=$SB_THREADS \
	--mysql-db=sbtest \
	--max-requests=999999999 \
	--run-time=$TIME \
	--test=/data/opt/alexey.s/sb2/tests/sysbench-standard/db/oltp.lua \
	--mysql-table-engine=Innodb \
	--oltp_tables_count=8 \
	--oltp_table_size=$SIZE $1 \
	
}

stop_mysqld()
{
    mysqladmin -h127.0.0.1 shutdown
}

start_mysqld()
{
    mysqld_safe --defaults-file=/home/fipar/PERF-31/my.cnf --datadir=$(current_datadir) &> mysqld_safe.log &
    sleep 1
}

start_oltp()
{
    [ -z "$1" ] && echo "usage: start_oltp <tag>">&2 && return 1
    sysbench_cmd run &> sysbench.$1.log &
    echo $! > $PID_DIR/sysbench.pid
}

stop_oltp()
{
    kill $(cat $PID_DIR/sysbench.pid); rm -f $PID_DIR/sysbench.pid
}

start_collectors()
{
    [ -z "$1" ] && echo "usage: start_collectors <tag>">&2 && return 1
    vmstat 1 &> vmstat.$1.log &
    echo $! > $PID_DIR/vmstat.pid
    pt-diskstats --iterations $TIME </dev/null &> diskstats.$1.log &
    echo $! > $PID_DIR/diskstats.pid
}

stop_collectors()
{
    kill -9 $(cat $PID_DIR/vmstat.pid); rm -f $PID_DIR/vmstat.pid
    kill -9 $(cat $PID_DIR/diskstats.pid); rm -f $PID_DIR/diskstats.pid
}

wait_for_mysqld()
{
    running=1
    while [ $running -eq 1 ]; do
	mysql -h127.0.0.1 -e 'select @@version' 2>/dev/null && running=0 || sleep 0.3
    done # while $running -eq 1
}

restore_datadir()
{
    stop_mysqld
    rm -rf $(current_datadir)/* 
    cp -rv $BACKUP_DIR/* $(current_datadir) 
    start_mysqld
    echo -n "Waiting for mysqld to come up ... "
    wait_for_mysqld
    echo "Done"
}

restart_mysqld()
{
    stop_mysqld
    start_mysqld
    echo -n "Waiting for mysqld to come up ... "
    wait_for_mysqld
    echo "Done"
}

ts()
{
    date "+%s"
}

prepare()
{
   sysbench_cmd prepare
}

test_file_copy()
{
    mkdir $BACKUP_DIR/manual_test
    cp -rv $SSD_DATADIR $BACKUP_DIR
}

deferred_pmp()
{
    sleep 40
    for i in $(seq 4); do
	pt-pmp -p $(pidof innobackupex) &> ${1}-$i.pmp &
	sleep 10
    done
}

# test sysbench with no backup running
test_sysbench_nobackup()
{
    restore_datadir
    tag="nobackup"
    echo "Sleeping 5 seconds before starting collectors"
    sleep 5
    start_oltp $tag
    start_collectors $tag
    echo "Sleeping 150 seconds to simulate a backup"
    sleep 150
    stop_oltp
    stop_collectors
    echo "Done"
}

# baseline. full, uncompressed, unencrypted backup
test_baseline()
{
i=1
#for i in $(seq 5); do
    restore_datadir
    tag="baseline-$i"
    [ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
    echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
    start_oltp $tag
    start_collectors $tag
    echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
    ts > timestamps.$tag.log
    trace_cmd=""
    [ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
    [ $TRACE -eq 2 ] && trace_cmd="operf "
    [ $TRACE -eq 3 ] && deferred_pmp $tag & 
    $trace_cmd$IB $* $XB_DIR
    ts >> timestamps.$tag.log
    [ $TRACE -eq 1 ] && perf script > $tag.perf
    [ $TRACE -eq 2 ] && opreport > $tag.opreport
    echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
    stop_oltp
    stop_collectors
    echo "Done"
#done
}
# for the next two cases, play with threads, for t in 1 4 8 16 etc

# encrypted and compressed with xbstream
test_encrypted_compressed_xbstream()
{
for t in $XB_THREADS; do
    restore_datadir
    tag="encryption-xbstream_compressed-threads-$t"
    [ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
    echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
    start_oltp $tag
    start_collectors $tag
    echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
    ts > timestamps.$tag.log
    trace_cmd=""
    [ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
    [ $TRACE -eq 2 ] && trace_cmd="operf "    
    [ $TRACE -eq 3 ] && deferred_pmp $tag & 
    $trace_cmd$IB --compress --compress-threads=$t --stream=xbstream --encryption=AES256 --encrypt-key-file=/home/fipar/PERF-31/key.256 --encrypt-threads=$t $* ./ > $XB_DIR/backup.$tag.xbstream
    ts >> timestamps.$tag.log
    [ $TRACE -eq 1 ] && perf script > $tag.perf
    [ $TRACE -eq 2 ] && opreport > $tag.opreport
    echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
    stop_oltp
    stop_collectors
    echo "Done"
 done # for t in ...
}

# encrypted
test_encrypted()
{
for t in $XB_THREADS; do
    restore_datadir
    tag="encryption-threads-$t"
    [ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
    echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
    start_oltp $tag
    start_collectors $tag
    echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
    ts > timestamps.$tag.log
    trace_cmd=""
    [ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
    [ $TRACE -eq 2 ] && trace_cmd="operf "    
    [ $TRACE -eq 3 ] && deferred_pmp $tag & 
    $trace_cmd$IB --encryption=AES256 --encrypt-key-file=/home/fipar/PERF-31/key.256 --encrypt-threads=$t $* $XB_DIR 
    ts >> timestamps.$tag.log
    [ $TRACE -eq 1 ] && perf script > $tag.perf
    [ $TRACE -eq 2 ] && opreport > $tag.opreport
    echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
    stop_oltp
    stop_collectors
    echo "Done"
 done # for t in ...
}

# compressed
test_compressed()
{
for t in $XB_THREADS; do
    restore_datadir
    tag="compression-threads-$t"
    [ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
    echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
    start_oltp $tag
    start_collectors $tag
    echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
    ts > timestamps.$tag.log
    trace_cmd=""
    [ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
    [ $TRACE -eq 2 ] && opreport > $tag.opreport
    [ $TRACE -eq 3 ] && deferred_pmp $tag &
    $trace_cmd$IB --compress --compress-threads=$t $* $XB_DIR
    ts >> timestamps.$tag.log
    [ $TRACE -eq 1 ] && perf script > $tag.perf
    [ $TRACE -eq 2 ] && opreport > $tag.opreport
    echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
    stop_oltp
    stop_collectors
    echo "Done"
 done # for t in ...
}

test_xbstream_compressed()
{
    for t in $XB_THREADS; do
	restore_datadir
	tag="xbstream_compressed-threads-$t"
	[ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
	echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
	start_oltp $tag
	start_collectors $tag
	echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
	ts > timestamps.$tag.log
	[ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
	[ $TRACE -eq 2 ] && opreport > $tag.opreport
	[ $TRACE -eq 3 ] && deferred_pmp $tag &
	$trace_cmd$IB --compress --compress-threads=$t --stream=xbstream $* ./ > $XB_DIR/backup.$tag.xbstream
	ts >> timestamps.$tag.log
	echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
	stop_oltp
	stop_collectors
	echo "Done"
    done
}

test_xbstream_qpress()
{
    for t in $XB_THREADS; do
	restore_datadir
	tag="xbstream_qpress-threads-$t"
	[ $# -gt 0 ] && tag=$tag$(echo $*|tr ' ' '_')
	echo -n "Sleeping 5 seconds before starting collectors ... "; sleep 5; echo "Done"
	start_oltp $tag
	start_collectors $tag
	echo -n "Sleep 20 seconds before starting backup ..."; sleep 20; echo "Done"
	ts > timestamps.$tag.log
	[ $TRACE -eq 1 ] && trace_cmd="perf record -F 99 -a -g -- "
	[ $TRACE -eq 2 ] && opreport > $tag.opreport
	[ $TRACE -eq 3 ] && deferred_pmp $tag &
	$trace_cmd$IB --stream=xbstream $* ./ | qpress -io -T$t > $XB_DIR/backup.$tag.xbstream
	ts >> timestamps.$tag.log
	echo "Sleeping 10 seconds before stopping collectors ..."; sleep 20
	stop_oltp
	stop_collectors
	echo "Done"
    done
}

# --parallel
# we're using 8 tables in the sbtest database, and innodb_file_per_table
test_parallel()
{
    rm -rf $XB_DIR/*
    for t in $PARALLEL_THREADS; do
	arg="--parallel=$t"
	test_baseline $arg
	test_compressed $arg
	test_encrypted $arg
	test_encrypted_compressed_xbstream $arg
	test_xbstream_qpress $arg
	test_xbstream_compressed $arg
    done # for t in ...
}

test_parallel_only_encrypted_compressed()
{
    rm -rf $XB_DIR/*
    for t in $PARALLEL_THREADS; do
	arg="--parallel=$t"
	test_encrypted_compressed_xbstream $arg
    done # for t in ...
}

test_parallel_only_xbstream()
{
    for t in $PARALLEL_THREADS; do
	arg="--parallel=$t"
	test_xbstream_qpress $arg
	test_xbstream_compressed $arg
    done # for t in ...
}

test_parallel_only_xbstream_qpress()
{
    for t in $PARALLEL_THREADS; do
	arg="--parallel=$t"
	test_xbstream_qpress $arg
    done # for t in ...
}

# based on results, trace tests not using --parallel, and for threads 2 and 4 
test_trace()
{
    SAVED_THREADS=$XB_THREADS
    export PARALLEL_THREADS="1"
    export XB_THREADS="1 2 4"
    export TRACE=3
#    test_baseline
    for t in $PARALLEL_THREADS; do
	arg="--parallel=$t"
	test_compressed $arg
    done
#    test_encrypted
    export TRACE=0
    export XB_THREADS="$SAVED_THREADS"
}

test_du()
{
    SAVED_THREADS=$XB_THREADS
    export PARALLEL_THREADS=1
    export XB_THREADS=1
    export TRACE=0
    test_compressed
    du -hc $XB_DIR
    sleep 5
    test_encrypted
    du -hc $XB_DIR
}
