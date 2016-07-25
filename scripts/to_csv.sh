#!/bin/bash

# files for the short benchmarks: sysbench-inmemory-uniform-512-oltp_ro.txt

echo "engine,"$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-inmemory-uniform-512-oltp_ro.txt wt_vs_im 20000000 512) > ../data-short-benchmarks.csv

for engine in inmemory wt; do
    for workload in oltp oltp_ro; do
	for distribution in uniform pareto; do
	    for threads in 512 128 48 32; do
		env _NOHEADER=1 csv_from_sysbench.sh ../raw/sysbench-$engine-$distribution-$threads-$workload.txt $workload 20000000 $threads | while read l; do
																		    echo $engine,$l
																		    done >> ../data-short-benchmarks.csv
	    done # for threads in ...
	done # for distribution in ...
    done # for workload in ...
done # for engine in ...
