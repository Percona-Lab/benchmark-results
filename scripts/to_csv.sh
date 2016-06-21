#!/bin/bash

echo "test,active_schemas,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-gt-20000.txt _ _ _)" > ../alldata.csv

for f in ../raw/sys*txt; do
    test=$(echo $f|awk -F'-' '{print $2}')
    active_schemas=$(echo $f|awk -F'-' '{print $3}'|sed 's/\.txt//')
    env _NOHEADER=1 csv_from_sysbench.sh $f _ _| while read l; do
						  echo "$test,$active_schemas,$l" >> ../alldata.csv
					      done # while read l
done # for f in ../raw/
