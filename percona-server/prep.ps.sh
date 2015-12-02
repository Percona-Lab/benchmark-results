for i in 50000 25000 10000 5000 2500 1000
do
for j in oltp update_index update_non_index
do
bash 1.sh ps.${i}.${j}.txt ps $i $j
bash 1.sh ps.${i}.${j}.io2000.txt ps-io2000 $i $j
bash 1.sh ps.${i}.${j}.io3000.txt ps-io3000 $i $j
#ps.1000.update_index.io2000.txt
done
done
