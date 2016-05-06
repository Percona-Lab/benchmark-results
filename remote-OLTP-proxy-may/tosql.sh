f="2.csv"
RUNSIG="OLTP-RO-proxy#smblade01-net#"
rm -f $f
for t in res.*
do
for fn in $t/res*.txt
do
res=$(basename "$t")
res=${res#res.} 
bash parsem.sh $fn $RUNSIG$res $f
echo $t "|" $res "|" $fn
done
done
mysql -h10.20.2.4 -e "LOAD DATA LOCAL INFILE '$f' REPLACE INTO TABLE sbtest_results FIELDS TERMINATED BY ','" -usbtest  --local-infile=1 benchmarks
