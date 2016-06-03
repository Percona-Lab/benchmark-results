source config.sh
DB="sbtest"
DIR=res-OLTP-RW-memory-disk-samsung-8t-rocks

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# cycle by buffer pool size

for BP in `seq 4 8 200`
#for BP in `seq 142 8 150`
do

startmongo &
sleep 10
waitmongo

cgcreate -g memory:DBLimitedGroup
echo $(( $BP * 2 ))G > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
cgclassify -g memory:DBLimitedGroup `pidof mongod`

runid="mongowt.BP${BP}"

# perform warmup
./sysbench --test=tests/mongodb/oltp.lua --oltp_tables_count=8 --oltp_table_size=60000000 --num-threads=100 $HOST --mysql-user=sbtest --oltp-point-selects=10 --oltp-simple-ranges=1 --oltp-sum-ranges=1 --oltp-order-ranges=1  --oltp-distinct-ranges=1  --oltp-index-updates=0  --oltp-non-index-updates=0  --oltp-inserts=0 --oltp-read-only=on --max-time=600 --max-requests=0 --report-interval=10 --rand-type=uniform --rand-init=on --mongo-url="mongodb://localhost" --mongo-database-name=$DB  run | tee -a res.warmup.ro.txt

#for i in 1 2 4 6 10 106 25 38 56 82 120 175 250 360
#for i in 4 6 10 16 25 38 56 82 120 175
#for i in 56 82 120 
for i in 14 28 56 84 112 140
do

        OUTDIR=$DIR/$runid/thr$i
        mkdir -p $OUTDIR

        echo "{\"cache-size\":$BP,\"user-threads\":$i}\"" > $OUTDIR/runparam.json
        echo "====== Running BP: $BP, Threads: $i ========"

        # start stats collection
        #initialstat
        collect_dstat_stats 

        time=300
        ./sysbench --test=tests/mongodb/oltp.lua --oltp_tables_count=8 --oltp_table_size=60000000 --num-threads=$i --oltp-point-selects=10  --oltp-simple-ranges=1  --oltp-sum-ranges=1  --oltp-order-ranges=1  --oltp-distinct-ranges=1  --oltp-index-updates=1  --oltp-non-index-updates=1  --oltp-inserts=1 --oltp-read-only=on --max-time=$time --max-requests=0 --report-interval=10 --rand-type=uniform --rand-init=on --mongo-url="mongodb://localhost" --mongo-database-name=$DB  run | tee -a $OUTDIR/res.txt

        # kill stats
        set +e
        kill $PIDDSTATSTAT
        set -e

        sleep 30
done

shutdownmongo

done
