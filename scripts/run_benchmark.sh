time=30
for engine in wt; do
restore_datadir()
{
kill -SIGTERM $(pidof mongod)
    echo -n "Waiting for mongod to shutdown ..."
    while [ -n "$(pidof mongod)" ]; do 
       sleep 0.3
    done
    echo " Done"
rm -rf /mnt/i3600/PERF-15/$engine/
'cp' -rv /mnt/storage/PERF-15/3.2-$engine /mnt/i3600/PERF-15/
mv /mnt/i3600/PERF-15/3.2-$engine /mnt/i3600/PERF-15/$engine 
pushd /mnt/storage/PERF-15/fipar/
./transparent_huge_pages.sh disable
env VERSION=$version ./upstream-${engine}.sh --quiet $* &> upstream-${engine}.log &
   echo -n "Waiting for mongod ($engine) to become ready ..."
    while [ $(echo 'db.isMaster()' | /mnt/storage/PERF-15/fipar/mongodb-linux-x86_64-ubuntu1404-3.2.4/bin/mongo 2>/dev/null|grep ismaster|grep -c true) -eq 0 ]; do
       sleep 0.3
    done
    echo " Done"
popd
}
 
    size=2000000
    for threads in 1 4 8 16 32 64 256; do
       for workload in oltp oltp_ro; do
	for extra in "--profile=0 --slowms=100000" "--profile=2 --slowms=0" "--profile=1 --slowms=2"; do
        profile=$(echo $extra|awk '{print $1}'|awk -F'=' '{print $2}')
	echo "Workload: $workload, threads: $threads, engine: $engine"
	echo -n "restoring datadir ..."
	restore_datadir $extra
	echo "Done"
	echo "Starting benchmark"
	    /home/fipar/bin/sysbench \
		--mongo-write-concern=1 \
		--mongo-url="mongodb://localhost" \
		--mongo-database-name=sbtest \
		--test=sysbench/tests/mongodb/$workload.lua \
		--oltp_table_size=$size \
		--oltp_tables_count=16 \
		--num-threads=$threads \
		--report-interval=1 \
		--max-requests=0 \
		--max-time=$time \
		--oltp-point-selects=10 \
		--oltp-simple-ranges=1 \
		--oltp-sum-ranges=1 \
		--oltp-order-ranges=1 \
		--oltp-distinct-ranges=1 \
		--oltp-index-updates=1 \
		--oltp-non-index-updates=1 \
		--oltp-inserts=1 run 2>&1 | tee sysbench-upstream-$engine-$size-$threads-$workload-profile$profile.txt
	 echo "Benchmark complete"
	done
       done
    done
done
