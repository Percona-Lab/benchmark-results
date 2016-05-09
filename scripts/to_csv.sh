#!/bin/bash 
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample file name for this benchmark: 
# sysbench-iobound-1000-pareto-psfm32-rocks-60000000-1-ranges_ro.txt
echo "workload,range_size,engine,distribution,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-iobound-1000-pareto-psfm32-rocks-60000000-1-ranges_ro.txt psfm 60000000 1)" > ../alldata.csv

for workload in iobound iobound_heavy cpubound; do
    for distribution in uniform pareto; do
	for engine in wt rocks; do
	    for range_size in 1000 10000; do
		for f in ../raw/sysbench-$workload-$range_size-$distribution-psfm32-$engine-*; do
		    threads=$(echo $f|sed 's/.*60000000-//g'|sed 's/-ranges.*//g')
		    [ -f $f ] || continue
		    env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads | while read l; do
											    echo "$workload,$range_size,$engine,$distribution,$l" >> ../alldata.csv
											    done
		done
	    done
	done
    done
done
