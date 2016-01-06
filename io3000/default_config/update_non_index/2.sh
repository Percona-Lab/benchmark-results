#!/bin/bash

# toku.2500.oltp.io3000.tokudb_config.txt

for f in toku*; do
    size=$(echo $f|awk -F. '{print $2}')
    volume_type=$(echo $f|awk -F. '{print $4}')
    test=$(echo $f|awk -F. '{print $3}')
    ./1.sh $f $test $size $volume_type 
    echo
done
