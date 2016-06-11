
mongoc="mongo localhost/sbtest"
sb='./sysbench/sysbench'
testpath='./sysbench/tests'
size=40000
tables=4
time=30
runs=1

prepare()
{
    [ -z "$1" ] && return
    $sb --test="$testpath/mongodb/$1.lua" --max-time=0 --mongo-write-concern=1 --mongo-url='mongodb://localhost' --oltp_tables_count=$tables --mongo-database-name='sbtest' --oltp_table_size=$size prepare
}

cleanup()
{
    [ -z "$1" ] && return
    $sb --test="$testpath/mongodb/$1.lua" --max-time=0 --mongo-write-concern=1 --mongo-url='mongodb://localhost' --oltp_tables_count=$tables --mongo-database-name='sbtest' --oltp_table_size=$size cleanup
}

run()
{
    [ -z "$1" -o -z "$2" ] && return
   $sb --test="$testpath/mongodb/$1.lua" --report-interval=1 --max-requests=10000000 --max-time=$time --oltp_tables_count=$tables --mongo-write-concern=1 --mongo-url='mongodb://localhost' --mongo-database-name='sbtest' --oltp_table_size=$size --num-threads=$2 run
}

profiler()
{
  [ -z "$1" ] && return 
  [ "$1" == "0" ] && $mongoc --eval 'db.setProfilingLevel(0)' || $mongoc --eval 'db.setProfilingLevel(2)'
}


start_collections()
{
    perf record -F 99 -a -g -- sleep $time
}

stop_collections()
{
    sleep 3
    perf script > perf-$1.perf
}

for threads in 1 4 8 16; do
    for workload in oltp; do
	for profiler in 0 2; do
            for run in $(seq $runs); do
		profiler $slowms
		prepare $workload
                echo "running for $threads threads, profiler=$profiler"
		tag=$workload-$threads-run$run-slowms-$profiler
		start_collections &
		run $workload $threads 2>&1 | tee sysbench-$tag.txt
		stop_collections $tag
		cleanup $workload
            done
	done
    done
done

