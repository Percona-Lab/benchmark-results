#!/bin/bash 
#This expects csv_from_sysbench from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample file name for this benchmark: 
# raw/thread_scalability/sysbench-rocks-ext4-rocks0-pareto-1-oltp.txt
echo "engine,configuration,distribution,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/thread_scalability/sysbench-rocks-ext4-rocks0-pareto-1-oltp.txt _ _ _)" > ../thread_scalability.csv

THREADS="1 3 5 8 13 20 31 46 68 100 145 210 300 430 630 870 1000 1200"

for workload in oltp oltp_ro; do
    for distribution in uniform pareto; do
	for engine in wt rocks; do
	    for threads in $THREADS; do
		for configuration in rocks0 wt0 wt1 wt2; do
		    echo $configuration|grep $engine>/dev/null || continue
		    for f in ../raw/thread_scalability/sysbench-$engine-ext4-$configuration-$distribution-$threads-$workload.txt; do
			env _NOHEADER=1 csv_from_sysbench.sh $f psfm 60000000 $threads | while read l; do
												echo "$engine,$configuration,$distribution,$l" >> ../thread_scalability.csv
												done
		    done # for f in ../raw
		done # for configuration
	    done # for threads
	done # for engine
    done # for distribution
done #for workload
