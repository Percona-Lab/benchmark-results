for i in 50000 25000 10000 5000 2500 1000
do
for j in oltp update_index update_non_index
do
bash 1.sh au.${i}.${j}.txt aurora $i $j
done
done
