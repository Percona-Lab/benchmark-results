
# Determine run number for selecting an output directory
RUN_NUMBER=-1

if [ -f ".run_number" ]; then
  read RUN_NUMBER < .run_number
fi

if [ $RUN_NUMBER -eq -1 ]; then
        RUN_NUMBER=0
fi

OUTDIR=res$RUN_NUMBER
mkdir -p $OUTDIR


RUN_NUMBER=`expr $RUN_NUMBER + 1`
echo $RUN_NUMBER > .run_number

runid="ld_qz_16k_10x_fn128"

PIDS=()
iostat -dmx 10 >> $OUTDIR/iostat.$runid.res &
PIDS+=($!) 
dstat -t -v --nocolor 10 > $OUTDIR/dstat_plain.$runid.res  &
PIDS+=($!) 


#bin/linkbench -r -c config/LinkConfigMysql.properties -D requesters=48 -D requestrate=45000 -D dbid=$runid -D maxtime=86400 -csvstream $OUTDIR/qz24h.rt45k.8G_nodirect.12Gcgroup.ckp900.bs4M.fn128.HDD.csv
bin/linkbench -r -c config/LinkConfigMysql.properties -D requesters=48 -D requestrate=45000 -D dbid=ld_inno_8k_100x -D maxtime=86400 -csvstream $OUTDIR/innodb.12G.comp8x.HDD.csv

echo "Killing stats"
for var in "${PIDS[@]}"
do
  kill -9 $var
done

