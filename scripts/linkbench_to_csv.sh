#!/bin/bash

pushd ../raw/linkbenchX/
echo "engine,ts,tps" > linkbench.csv
for engine in wt inmemory; do
    t=0
    while read line; do
	tps=$(echo $line|awk -F, '{print $2}')
	echo "$engine,$t,$tps" >> linkbench.csv
	t=$((t+10))
    done < linkbench.$engine.txt.csv # while read line
done # for engine in ...
popd
