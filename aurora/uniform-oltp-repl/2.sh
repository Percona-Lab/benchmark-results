#!/bin/bash

# au.sz125000.thr100.oltp.txt

for f in au*; do
    size=$(echo $f|sed 's/.*sz//g
                        s/\..*//g')
    workload=$(echo $f|sed 's/.*thr//g
                        s/\..*//g')
    test=$(echo $f|sed 's/.*thr[0-9]*\.//g
                        s/\..*//g')
    ./1.sh $f $test $size $workload 
    echo
done
