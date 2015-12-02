for i in 50000 25000 10000 5000 2500 1000
do
./sysbench --test=tests/db/update_non_index.lua --oltp_tables_count=32 --mysql-user=root --mysql_table_engine=InnoDB --num-threads=16 --oltp-table-size=${i}000 --rand-type=pareto --rand-init=on --report-interval=10 --mysql-host=db5.cfdmneyqgsom.us-west-2.rds.amazonaws.com --mysql-user=mu --mysql-password=beaxblbe --mysql-db=sbtest --max-time=7200 --max-requests=0 run | tee -a au.${i}.update_non_index.txt
done
