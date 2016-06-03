HOST="--mysql-socket=/tmp/mysql.sock"
MYSQLDIR=/opt/vadim/bin/percona-server-mongodb-3.2.4-1.0rc2
#DATADIR=/data/opt/data/tpcc1000
#DATADIR=/data/sam/mongo
DATADIR=/data/sam/mongorocks
CONFIG=/etc/my.ps57.cnf

startmongo(){
  pushd $MYSQLDIR
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  #LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1 
  #numactl --interleave=all bin/mongod --dbpath=$DATADIR --wiredTigerCacheSizeGB=${BP}
  numactl --interleave=all bin/mongod --dbpath=$DATADIR --storageEngine=rocksdb --config=bin/rocks.conf --rocksdbCacheSizeGB=${BP}
}

shutdownmongo(){
  echo "Shutting mongod down..."
  $MYSQLDIR/bin/mongo --eval "db.getSiblingDB('admin').shutdownServer()"
}

waitmongo(){
        set +e

        while true;
        do
                $MYSQLDIR/bin/mongo --eval "printjson(db.serverStatus())"

                if [ "$?" -eq 0 ]
                then
                        break
                fi

                sleep 30

                echo -n "."
        done
        set -e
}

initialstat(){
  $MYSQLDIR/bin/mysqladmin variables > $OUTDIR/mysqlvariables.txt
  cp $CONFIG $OUTDIR
  cp config.sh $OUTDIR
  cp $0 $OUTDIR
}

collect_mysql_stats(){
  $MYSQLDIR/bin/mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
  PIDMYSQLSTAT=$!
}
collect_dstat_stats(){
  dstat --output=$OUTDIR/dstat.txt 10 > $OUTDIR/dstat.out &
  PIDDSTATSTAT=$!
}
