#!/bin/bash

# Sketched version of script to start 
# mysql group replication
# ---------------------------------------


FLOWCONTROL=""
CNF_FILE=<common-durable.cnf|common-relaxed.cnf>

MGR_CNF="--defaults-file=${CNF_FILE} --plugin-load=group_replication.so \
                --slave-transaction-retries=10 --group_replication_auto_increment_increment=9"
                
...

start_server.sh ${NODE} ${MGR_CNF}

...

NODE_LIST=(172.16.0.1:7707 172.16.0.2:7707 172.16.0.3:7707)
NODES=$(IFS=, ; echo "${NODE_LIST[*]}")

for NODE_IDX in 1 2 3 ; do

NODE=${NODE_LIST[$(($NODE_IDX-1))]%:*}

mysql -h $NODE -uroot -vvv -e"STOP GROUP_REPLICATION;
                     CHANGE MASTER TO MASTER_USER='rpl', MASTER_PASSWORD='rplpass' FOR CHANNEL 'group_replication_recovery';
                     SET GLOBAL transaction_write_set_extraction=XXHASH64;
                     SET GLOBAL slave_preserve_commit_order=on;
                     SET GLOBAL slave_parallel_type=LOGICAL_CLOCK;
                     SET GLOBAL slave_parallel_workers=16;
                     SET GLOBAL sync_relay_log_info=0;
                     SET GLOBAL sync_master_info=0;
                     SET GLOBAL sync_relay_log=0;
                     SET GLOBAL binlog_row_image=full;
                     SET GLOBAL group_replication_single_primary_mode=FALSE;
                     SET GLOBAL group_replication_group_name= 'eeeeeeee-dddd-cccc-bbbb-aaaaaaaaaaaa';
                     SET GLOBAL group_replication_compression_threshold=0;
                     SET GLOBAL group_replication_compression_threshold=0;
                     SET GLOBAL group_replication_local_address='${NODE_LIST[$(($NODE_IDX-1))]}';"

if [ "$NODE_IDX" = "1" ]; then
   mysql -h $NODE -uroot -vvv -e"SET GLOBAL group_replication_bootstrap_group=1;"
else
   mysql -h $NODE -uroot -vvv -e"SET GLOBAL group_replication_group_seeds='${NODES}';"
fi

if [ "$FLOWCONTROL" == "0" ]; then
    mysql -h $NODE -uroot -vvv -e"SET GLOBAL group_replication_flow_control_mode=DISABLED;"
elif [ "$FLOWCONTROL" == "1000" ]; then
    mysql -h $NODE -uroot -vvv -e"SET GLOBAL group_replication_flow_control_mode=QUOTA;
                                  SET GLOBAL group_replication_flow_control_certifier_threshold=1000;
                                  SET GLOBAL group_replication_flow_control_applier_threshold=1000;"
fi

mysql -h $NODE -uroot -vvv -e"START GROUP_REPLICATION;"

done
