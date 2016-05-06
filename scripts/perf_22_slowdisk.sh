time=1800
experiment=0
experiments=624
size=60000000
for cgroup in PERF22_20 PERF22_40; do
    for engine in ft wt rocks; do 
	for paths in "mongodb-linux-x86_64-ubuntu1404-3.2.4:uniform_3.2-$engine" "mongodb-linux-x86_64-ubuntu1404-3.2.4:pareto_3.2-$engine" "percona-server-mongodb-3.2.4-1.0-rc2-snappy:uniform_3.2-$engine" "percona-server-mongodb-3.2.4-1.0-rc2-snappy:pareto_3.2-$engine"; do 
	    for threads in 512 128 48 32 16 4 1; do 
		experiment=$((experiment+1))
		cachememory=20
		[ "$cgroup" == "PERF22_20" ] && cachememory=10
		path="mongo/$(echo $paths|awk -F: '{print $1}')"
		distribution=uniform
		echo $paths|grep pareto>/dev/null && distribution=pareto
		datapath=$(echo $paths|awk -F: '{print $2}')
		echo $path|grep 'mongodb-linux'>/dev/null && [ "$engine" != "wt" ] && continue
		server="psmdb"
		echo $path|grep 'mongodb-linux'>/dev/null && server="upstream"
		for workload in oltp oltp_ro; do
		    version=3.0
		    echo $path | grep 3.2>/dev/null && version=3.2 
		    echo "Workload: $workload, threads: $threads, engine: $engine, time: $time"
		    echo -n "restoring datadir ..."
		    ssh smblade04 "sudo env engine=$engine cachesize=$cachememory /home/fipar/PERF-22/restore_datadir_22_slowdisk.sh $path $datapath"
		    ssh smblade04 "sudo cgclassify -g memory:$cgroup \$(pidof mongod)"
		    echo "Done"
		    echo "Sending SIGHUP to mongo-response-time-exporter"
		    ssh smblade04 "sudo kill -s SIGHUP $(pidof mongo-response-time-exporter)"
		    echo -n "Waiting 30 seconds before starting experiment $experiment of $experiments... "
		    sleep 30
		    echo "Done"
		    echo "Starting benchmark"
		    /home/fipar/bin/sysbench \
			--mongo-write-concern=1 \
			--mongo-url="mongodb://smblade04" \
			--mongo-database-name=sbtest \
			--test=sysbench/sysbench/tests/mongodb/$workload.lua \
			--oltp_table_size=$size \
			--oltp_tables_count=16 \
			--num-threads=$threads \
			--rand-type=$distribution \
			--report-interval=10 \
			--max-requests=0 \
			--max-time=$time \
			--oltp-point-selects=10 \
			--oltp-simple-ranges=1 \
			--oltp-sum-ranges=1 \
			--oltp-order-ranges=1 \
			--oltp-distinct-ranges=1 \
			--oltp-index-updates=1 \
			--oltp-non-index-updates=1 \
			--oltp-inserts=1 run 2>&1 | tee sysbench-$cgroup-$distribution-$server-$version-$engine-$size-$threads-$workload.txt
		    echo "Benchmark complete ($experiment of $experiments)"
		done
	    done
	done
    done
done

