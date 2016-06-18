#!/bin/bash 
#This expects csv_from_sysbench from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample file name for this benchmark: 

#i identifies the repeat number
i=2
# raw/repeats/memory_scalability/$i/sysbench-mem200-wt-ext4-wt2-pareto-100-oltp_ro.txt
echo "engine,memory,filesystem,configuration,distribution,test,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/repeats/memory_scalability/$i/sysbench-mem200-wt-ext4-wt2-pareto-100-oltp_ro.txt _ _ _)" > ../repeats_memory_scalability.csv

for f in ../raw/repeats/memory_scalability/$i/sysbench*txt; do
    memory=$(echo $f|awk -F'-' '{print $2}'|sed 's/mem//')
    engine=$(echo $f|awk -F'-' '{print $3}')
    fs=$(echo $f|awk -F'-' '{print $4}')
    config=$(echo $f|awk -F'-' '{print $5}')
    distribution=$(echo $f|awk -F'-' '{print $6}')
    workload=$(echo $f|awk -F'-' '{print $8}'|sed 's/\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f psfm 60000000 100 | while read l; do
								    echo "$engine,$memory,$fs,$config,$distribution,$workload,$l" >> ../repeats_memory_scalability.csv
								done 
done # for f in ..

echo "engine,memory,filesystem,configuration,distribution,test,$(head -1 ../raw/repeats/memory_scalability/$i/dstat-mem60-rocks-ext4-rocks0-pareto-100-oltp_ro.csv)" > ../repeats_dstat.csv
for f in ../raw/repeats/memory_scalability/$i/dstat*csv; do
    memory=$(echo $f|awk -F'-' '{print $2}'|sed 's/mem//')
    engine=$(echo $f|awk -F'-' '{print $3}')
    fs=$(echo $f|awk -F'-' '{print $4}')
    config=$(echo $f|awk -F'-' '{print $5}')
    distribution=$(echo $f|awk -F'-' '{print $6}')
    workload=$(echo $f|awk -F'-' '{print $8}'|sed 's/\.csv//')
    grep -v total $f | while read l; do
			   echo "$engine,$memory,$fs,$config,$distribution,$workload,$l" >> ../repeats_dstat.csv
		       done
done
# for f in ../raw/repeats/memory_scalability/$i/dstat*csv; do
#     of=$(basename $(echo $f|sed 's/csv$/png/g'))
#     env _INPUT_FILE=$f _OUTPUT_FILE=$of _X_AXIS="rownames(data)" _X_AXIS_LABEL="rownames" _Y_AXIS=dsk.total _Y_AXIS_LABEL="dsk.total" _GRAPH_TITLE="disk stats ($f)" csv_to_png.sh
# done
