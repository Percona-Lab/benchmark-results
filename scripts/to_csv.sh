#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

for version in "" "3.0" "upstream-3.0" "upstream-3.2"; do
    for engine in ft wt rocks; do
	echo $version|grep upstream>/dev/null && [ "$engine" != "wt" ] && continue
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
       echo $version|grep upstream>/dev/null && [ "$engine" != "wt" ] && continue
       cat ../alldata-${engine}${version}.csv | grep -v workload|while read l; do
					  echo "$engine,$l" >> ../alldata${version}.csv
       done
    done
done

echo "distribution,version,engine,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../rawpareto/sysbench-psmdb-3.0-ft-2000000-1-oltp.txt psfm 2000000 1)" > ../alldata-pareto.csv
for version in psmdb-3.0 psmdb-3.2 upstream-3.0 upstream-3.2; do
    for engine in ft wt rocks; do
	echo $version|grep upstream>/dev/null && [ "$engine" != "wt" ] && continue
	for workload in oltp oltp_ro; do
	    for f in ../rawpareto/sysbench-$version-$engine-*$workload.txt; do
		threads=$(echo $f|sed 's/.*2000000-//g'|sed 's/-oltp.*//g')
		env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads | while read l; do
											    echo "pareto,$version,$engine,$l" >> ../alldata-pareto.csv
											 done
	    done
	done
    done
done 

# echo "version,engine_and_version,$(head -1 ../alldata.csv)" > ../alldata-bothversions.csv
# for f in ../alldata.csv ../alldata3.0.csv ../alldataupstream-3.0.csv ../alldataupstream-3.2.csv; do
#     version=NA
#     case $f in
# 	"../alldata.csv")
# 	    version="psmdb3.2";;
# 	"../alldata3.0.csv")
# 	    version="psmdb3.0";;
# 	"../alldataupstream-3.0.csv")
# 	    version="upstream3.0";;
# 	"../alldataupstream-3.2.csv")
# 	    version="upstream3.2";
#     esac
#     cat $f | grep -v workload|while read l; do
# 				  engine=$(echo $l|awk -F, '{print $1}')
# 				  echo "$version,${engine}_${version},$l" >> ../alldata-bothversions.csv
#     done
# done

echo "distribution,version,$(head -1 ../alldata.csv)" > ../alldata-bothversions.csv
for f in ../alldata.csv ../alldata3.0.csv ../alldataupstream-3.0.csv ../alldataupstream-3.2.csv; do
    version=NA
    case $f in
	"../alldata.csv")
	    version="psmdb-3.2";;
	"../alldata3.0.csv")
	    version="psmdb-3.0";;
	"../alldataupstream-3.0.csv")
	    version="upstream-3.0";;
	"../alldataupstream-3.2.csv")
	    version="upstream-3.2";
    esac
    cat $f| while read l; do 
		echo "uniform,$version,$l" >> ../alldata-bothversions.csv
    done
done

head -1 ../alldata-bothversions.csv > ../alldata-bothversions-bothdistributions.csv
cat ../alldata-bothversions.csv ../alldata-pareto.csv | grep -v user_provided_threads >> ../alldata-bothversions-bothdistributions.csv
