#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

test -f ../../cs/raw/sysbench-uniform-psmdb-3.0-rocks-2000000-1-oltp.txt || exit
echo "distribution,version,engine,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../../cs/raw/sysbench-uniform-psmdb-3.0-rocks-2000000-1-oltp.txt _ _ _)" > ../../alldata-cs.csv
for version in "psmdb-3.2" "psmdb-3.0" "upstream-3.0" "upstream-3.2"; do
    for engine in ft wt rocks; do
	for distribution in uniform pareto; do
	    echo $version|grep upstream>/dev/null && [ "$engine" != "wt" ] && continue
	    test -f ../../cs/raw/sysbench-${distribution}-${version}-${engine}-2000000-1-oltp.txt || continue
	    for workload in oltp oltp_ro; do
		for f in ../../cs/raw/sysbench-$distribution-$version-$engine-*$workload.txt; do 
		    threads=$(echo $f|sed 's/.*2000000-//g'|sed 's/-oltp.*//g')
		    env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads | while read l; do
											     echo "$distribution,$version,$engine,$l" >> ../../alldata-cs.csv
											     done
		done
	    done
	done
    done
done
