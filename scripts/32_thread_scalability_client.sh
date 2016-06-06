#!/bin/bash

# threads scalability - for data fitting into memory (cache size 210GB)
# run in range of threads 1 3 5 8 13 20 31 46 68 100 145 210 300 430 630 870 1000 1200 
# run sysbench mongodb OLTP and OLTP_RW

DBPATH=/data/sam/mongod/
BACKUPS_PATH=/home/fipar/PERF-22/backups_large/
# actual data dir is under $BACKUPS_PATH/${distribution}_${version}-${engine}/$engine
PID_DIR=/home/fipar/perf-32/
SIZE=60000000
MONGO=/home/fipar/perf-32/mongo/percona-server-mongodb-3.2.4-1.0rc2/bin/mongo
THREADS="1200 1000 870 630 430 300 210 145 100 68 46 31 20 13 8 5 3 1"
SERVER=smblade01
REMOTE_SCRIPT=/home/fipar/perf-32/32_thread_scalability_server.sh

# testing only
#THREADS=1
ulimit -n 4096
total_tests=144
current_test=0
test_duration=300
fs=ext4
for distribution in uniform pareto; do
    for engine in wt rocks; do
	for workload in oltp oltp_ro; do
	    restored_datadir=0
	    for threads in $THREADS; do
		for config in "rocks0:" "wt0:--syncdelay=900 --wiredTigerJournalCompressor=none" "wt1:--syncdelay=900 --wiredTigerJournalCompressor=zlib" "wt2:--syncdelay=900 --wiredTigerJournalCompressor=snappy"; do
		    configName=$(echo $config|awk -F: '{print $1}')
		    echo $configName|grep $engine>/dev/null || continue 
		    extraArgs=$(echo $config|awk -F: '{print $2}')
		    echo "stop_mongod"; ssh $SERVER "$REMOTE_SCRIPT stop_mongod"
		    if [ "$workload" == "oltp_ro" ]; then
			if [ $restored_datadir -eq 0 ]; then
			    echo "restore_datadir"; ssh $SERVER "$REMOTE_SCRIPT restore_datadir $distribution $engine"
			    restored_datadir=1
			fi # if restored_datadir is 0
		    else
			echo "restore_datadir"; ssh $SERVER "$REMOTE_SCRIPT restore_datadir $distribution $engine"
		    fi # if workload is oltp_ro
		    echo "start_mongod"; ssh $SERVER "$REMOTE_SCRIPT start_mongod $engine 210 0 $extraArgs" 
		    tag=$engine-$fs-$configName-$distribution-$threads-$workload
		    current_test=$((current_test+1))
		    if [ "$THREADS" != "1" ]; then
			echo "sending SIGHUP to mongo-response-time-exporter and waiting 30 seconds"
			sleep 30
		    fi
		    echo "Starting sysbench for test $current_test of $total_tests"
		    ./run_sysbench.sh $test_duration $threads $SIZE $distribution $workload $tag run
		done # for config in ...
	    done # for threads in ... 
	done # for workload in ...
    done # for engine in ...
done # for distribution in ...
