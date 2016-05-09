#!/bin/bash 
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample file name for this benchmark: 
# sysbench-PERF22_20-uniform-upstream-3.2-wt-60000000-32-oltp.txt
echo "version,memory,engine,distribution,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/wt_reruns/sysbench-PERF22_20-uniform-upstream-3.2-wt-60000000-48-oltp.txt psfm 60000000 1)" > ../wt_reruns.csv

for memory in 20; do
    for distribution in uniform pareto; do
	for engine in wt ; do
	    for workload in oltp oltp_ro; do
		for version in upstream-3.2; do
		    for f in ../raw/wt_reruns/sysbench-PERF22_${memory}-$distribution-$version-$engine-60000000-*$workload.txt; do
			threads=$(echo $f|sed 's/.*60000000-//g'|sed 's/-oltp.*//g')
			[ -f $f ] || continue
			env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads | while read l; do
												echo "$version,$memory,$engine,$distribution,$l" >> ../wt_reruns.csv
												done
		    done
		done
	    done
	done
    done
done
