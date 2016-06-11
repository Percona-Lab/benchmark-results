#!/bin/bash

pushd ../raw/
echo "profiler,$(env _ONLYHEADER=1 csv_from_sysbench.sh sysbench-oltp-16-run1-profiler-2.txt _file _bench _size _threads)" > ../alldata.csv
for f in sysbench-*txt; do
    threads=$(echo $f|awk -F'-' '{print $3}')
    profiler=$(echo $f|awk -F'-' '{print $6}'|sed 's/\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f _bench 40000 $threads | while read l; do
									echo "$profiler,$l" >> ../alldata.csv
								    done
done
popd
