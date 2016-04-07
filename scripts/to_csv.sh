#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

for profile in 0 2; do
    env _ONLYHEADER=1 csv_from_sysbench.sh ../raw${VERSION}/sysbench-${FULLVERSION}wt-2000000-1-oltp-profile$profile.txt pl$profile 2000000 1 > ../alldata-pl$profile$VERSION.csv
    for workload in oltp oltp_ro; do
	for f in ../raw${VERSION}/sysbench-${FULLVERSION}wt-*$workload-profile$profile.txt; do 
	    threads=$(echo $f|sed 's/.*2000000-//g'|sed 's/-oltp.*//g')
	    env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads >> ../alldata-pl$profile$VERSION.csv
	done
    done
done
echo "profile_level,$(head -1 ../alldata-pl0$VERSION.csv)" > ../alldata$VERSION.csv
for profile in 0 2; do
   cat ../alldata-pl$profile$VERSION.csv | grep -v workload|while read l; do
				      echo "pl$profile,$l" >> ../alldata$VERSION.csv
   done
done
