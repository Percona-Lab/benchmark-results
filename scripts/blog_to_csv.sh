#!/bin/bash

threads=70
#active_schemas=20000
echo "test,threads,active_schemas,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/blog/sysbench-blog-gt-$threads-20000-res.txt _ _ _)" > ../blog-alldata.csv

for f in ../raw/blog/sys*70*res.txt; do
    test=$(echo $f|awk -F'-' '{print $3}')
    active_schemas=$(echo $f|awk -F'-' '{print $5}')
    env _NOHEADER=1 csv_from_sysbench.sh $f _ _ $threads| while read l; do
						  echo "$test,$threads,$active_schemas,$l" >> ../blog-alldata.csv
					      done # while read l
done # for f in ../raw/$dataset/
