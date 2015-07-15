export ENGINE=$2
export STOR=$3


if [ "$STOR" == 'M500' ]; then
	DEV="sdd"
fi
if [ "$STOR" == 'i3600' ]; then
	DEV="nvme1n1"
fi
echo "DEV=$DEV"


cat $1/iostat* | grep -P "^$DEV" | awk -v eng=$ENGINE -v cache=$STOR 'BEGIN {c=10} { print c, $6, $7, eng, cache; c+=10 } ' >> $4.io.txt

#cat $1/script.out.txt | grep "int tps" | perl -n -e'/](\d*,*\d+)\sseconds.*int tps=(\d+\.\d+)\s/ && print $1." ".$2." ".$ENV{"ENGINE"}." ".$ENV{"SIZE"}."\n"'
