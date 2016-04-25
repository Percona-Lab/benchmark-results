#!/bin/bash 
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

echo "engine,distribution,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-pareto-psmdb-3.2-wt-10000000-1-oltp.txt psfm 10000000 1)" > ../alldata.csv

for distribution in uniform pareto; do
    for engine in wt rocks ft; do
	for workload in oltp oltp_ro; do
	    for f in ../raw/sysbench-$distribution-psmdb-3.2-$engine-*$workload.txt; do 
		threads=$(echo $f|sed 's/.*10000000-//g'|sed 's/-oltp.*//g')
		[ -f $f ] || continue
		env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads | while read l; do
											 echo "$engine,$distribution,$l" >> ../alldata.csv
											 done
	    done
	done
    done
done

