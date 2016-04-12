#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

for version in "" "3.0"; do
    for engine in ft wt rocks; do
	env _ONLYHEADER=1 csv_from_sysbench.sh ../raw${version}/sysbench-${engine}-2000000-1-oltp.txt psfm 2000000 1 > ../alldata-${engine}${version}.csv
	for workload in oltp oltp_ro; do
	    for f in ../raw${version}/sysbench-$engine-*$workload.txt; do 
		threads=$(echo $f|sed 's/.*2000000-//g'|sed 's/-oltp.*//g')
		env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads >> ../alldata-${engine}${version}.csv
	    done
	done
    done
    echo "engine,$(head -1 ../alldata-ft.csv)" > ../alldata${version}.csv
    for engine in ft wt rocks; do
       cat ../alldata-${engine}${version}.csv | grep -v workload|while read l; do
					  echo "$engine,$l" >> ../alldata${version}.csv
       done
    done
done

echo "version,engine_and_version,$(head -1 ../alldata.csv)" > ../alldata-bothversions.csv
for f in ../alldata.csv ../alldata3.0.csv; do
    version=3.2 
    if [ "$f" == "../alldata3.0.csv" ]; then
	version=3.0
    fi
    cat $f | grep -v workload|while read l; do
				  engine=$(echo $l|awk -F, '{print $1}')
				  echo "$version,$engine$version,$l" >> ../alldata-bothversions.csv
    done
done
