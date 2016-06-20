#!/bin/bash

# memory scalability - for increasing amounts of memory and cache (10GB increments)
# for 100 threads (obtained as best number from cpu scalability)
# run sysbench mongodb OLTP and OLTP_RW
# test journal compressed / decompressed 
# test ext4 and xfs

DBPATH=/data/sam/mongod/
BACKUPS_PATH=/home/fipar/PERF-22/backups_large/
# actual data dir is under $BACKUPS_PATH/${distribution}_${version}-${engine}/$engine
PID_DIR=/home/fipar/perf-32/
SIZE=60000000
MONGO=/home/fipar/perf-32/mongo/percona-server-mongodb-3.2.4-1.0rc2/bin/mongo
MEMORY_INCREMENT=10
MEMORY_START=20
#MEMORY_MAX=210
MEMORY_MAX=120
SERVER=smblade01
REMOTE_SCRIPT=/home/fipar/perf-32/32_thread_scalability_server.sh

# testing only
#THREADS=1
ulimit -n 4096
total_tests=352
current_test=0
test_duration=240
#test_duration=300
threads=100
fs=ext4
for distribution in uniform pareto; do
    for engine in rocks wt; do
	for workload in oltp oltp_ro; do
	    restored_datadir=0
	    for config in "rocks0:" "wt0:--syncdelay=900 --wiredTigerJournalCompressor=none" "wt1:--syncdelay=900 --wiredTigerJournalCompressor=zlib" "wt2:--syncdelay=900 --wiredTigerJournalCompressor=snappy"; do
		configName=$(echo $config|awk -F: '{print $1}')
		echo $configName|grep $engine>/dev/null || continue 
		[ $engine == "wt" -a "$configName" != "wt2" -a "$workload" == "oltp_ro" ] && continue
		extraArgs=$(echo $config|awk -F: '{print $2}')
		memory=$MEMORY_START
		while [ $memory -le $MEMORY_MAX ]; do
		    cache=$((memory / 2))
		    echo "stop_mongod"; ssh $SERVER "$REMOTE_SCRIPT stop_mongod"
		    if [ "$workload" == "oltp_ro" ]; then
			if [ $restored_datadir -eq 0 ]; then
			    echo "restore_datadir"; ssh $SERVER "$REMOTE_SCRIPT restore_datadir $distribution $engine"
			    restored_datadir=1
			fi # if restored_datadir is 0
		    else
			echo "restore_datadir"; ssh $SERVER "$REMOTE_SCRIPT restore_datadir $distribution $engine"
		    fi # if workload is oltp_ro
		    tag=mem$memory-$engine-$fs-$configName-$distribution-$threads-$workload
		    echo "start dstat"; ssh $SERVER "$REMOTE_SCRIPT start_dstat $tag"
		    echo "start_mongod"; ssh $SERVER "$REMOTE_SCRIPT start_mongod $engine $cache $memory $extraArgs" 
		    current_test=$((current_test+1))
		    kill -s SIGHUP $(pidof mongo-response-time-exporter)
		    echo "Starting sysbench for test $current_test of $total_tests"
		    ./run_sysbench.sh $test_duration $threads $SIZE $distribution $workload $tag run
		    echo "stop dstat"; ssh $SERVER "$REMOTE_SCRIPT stop_dstat"
		    memory=$((memory + MEMORY_INCREMENT))
		done # while memory ...
	    done # for config in ...
	done # for workload in ...
    done # for engine in ...
done # for distribution in ...
