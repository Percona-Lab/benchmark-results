#!/bin/bash

# Sketched version of script to start 
# percona xtradb cluster/mariadb cluster
# ---------------------------------------



CNF_FILE=<common-durable.cnf|common-relaxed.cnf>

NODE_LIST=(172.16.0.1:7707 172.16.0.2:7707 172.16.0.3:7707)
NODES=$(IFS=, ; echo "${NODE_LIST[*]}")

for NODE_IDX in 1 2 3 ; do 

NODE=${NODE_LIST[$(($NODE_IDX-1))]%:*}

if [ $NODE_IDX != "1" ]; then 
  CLUSTER_ADDRESS=${NODES}
fi


GALERA_CNF="--defaults-file=${CNF_FILE} --wsrep_provider=libgalera_smm.so --wsrep_on=ON --innodb-autoinc-lock-mode=2 \
                --wsrep_cluster_name='galera_cluster' --wsrep_node_address=${NODE_LIST[$(($NODE_IDX-1))]} \
                --wsrep_cluster_address=gcomm://${CLUSTER_ADDRESS} --wsrep_slave_threads=16 \
                --wsrep_provider_options='gcs.fc_master_slave=yes;'"

...

start_server.sh ${NODE} $GALERA_CNF


...

done
