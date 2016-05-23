#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths
# sample files for this benchmark:
# ../raw/{hdd|ssd}/sysbench.{baseline|compression|encryption}-{threads-N|N}.log
# ../raw/{hdd|ssd}/diskstats.{baseline|compression|encryption}-{threads-N|N}.log
# ../raw/{hdd|ssd}/vmstat.{baseline|compression|encryption}-{threads-N|N}.log
# ../raw/{hdd|ssd}/timestamps.{baseline|compression|encryption}-{threads-N|N}.log

#  #ts device     rd_s rd_avkb rd_mb_s rd_mrg rd_cnc   rd_rt    wr_s wr_avkb wr_mb_s wr_mrg wr_cnc   wr_rt busy in_prg    io_s  qtime stime
# I want $15, $18, $19

THREADS="1 4 8 16 32"
hdd=sda
ssd=nvme0n1

echo "disk,type,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/hdd/sysbench.baseline-1.log xb 10000000 1)" > ../alldata.csv
echo "disk,type,threads,backup_duration" > ../durations.csv

for type in baseline compression encryption; do
    for disk in hdd ssd; do
	baseline=0
	for threads in $THREADS; do
	            extra=1
	            if [ "$type" == "baseline" ]; then
		       [ $baseline -eq 0 ] && baseline=1 || continue	
		    else
                       extra="threads-$threads"
		    fi
	            for f in ../raw/$disk/sysbench.$type-$extra.log; do
			[ -f $f ] || continue
			env _NOHEADER=1 csv_from_sysbench.sh $f xb 10000000 $threads | while read l; do
												echo "$disk,$type,$l" >> ../alldata.csv
												done
			start_t=$(head -1 ../raw/$disk/timestamps.$type-$extra.log)
			end_t=$(tail -1 ../raw/$disk/timestamps.$type-$extra.log)
			echo "$disk,$type,$threads,$((end_t-start_t))" >> ../durations.csv
			dev=$(eval "echo \$$disk")
			echo "disk,type,threads,busy,qtime,stime" > ../diskstats.csv
			grep $dev ../raw/$disk/diskstats.$type-$extra.log|awk '{print $15, $18, $19}' | tr -d '%' |tr ' ' ','|while read l; do
													       echo "$disk,$type,$threads,$l" >> ../diskstats.csv
													    done
	    done # for f in ../$disk/
	done # for engine
    done # for distribution
done #for workload
