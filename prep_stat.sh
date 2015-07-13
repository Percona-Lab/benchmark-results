export ENGINE=$2
export SIZE=$3
cat $1/iostat.par640.res | grep -P "^sda" | awk -v eng=$ENGINE -v cache=$SIZE 'BEGIN {c=10} { print c, $6, $7, eng, cache; c+=10 } ' >> $4.io.txt
cat $1/dstat_plain.par640.res | grep ":" | awk  -v eng=$ENGINE -v cache=$SIZE  -F '|' 'BEGIN {c=10} { print c, $7, eng, cache; c+=10 } ' >> $4.cpu.txt

#cat $1/script.out.txt | grep "int tps" | perl -n -e'/](\d*,*\d+)\sseconds.*int tps=(\d+\.\d+)\s/ && print $1." ".$2." ".$ENV{"ENGINE"}." ".$ENV{"SIZE"}."\n"'
