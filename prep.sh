export ENGINE=$2
export SIZE=$3
cat $1/script.out.txt | grep "int tps" | perl -n -e'/](\d*,*\d+)\sseconds.*int tps=(\d+\.\d+)\s/ && print $1." ".$2." ".$ENV{"ENGINE"}." ".$ENV{"SIZE"}."\n"'
