HOSTN=10.0.0.65
#au8xclust.cluster-cfdmneyqgsom.us-west-2.rds.amazonaws.com
#for i in 250000 125000 64000 32000 16000 8000 4000
for i in 64000 32000 16000 8000 4000
do
#for t in 16 30 100 250 500 1000 2000 4000 8000 
for t in 2000 4000 8000 
do
rm -f au.sz${i}.thr${t}.oltp.txt
./sysbench --test=tests/db/oltp.lua --oltp_tables_count=64 --mysql-user=root --mysql_table_engine=InnoDB --num-threads=$t --oltp-table-size=${i}000 --rand-type=pareto --rand-init=on --report-interval=10 --mysql-host=$HOSTN --mysql-user=mu --mysql-password=percona00 --mysql-db=sb --max-time=3600 --max-requests=0 --report-interval=10 --mysql-ignore-errors=1030,1213 run | tee -a au.sz${i}.thr${t}.oltp.txt
done
done
