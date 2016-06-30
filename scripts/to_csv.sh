#!/bin/bash

echo "test,threads,active_schemas,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-gt-850-20000-res.txt _ _ _)" > ../alldata.csv

for f in ../raw/sys*res.txt; do
    test=$(echo $f|awk -F'-' '{print $2}')
    threads=$(echo $f|awk -F'-' '{print $3}')
    active_schemas=$(echo $f|awk -F'-' '{print $4}'|sed 's/-res\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f _ _| while read l; do
						  echo "$test,$threads,$active_schemas,$l" >> ../alldata.csv
					      done # while read l
done # for f in ../raw/
