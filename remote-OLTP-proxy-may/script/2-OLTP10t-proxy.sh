HOST="--mysql-socket=/tmp/proxysql.sock"
#HOST="--mysql-socket=/tmp/max.sock"
#HOST="--mysql-host=127.0.0.1"
#HOST=127.0.0.1
./sysbench --test=tests/db/oltp.lua --oltp_tables_count=10 --oltp_table_size=10000000 --num-threads=100 $HOST --mysql-user=root --mysql-password=root --oltp-read-only=on --max-time=300 --max-requests=0 --report-interval=10 --rand-type=pareto --rand-init=on --mysql-db=sbtest10t run | tee -a res.warmup.ro.txt
OUT="res.mysql57.proxysql.16thr.fast-forwars"
mkdir -p res-OLTP10t/$OUT
for i in 1 2 3 4 5 6 8 10 13 16 20 25 31 38 46 56 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
#for i in 300 360 430 520 630 750 870 1000
#for i in 1 3 5 8 13 20 31 46 68 100 145 210 300 430 630 870 1000
#for i in  520
do
time=600
if [ "$i" -gt "10" ]; then
time=600
fi
./sysbench --forced-shutdown=1 --test=tests/db/oltp.lua --oltp_tables_count=10 --oltp_table_size=10000000 --num-threads=${i} $HOST --mysql-user=root --mysql-password=root --mysql-db=sbtest10t --oltp-read-only=on --max-time=$time --max-requests=0 --report-interval=10 --rand-type=pareto --rand-init=on run | tee -a res-OLTP10t/$OUT/res.thr${i}.ro.txt
sleep 30
done
