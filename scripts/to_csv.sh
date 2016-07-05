#!/bin/bash 
#This expects csv_from_sysbench from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample file name for this benchmark: 
# raw/thread_scalability/sysbench-rocks-ext4-rocks0-pareto-1-oltp.txt
echo "engine,configuration,distribution,test,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/thread_scalability/sysbench-rocks-ext4-rocks0-pareto-1-oltp.txt _ _ _)" > ../thread_scalability.csv

for f in ../raw/thread_scalability/sysbench*txt; do
    engine=$(echo $f|awk -F'-' '{print $2}')
    configuration=$(echo $f|awk -F'-' '{print $4}')
    distribution=$(echo $f|awk -F'-' '{print $5}')
    threads=$(echo $f|awk -F'-' '{print $6}')
    workload=$(echo $f|awk -F'-' '{print $7}'|sed 's/\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f psfm 60000000 $threads | while read l; do
									 echo "$engine,$configuration,$distribution,$workload,$l" >> ../thread_scalability.csv
								     done
done # for f in ..

# raw/memory_scalability/sysbench-mem20-wt-ext4-wt2-pareto-100-oltp_ro.txt
echo "engine,memory,filesystem,configuration,distribution,test,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/memory_scalability/sysbench-mem20-wt-ext4-wt2-pareto-100-oltp_ro.txt _ _ _)" > ../memory_scalability.csv

for f in ../raw/memory_scalability/sysbench*txt; do
    memory=$(echo $f|awk -F'-' '{print $2}'|sed 's/mem//')
    engine=$(echo $f|awk -F'-' '{print $3}')
    fs=$(echo $f|awk -F'-' '{print $4}')
    config=$(echo $f|awk -F'-' '{print $5}')
    distribution=$(echo $f|awk -F'-' '{print $6}')
    workload=$(echo $f|awk -F'-' '{print $8}'|sed 's/\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f psfm 60000000 100 | while read l; do
								    echo "$engine,$memory,$fs,$config,$distribution,$workload,$l" >> ../memory_scalability.csv
								done 
done # for f in ..


pushd ../raw/memory_scalability/
rm -f mem*csv
for f in mem*; do
    cleanup_dstat.sh $f > $f.csv
done # for f in mem* 
popd

echo "engine,memory,filesystem,configuration,distribution,test,$(head -1 ../raw/memory_scalability/mem60-rocks-ext4-rocks0-pareto-100-oltp_ro.csv)" > ../dstat.csv
for f in ../raw/memory_scalability/mem*csv; do
    memory=$(echo $f|awk -F'-' '{print $1}'|sed 's/.*mem//')
    engine=$(echo $f|awk -F'-' '{print $2}')
    fs=$(echo $f|awk -F'-' '{print $3}')
    config=$(echo $f|awk -F'-' '{print $4}')
    distribution=$(echo $f|awk -F'-' '{print $5}')
    workload=$(echo $f|awk -F'-' '{print $7}'|sed 's/\.csv//')
    grep -v total $f | while read l; do
                           echo "$engine,$memory,$fs,$config,$distribution,$workload,$l" >> ../dstat.csv
                       done
done
