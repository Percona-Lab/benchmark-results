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

THREADS="1 4 8 16 32 48 62"
PARALLEL_THREADS="1 4 8 16 32"
hdd=sda
ssd=nvme0n1

#echo "disk,type,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/hdd/sysbench.baseline-1.log xb 10000000 1)" > ../alldata.csv
#echo "disk,type,threads,backup_duration" > ../durations.csv
#echo "disk,type,threads,busy,qtime,stime" > ../diskstats.csv

echo "disk,type,parallel_threads,$(env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/ssd/sysbench.baseline-1--parallel=1.log xb 10000000 1)" > ../alldata-parallel.csv
echo "disk,type,parallel_threads,threads,backup_duration" > ../durations-parallel.csv
echo "counter,disk,type,parallel_threads,threads,busy,qtime,stime" > ../diskstats-parallel.csv
echo "disk,type,parallel_threads,threads,time,r,b,swpd,free,buff,cache,si,so,bi,bo,in,cs,us,sy,id,wa,st" > ../vmstat-parallel.csv


# for type in baseline compression encryption; do
#     for disk in hdd ssd; do
# 	baseline=0
# 	for threads in $THREADS; do
# 	            extra=1
# 	            if [ "$type" == "baseline" ]; then
# 		       [ $baseline -eq 0 ] && baseline=1 || continue	
# 		    else
#                        extra="threads-$threads"
# 		    fi
# 	            for f in ../raw/$disk/sysbench.$type-$extra.log; do
# 			[ -f $f ] || continue
# 			env _NOHEADER=1 csv_from_sysbench.sh $f xb 10000000 $threads | while read l; do
# 												echo "$disk,$type,$l" >> ../alldata.csv
# 												done
# 			start_t=$(head -1 ../raw/$disk/timestamps.$type-$extra.log)
# 			end_t=$(tail -1 ../raw/$disk/timestamps.$type-$extra.log)
# 			echo "$disk,$type,$threads,$((end_t-start_t))" >> ../durations.csv
# 			dev=$(eval "echo \$$disk")
# 			grep $dev ../raw/$disk/diskstats.$type-$extra.log|awk '{print $15, $18, $19}' | tr -d '%' |tr ' ' ','|while read l; do
# 													       echo "$disk,$type,$threads,$l" >> ../diskstats.csv
# 													    done
# 	    done # for f in ../$disk/
# 	done # for engine
#     done # for distribution
# done #for workload

for type in baseline compression encryption xbstream_compressed xbstream_qpress; do
    for disk in ssd; do
	baseline=0
	for threads in $THREADS; do
	            extra=1
		    if [ "$type" == "baseline" ]; then
			baseline=$((baseline+1))
		    else
			extra="threads-$threads"
		    fi
		    for pt in $PARALLEL_THREADS; do
			[ "$type" == "baseline" -a $baseline -gt 1 ] && continue
			[ "$type" == "baseline" -a $baseline -le 1 ] && baseline=$((baseline+1))
			parallel="--parallel=$pt"
			for f in ../raw/$disk/sysbench.$type-$extra$parallel.log; do
			    [ -f $f ] || continue
			    env _NOHEADER=1 csv_from_sysbench.sh $f xb 10000000 $threads | while read l; do
												    echo "$disk,$type,$pt,$l" >> ../alldata-parallel.csv
												    done # while read l
			    start_t=$(head -1 ../raw/$disk/timestamps.$type-$extra$parallel.log)
			    end_t=$(tail -1 ../raw/$disk/timestamps.$type-$extra$parallel.log)
			    echo "$disk,$type,$pt,$threads,$((end_t-start_t))" >> ../durations-parallel.csv
			    # dev=$(eval "echo \$$disk") # no longer used because we're not publishing the hdd to hdd results
			    # backups are always ssd to hdd 
			    for dev in $ssd $hdd; do 
				counter=1
				grep $dev ../raw/$disk/diskstats.$type-$extra$parallel.log|awk '{print $15, $18, $19}' | tr -d '%' |tr ' ' ','|while read l; do
														    echo "$counter,$dev,$type,$pt,$threads,$l" >> ../diskstats-parallel.csv
														    counter=$((counter+1))
																	    done # while read l
			    done # for dev in ...
			    for f in ../raw/$disk/vmstat.$type-threads-$threads--parallel=$pt.log; do
				[ -f $f ] || continue
				secs=1
			 	grep -v '[a-z]' $f | sed 's/  */,/g' | while read l; do
									  echo "$disk,$type,$pt,$threads,$secs,$l" >> ../vmstat-parallel.csv
									  secs=$((secs+1))
								      done # while read l
				grep -v ',,' ../vmstat-parallel.csv > $$ && mv -f $$ ../vmstat-parallel.csv
			    done # for f in ... vmstat ... 
			done # for pt in ...
	    done # for f in ../$disk/ ... sysbench ...
	done # for engine
    done # for distribution
done #for workload
