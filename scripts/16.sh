
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
  $mongoc --eval "db.setProfilingLevel($1)"
}


start_collections()
{
for x in $(seq 1 1000)
  do
    ./quickstack -p $(pidof mongod)
    sleep 0.1 
  done | grep -v '^2016-' 
}

aggregate_stack_trackes()
{
 awk '
   BEGIN { s = ""; } 
   /^Thread/ { print s; s = ""; } 
   /^\#/ { if (s != "" ) { s = s "," $4} else { s = $4 } } 
   END { print s }' | \
 sort | uniq -c | sort -r -n -k 1,1
}

stop_collections()
{
    :
}

for run in $(seq $runs); do
    for profiler in 0 2; do
	profiler $profiler
	prepare oltp
	tag=detailed_oltp-16-run$run-profiler-$profiler
	(start_collections > stacks-$tag.txt) & 
	run oltp 16 2>&1 | tee sysbench-$tag.txt
	stop_collections $tag
	cleanup oltp
    done
done
