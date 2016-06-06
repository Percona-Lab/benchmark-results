#!/bin/bash

DBPATH=/data/sam/mongod/
BACKUPS_PATH=/home/fipar/PERF-22/backups_large/
# actual data dir is under $BACKUPS_PATH/${distribution}_${version}-${engine}/$engine
PID_DIR=/home/fipar/perf-32/
SIZE=60000000
MONGO=/home/fipar/perf-32/mongo/percona-server-mongodb-3.2.4-1.0rc2/bin/mongo
MEMORY_INCREMENT=10
MEMORY_START=20
MEMORY_MAX=210
SERVER=smblade01
REMOTE_SCRIPT=/home/fipar/perf-32/32_thread_scalability_server.sh

# testing only
#THREADS=1
ulimit -n 4096
for distribution in uniform pareto; do
    for engine in rocks wt; do
	ssh $SERVER "$REMOTE_SCRIPT stop_mongod"
	ssh $SERVER "$REMOTE_SCRIPT cleanup_datadir"
	ssh $SERVER "$REMOTE_SCRIPT start_mongod $engine 190 0 --slowms=10000"
	./run_sysbench.sh 3600 8 $SIZE $distribution "parallel_prepare" "$engine-$distribution-prepare" run 8
        ssh $SERVER "$REMOTE_SCRIPT stop_mongod" 
        ssh $SERVER "$REMOTE_SCRIPT save_datadir $distribution $engine"
    done # for engine in ...
done # for distribution in ...
