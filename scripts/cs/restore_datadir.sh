#!/bin/bash
[ -z "$1" ] && echo "No mongo path specified">&2 && exit 1
[ -z "$2" ] && echo "No backup datadir path specified">&2 && exit 1
[ -z "$engine" ] && echo "engine not set">&2 && exit 1
[ -n "$(pidof mongod)" ] && kill $(pidof mongod)
    echo -n "Waiting for mongod to shutdown ..."
    while [ -n "$(pidof mongod)" ]; do 
       sleep 0.3
    done
    echo " Done"
rm -rf /data/sam/PERF-22/$engine/
'cp' -rv /home/fipar/PERF-22/backups/$2/$engine /data/sam/PERF-22/
pushd /home/fipar/PERF-22/
[ "$engine" == "ft" ] && /home/fipar/PERF-22/transparent_huge_pages.sh disable || /home/fipar/PERF-22/transparent_huge_pages.sh enable
env MONGO_PATH=$1 nohup /home/fipar/PERF-22/start-$engine.sh --quiet --slowms=100000000 &> $engine.log &
   echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | /home/fipar/PERF-22/$1/bin/mongo 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
       sleep 0.3
    done
    echo " Done"
popd
