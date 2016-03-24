HOST="--mysql-socket=/tmp/mysql.sock"
#HOST=127.0.0.1
./sysbench --test=tests/db/oltp.lua --oltp_tables_count=100 --oltp_table_size=1000000 --num-threads=100 $HOST --mysql-user=sbtest --oltp-read-only=on --max-time=300 --max-requests=0 --report-interval=10 --rand-type=uniform --rand-init=on run | tee -a res.warmup.ro.txt
OUT="res.mysql55"
mkdir -p res/$OUT
for i in 1 2 3 4 5 6 8 10 13 16 20 25 31 38 46 56 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
#for i in 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
do
time=300
if [ "$i" -gt "10" ]; then
time=300
fi
./sysbench --forced-shutdown=1 --test=tests/db/oltp.lua --oltp_tables_count=100 --oltp_table_size=1000000 --num-threads=${i} $HOST --mysql-user=sbtest --oltp-read-only=on --max-time=$time --max-requests=0 --report-interval=10 --rand-type=uniform --rand-init=on --oltp_skip_trx=on --oltp_distinct_ranges=0 --oltp_order_ranges=0 --oltp_sum_ranges=0 --oltp_simple_ranges=0 --oltp_point_selects=1 run | tee -a res/$OUT/res.thr${i}.ro.txt
done
