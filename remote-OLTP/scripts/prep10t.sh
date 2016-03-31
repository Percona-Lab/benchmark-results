#for i in 1 `seq 2 2 200`
#do
#./sysbench --test=tests/db/oltp.lua --oltp_tables_count=100 --oltp_table_size=1000000 --num-threads=${i} --mysql-host=172.16.0.4 --mysql-user=sbtest --oltp-read-only=on --max-time=300 --max-requests=0 --report-interval=10 --rand-type=uniform --rand-init=on run | tee -a res.${i}.ro.txt
#done
#./sysbench --test=tests/db/parallel_prepare.lua --oltp_tables_count=100 --oltp_table_size=1000000 --num-threads=25 --mysql-host=172.16.0.4 --mysql-user=sbtest --oltp-read-only=on --report-interval=10 --rand-type=uniform --rand-init=on run
./sysbench --test=tests/db/parallel_prepare.lua --oltp_tables_count=10 --oltp_table_size=10000000 --num-threads=10 --max-requests=10 --mysql-host=172.16.0.4 --mysql-user=sbtest --mysql-db=sbtest10t --oltp-read-only=on --report-interval=10 --rand-type=pareto --rand-init=on run
#./sysbench --test=tests/db/parallel_prepare.lua --oltp_tables_count=8 --oltp_table_size=10000000 --num-threads=8 --mysql-host=172.16.0.4 --mysql-user=sbtest --oltp-read-only=on --max-time=1800 --max-requests=0 --report-interval=10 run
#./sysbench --test=/opt/tests/db/oltp.lua --oltp_tables_count=8 --oltp_table_size=10000000 --num-threads=16 --mysql-host=172.16.0.4 --mysql-user=sbtest --oltp-read-only=on --max-time=1800 --max-requests=0 --report-interval=10 run
