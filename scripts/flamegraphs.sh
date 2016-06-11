#!/bin/bash

flame_graphs_repo=~/src/FlameGraph

pushd ../raw
for f in perf*profiler-0.perf.gz; do
    compare_with=$(echo $f|sed 's/profiler-0/slowms-2/')
    threads=$(echo $f|awk -F '-' '{print $3}')
    gunzip -c $f > log_none
    gunzip -c $compare_with > log_all
    $flame_graphs_repo/stackcollapse-perf.pl log_all > log_all.folded; rm -f log_all
    $flame_graphs_repo/stackcollapse-perf.pl log_none > log_none.folded; rm -f log_none
    $flame_graphs_repo/difffolded.pl log_none.folded log_all.folded | $flame_graphs_repo/flamegraph.pl > ../img/diff-$threads.svg
    rm -f *folded
done

test -f stacks-detailed_oltp-16-run1-profiler-0.txt && {
    $flame_graphs_repo/stackcollapse-gdb.pl stacks-detailed_oltp-16-run1-profiler-0.txt > log_none.folded
    $flame_graphs_repo/stackcollapse-gdb.pl stacks-detailed_oltp-16-run1-profiler-2.txt > log_all.folded
    $flame_graphs_repo/difffolded.pl log_none.folded log_all.folded | $flame_graphs_repo/flamegraph.pl > ../img/diff-16-gdb.svg
}

popd
