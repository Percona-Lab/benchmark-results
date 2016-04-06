rm -f summary.csv
for t in  mysql57 mysql57.wd50 mysql57.wd100 mysql57.wd200
do
for i in 1 2 3 4 5 6 8 10 13 16 20 25 31 38 46 56 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
do
echo "res.$t/res.${i}.ro.txt $t,$i"
bash parse.sh raw/res.$t/res.${i}.ro.txt $t,$i >> summary.csv
done
done
