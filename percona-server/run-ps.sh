for t in oltp update_index update_non_index
do
for i in 50000 25000 10000 5000 2500 1000
do
./sysbench --test=tests/db/${t}.lua --oltp_tables_count=32 --mysql-user=root --mysql_table_engine=InnoDB --num-threads=16 --oltp-table-size=${i}000 --rand-type=pareto --rand-init=on --report-interval=10 --mysql-host=10.0.0.250 --mysql-user=sbtest --mysql-db=sbtest --max-time=7200 --max-requests=0 run | tee -a ps.${i}.${t}.io2000.txt
done
done
