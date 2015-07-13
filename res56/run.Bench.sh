#!/bin/sh
set -u
set -x
set -e

ulimit -c unlimited
ulimit -n 1000000


SERVER="10.11.12.220"
RT=3600
DATADIR="/data/bench/mongodir/mongo"
#MONGODIR="/data/bench/vadim/mango/rocks/mongo"
#MONGODIR="/data/bench/vadim/mango/tokumx-2.0.1-linux-x86_64/bin"
MONGODIR="/data/bench/vadim/mango/pre-lock/rc6/percona-tokumxse-3.0.3-1.0-rc.6/bin"

#MONGODIR="/data/bench/vadim/mango/lock-fix/"

# restore from backup

function StartMongo {

echo "Starting mongod..."

#$MONGODIR/mongod --dbpath=$DATADIR --logpath=$1/server.log &
#$MONGODIR/mongod --dbpath=$DATADIR --storageEngine=wiredTiger --wiredTigerCacheSizeGB=32  --wiredTigerJournalCompressor=none --syncdelay=900 --logpath=$1/server.log &
#$MONGODIR/mongod --dbpath=$DATADIR --storageEngine=rocksdb --rocksdbCacheSizeGB=32 --logpath=$1/server.log &
$MONGODIR/mongod --dbpath=$DATADIR  --logpath=$1/server.log --storageEngine=tokuft --tokuftCollectionReadPageSize=16384 --tokuftCollectionCompression=quicklz --tokuftCollectionFanout=128 --tokuftIndexReadPageSize=16384 --tokuftIndexCompression=quicklz --tokuftIndexFanout=128 --tokuftEngineCacheSize=$(( 17179869184*2 )) --syncdelay=900 &
#$MONGODIR/mongod --dbpath=$DATADIR --setParameter="defaultCompression=quicklz" --setParameter="defaultFanout=128" --setParameter="defaultReadPageSize=16384" --setParameter="fastUpdates=true" --cacheSize=32G --checkpointPeriod=900 --logpath=$1/server.log &


set +e

while true;
do
$MONGODIR/mongo --eval "db.stats()" 

if [ "$?" -eq 0 ]
then
  break
fi

sleep 30

echo -n "."
done

set -e

cgclassify -g memory:DBLimitedGroup `pidof mongod`

}


# Determine run number for selecting an output directory
RUN_NUMBER=-1

if [ -f ".run_number" ]; then
  read RUN_NUMBER < .run_number
fi

if [ $RUN_NUMBER -eq -1 ]; then
        RUN_NUMBER=0
fi

OUTDIR=res$RUN_NUMBER
mkdir -p $OUTDIR

StartMongo $OUTDIR

RUN_NUMBER=`expr $RUN_NUMBER + 1`
echo $RUN_NUMBER > .run_number

runid="par640"

PIDS=()
iostat -dmx 10 >> $OUTDIR/iostat.$runid.res &
PIDS+=($!) 
dstat -t -v --nocolor 10 > $OUTDIR/dstat_plain.$runid.res  &
PIDS+=($!) 

cp $0 $OUTDIR

#./innodb_stat.sh $RT $SERVER $PORT >> $OUTDIR/innodb.${runid}.$i.res &
#./tpcc_start -h $SERVER -P $PORT -d tpcc$WH -u root -p "" -w $WH -c $par -r 10 -l $RT | tee -a $OUTDIR/tpcc.${runid}.$i.out 
echo "Running..."
bash run.simple.bash config.bash $OUTDIR | tee -a $OUTDIR/script.out.txt


echo "Killing stats"
for var in "${PIDS[@]}"
do
  kill -9 $var
done

echo "Stop mongod"
$MONGODIR/mongo --eval "db.getSiblingDB('admin').shutdownServer()"

