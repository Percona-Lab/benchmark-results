#!/bin/bash
# raw/res-OLTP-RO-memory-disk-samsung-8t-rocks/mongowt.BP100/thr112
# dstat.csv	dstat.out	dstat.txt	res.txt		runparam.json
# 
# raw/res-$workload-memory-disk-samsung-8t-$engine/mongo$engine.BP$memory/thr$threads

TESTS="OLTP-RO"
ENGINES="wt rocks"

echo "engine,memory,user_provided_threads,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/res-OLTP-RO-memory-disk-samsung-8t-rocks/mongowt.BP100/thr112/res.txt _ _ _)" > ../alldata.csv

echo "engine,memory,workload,threads,$(env _ONLYHEADER=1 cleanup_dstat.sh ../raw/res-OLTP-RO-memory-disk-samsung-8t-rocks/mongowt.BP100/thr112/dstat.txt)" > ../dstat.csv

for f in $(find ../raw/res-*/ -type f); do
    workload=$(echo $f|sed 's/.*res-//
                            s/-memory.*//g')
    engine=$(echo $f|sed 's/.*-8t-//
                          s/\/.*//g')
    memory=$(echo $f|sed 's/.*BP//
                          s/\/.*//g')
    threads=$(echo $f|sed 's/.*thr//
                           s/\/.*//g')
    bn=$(basename $f)
    [ "$bn" == "dstat.txt" ] && {
	#nn=$(echo $bn|sed 's/txt$/csv/')
	env _NOHEADER=1 cleanup_dstat.sh $f | while read l; do
				  echo "$engine,$memory,$workload,$threads,$l" >> ../dstat.csv
			      done # while read l (dstat.txt)
    }
    [ "$bn" == "res.txt" ] && {
	env _NOHEADER=1 csv_from_sysbench.sh $f $workload 60000000 $threads | while read l; do
						      echo "$engine,$memory,$threads,$l" >> ../alldata.csv
						  done # while read l (res.txt)
    }
done # for f in ...
