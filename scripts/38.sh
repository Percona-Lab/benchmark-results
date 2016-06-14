#!/bin/bash
# using: https://github.com/fipar/bash_utils/blob/master/worker_pool.sh

# this prefix will be used to create lock files for individual workers
# a lock file will consist of ${_worker_pool_LOCK_PREFIX}.${RANDOM}
[ -z "$_worker_pool_LOCK_PREFIX" ] && _worker_pool_LOCK_PREFIX=/tmp/worker
# the max number of workers to allow
[ -z "$_worker_pool_WORKERS" ] && _worker_pool_WORKERS=48
# we default to silent mode, only producing output on errors
[ -z "$_worker_pool_VERBOSE" ] && _worker_pool_VERBOSE=0
# when all worker slots are used, this marks how many seconds we should sleep
# before checking again for available slots 
[ -z "$_worker_pool_SLEEP_TIME" ] && _worker_pool_SLEEP_TIME=1

# example usage: 
# . worker_pool.sh
# export _worker_pool_WORKERS=2
# for f in $(ls /some/path); do
#    _worker_pool_start_worker_or_wait_for_slot grep PATTERN /some/path/$f > /tmp/${f}.matches
# done

_worker_pool_worker()
{
    lock=$1
    shift
    eval $* 
    [ $_worker_pool_VERBOSE -gt 0 ] && echo "worker $lock finished"
    rm -f $lock
}

_worker_pool_no_of_running_workers()
{
    ls ${_worker_pool_LOCK_PREFIX}* 2>/dev/null|wc -l
}

_worker_pool_start_worker_or_wait_for_slot()
{
    echoed=0
    while [ $(_worker_pool_no_of_running_workers) -ge $_worker_pool_WORKERS ]; do
	[ $echoed -eq 0 ] && {
	    [ $_worker_pool_VERBOSE -gt 0 ] && echo "all workers in use, will wait for a slot">&2
	    echoed=1
	}
	sleep ${_worker_pool_SLEEP_TIME}
	for f in ${_worker_pool_LOCK_PREFIX}*; do
	    [ "$(ps -p $(cat $f) | wc -l)" -gt 1 ] || {
		[ $_worker_pool_VERBOSE -gt 0 ] && echo "removing orphaned lock $f for worker $(cat $f)"
		rm -f $f # remove lock file if worker is no longer running
	    }
        done
    done
    lock=${_worker_pool_LOCK_PREFIX}.$RANDOM
    touch $lock
    [ $_worker_pool_VERBOSE -gt 0 ] && echo "will start worker $lock: $*"
    _worker_pool_worker $lock $* &
    echo $! > $lock
}

export DATADIR=/mnt/i3600/perf-38
export THREADS="8 16 32 48 64"
export SIZE=1000
export TIME=300
export PID_DIR=/home/fipar/perf-38
export BACKUP_DIR=/mnt/storage/perf-38
export MYSQL_BIN_DIR=$PID_DIR/mysql-5.7.13-linux-glibc2.5-x86_64/bin/

sysbench_cmd()
{
    table_size=$((RANDOM % SIZE + 1))
    [ -z "$1" -o -z "$2" ] && echo "usage: sysbench_cmd <command> <threads> <i># where command is a valid sysbench command like prepare or run, threads is passed on to --num-threads, and i is an integer that is appended to sbtest as the database">&2 && return 1
    sysbench \
	--mysql-host=127.0.0.1 \
	--mysql-user=sbuser \
	--mysql-password=sbuser \
	--report-interval=1 \
	--num-threads=$2 \
	--mysql-db=sbtest$3 \
	--max-requests=999999999 \
	--run-time=$TIME \
	--test=/data/opt/alexey.s/sb2/tests/sysbench-standard/db/oltp.lua \
	--mysql-table-engine=Innodb \
	--oltp_tables_count=100 \
	--oltp_table_size=$table_size $1 
}

stop_mysqld()
{
    mysqladmin -h127.0.0.1 shutdown
}

start_mysqld()
{
    $MYSQL_BIN_DIR/mysqld_safe --defaults-file=/home/fipar/perf-38/my.cnf --datadir=$DATADIR --pid-file=/tmp/mysql.pid &> mysqld_safe.log &
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


wait_for_mysqld()
{
    running=1
    while [ $running -eq 1 ]; do
	mysql -h127.0.0.1 -e 'select @@version' 2>/dev/null && running=0 || sleep 0.3
    done # while $running -eq 1
}

wait_for_mysqld_to_shutdown()
{
    max_wait=3600; wait=0
    while [ -n "$(pidof mysqld)" -a $wait -lt $max_wait ]; do
	sleep 1; wait=$((wait+1))
    done
}

restore_datadir()
{
    stop_mysqld
    rm -rf $DATADIR/* 
    cp -rv $BACKUP_DIR/* $DATADIR 
    start_mysqld
    echo -n "Waiting for mysqld to come up ... "
    wait_for_mysqld
    echo "Done"
}

cleanup_datadir()
{
    rm -rf $DATADIR/*
    pushd $MYSQL_BIN_DIR/../
    $MYSQL_BIN_DIR/mysqld --defaults-file=$PID_DIR/my.cnf --initialize-insecure --datadir=$DATADIR #--user=mysql
    popd
}

backup_datadir()
{
    stop_mysqld
    wait_for_mysqld_to_shutdown
    rm -rf $BACKUP_DIR/*
    cp -rv $DATADIR/* $BACKUP_DIR/
}


restart_mysqld()
{
    stop_mysqld
    wait_for_mysqld_to_shutdown
    start_mysqld
    echo -n "Waiting for mysqld to come up ... "
    wait_for_mysqld
    echo "Done"
}

ts()
{
    date "+%s"
}


export SCHEMAS=40000
prepare()
{
    restart_mysqld
    i=0
    mysql -e "grant all on *.* to 'sbuser'@'localhost' identified by 'sbuser'"
    echo "Creating $SCHEMAS schemas ..."
    while [ $i -lt $SCHEMAS ]; do
	mysql -e "create database sbtest$i; grant all on sbtest$i to 'sbuser'@'localhost' identified by 'sbuser'"
	_worker_pool_start_worker_or_wait_for_slot sysbench_cmd prepare 1 $i
	i=$((i+1))
    done # while $i -lt $SCHEMAS
    echo "Done"
    
   sysbench_cmd prepare
}


