#!/bin/bash

# files for the short benchmarks: sysbench-ssd-wt-uniform-48-oltp.txt
echo "engine,disk,distribution,"$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-ssd-inmemory-uniform-256-oltp.txt wt_vs_im 20000000 256) > ../data-short-benchmarks.csv

for disk in hdd ssd; do
    for engine in inmemory wt; do
	for workload in oltp insert write_only; do # maybe add insert too
	    for distribution in uniform pareto; do
		for threads in 256 128 48; do
		    env _NOHEADER=1 csv_from_sysbench.sh ../raw/sysbench-$disk-$engine-$distribution-$threads-$workload.txt $workload 20000000 $threads | while read l; do
																			echo $engine,$disk,$distribution,$l
																			done >> ../data-short-benchmarks.csv
		done # for threads in ...
	    done # for distribution in ...
	done # for workload in ...
    done # for engine in ...
done #for disk in ...

# files for the long benchmarks: sysbench-long-inmemory-pareto-128-oltp.txt


echo "engine,distribution,"$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-long-inmemory-pareto-128-oltp.txt wt_vs_im 20000000 512) > ../data-long-benchmarks.csv

for engine in inmemory wt; do
	for distribution in uniform pareto; do
	        threads=128; workload=oltp
		env _NOHEADER=1 csv_from_sysbench.sh ../raw/sysbench-long-$engine-$distribution-$threads-$workload.txt $workload 20000000 $threads | while read l; do
																		    echo $engine,$distribution,$l
																		    done >> ../data-long-benchmarks.csv
	done # for distribution in ...
done # for engine in ...
