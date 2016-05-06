#!/bin/bash
[ -z "$1" ] && echo "No mongo path specified">&2 && exit 1
[ -z "$2" ] && echo "No backup datadir path specified">&2 && exit 1
[ -z "$engine" ] && echo "engine not set">&2 && exit 1
[ -z "$cachesize" ] && echo "cachesize not set">&2 && exit 1
[ -n "$(pidof mongod)" ] && kill $(pidof mongod)
    i=0
    echo -n "Waiting for mongod to shutdown ..."
    while [ -n "$(pidof mongod)" -a $i -lt 20 ]; do 
       sleep 0.3; i=$((i+1))
    done
    [ $i -ge 20 ] && kill -9 $(pidof mongod)
    echo " Done"
rm -rf /PERF-22/*
'cp' -rv /home/fipar/PERF-22/backups_large/$2/$engine /PERF-22/
pushd /home/fipar/PERF-22/
[ "$engine" == "ft" ] && /home/fipar/PERF-22/transparent_huge_pages.sh disable || /home/fipar/PERF-22/transparent_huge_pages.sh enable
echo "starting from $1"
export MONGO_PATH=$1
[ $i -ge 20 ] && sleep 120 #sleep if SIGKILL was used, as otherwise it may fail to bind to the socket
export DATADIR=/PERF-22/
nohup /home/fipar/PERF-22/start-$engine-22.sh $cachesize --quiet --slowms=100000000 &> $engine.log &
   echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | /home/fipar/PERF-22/$1/bin/mongo 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
       sleep 0.3
    done
    echo " Done"
popd
