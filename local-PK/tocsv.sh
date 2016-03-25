rm -f summary.csv
for i in 1 2 3 4 5 6 8 10 13 16 20 25 31 38 46 56 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
do
for t in mysql55 mysql56.bpi32 mysql56.psOFF mysql57.bpi32 mysql57.psOFF mysql56.tiRC mysql57.tiRC.psALL_ON mysql57.tiRC.no-perf-schema-compiled mysql56.tiRC.no-perf-schema-compiled mysql57.imON mysql57.short
do
bash parse.sh  raw/res.${t}/res.thr${i}.ro.txt $t,$i >> summary.csv
done
done
