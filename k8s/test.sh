#!/bin/bash


export KUBECONFIG=$2
type_=$1

test -d data || mkdir data
test -d graphs || mkdir graphs

function vSpec() {
	if [ "$1" == "Linode" ]; then
		cat << EOD
      persistentVolumeClaim:
        storageClassName: local-storage
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 100Gi
EOD
	else
		cat << EOD
      hostPath:
        path: \/mnt\/disks\/ssd0\/mysql
        type: DirectoryOrCreate
EOD

	fi;
}

function splitFiles() {
	size=10
	test -x graphs/$2/$3/raw || mkdir -p graphs/$2/$3/raw
	test -x graphs/$2/$3/tps || mkdir -p graphs/$2/$3/tps
	cat $1 |  grep 'thds\|^10G\|^40G' | while read line; do
	
	if [ "$line" == "10G" ]; then
		size=10
	elif [ "$line" == "40G" ]; then
		size=40
	else
		thds=$( echo "$line" | awk '{print $5}')
		echo "$line" >> graphs/$2/$3/raw/${3}_${size}_${thds};
	fi
	done

	for i in graphs/$2/$3/raw/${3}_*; do
		awk '{ print int($2) " " $7}' $i > graphs/$2/$3/tps/$(basename $i);
	done;

	for i in graphs/$2/$3/tps/${3}_10*; do
		python avg.py $i >> graphs/$2/$3/10.avg
	done;
	sort -n -k1 graphs/$2/$3/10.avg -o graphs/$2/$3/10.avg

	for i in graphs/$2/$3/tps/${3}_40*; do
		python avg.py $i >> graphs/$2/$3/40.avg
	done;
	sort -n -k1 graphs/$2/$3/40.avg -o graphs/$2/$3/40.avg 
}

function generateConfig() {
	TYPE=$1
	__MYSQL_MEMORY__=$2
	__MYSQL_CPUS__=$3
	__HAPROXY_MEMORY__=$4
	__HAPROXY_CPUS__=$5
	__CONFIGURATION__="$6"

	ESCAPED=$(echo "$(vSpec "${TYPE}")" | sed '$!s@$@\\@g')
	ESCAPED_CONF=$(echo "${__CONFIGURATION__}" | sed -z 's/\n/\\\\n/g' )
	cat cr_template.yaml | sed "s/__VOLUME_SPEC__/${ESCAPED}/g" | sed "s/__MYSQL_MEMORY__/${__MYSQL_MEMORY__}/g" | sed "s/__MYSQL_CPUS__/${__MYSQL_CPUS__}/g" | sed "s/__HAPROXY_MEMORY__/${__HAPROXY_MEMORY__}/g" | sed "s/__HAPROXY_CPUS__/${__HAPROXY_CPUS__}/g" | sed  "s/__MYSQL_CONFIGURATION__/${ESCAPED_CONF}/g"
}

numnodes_=3

for stage in A B C D E F G;  do
	echo "[`date`] Starting with instance type $stage"
	CONFIGURATION="$(cat conf/conf_${stage})"
	case $stage in
		"A")
			conf=$(generateConfig "${type_}" "1G" "1" "1G" "1" "$CONFIGURATION")		
		;;

		"B")
			conf=$(generateConfig "${type_}" "2G" "1" "1G" "1" "$CONFIGURATION")		
		;;

		"C")
			conf=$(generateConfig "${type_}" "4G" "2" "1G" "1" "$CONFIGURATION")		
		;;

		"D")
			conf=$(generateConfig "${type_}" "8G" "4" "1G" "1" "$CONFIGURATION")		
		;;

		"E")
			conf=$(generateConfig "${type_}" "16G" "6" "1G" "1" "$CONFIGURATION")		
		;;		

		"F")
			conf=$(generateConfig "${type_}" "32G" "8" "1G" "1" "$CONFIGURATION")		
		;;

		"G")
			conf=$(generateConfig "${type_}" "64G" "16" "1G" "1" "$CONFIGURATION")		
		;;
	esac

	echo "[`date`] Updating with instance type $stage"
	echo "$conf"  | kubectl replace -f -;
	sleep 5;
	echo "[`date`] Waiting for the changed to be applied with instance type $stage"

	_z=0
	while [ "$(kubectl get perconaxtradbclusters.pxc.percona.com/cluster1 -o jsonpath --template='{.status.state}')" != "ready" ]; do
		echo -ne "Waited $_z sec \r"
		_z=$((_z + 5 ));
		sleep 5;
	done;
	sleep 30;

	#kubectl get pods > results_pods_${stage};
	#for i in 0 1 2; do
	#	kubectl describe pod cluster1-pxc-$i >> results_describe_pods_${stage};
	#done;

	# for i in $(seq 0 $(($numnodes_ -1 ))); do
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "curl -o /tmp/node.tar.gz -L https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz"
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "curl -o /tmp/mysqld.tar.gz -L curl -o /tmp/mysqld.tar.gz -L https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz"
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "cd /tmp && tar -zxvf mysqld.tar.gz && tar -zxvf node.tar.gz"
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "nohup /tmp/node_exporter-1.0.1.linux-amd64/node_exporter --web.listen-address=:9100 > /dev/null 2>&1 &"
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "echo [client] > /tmp/my.cnf" 
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "echo user=root >> /tmp/my.cnf" 
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "echo -ne  password= >> /tmp/my.cnf && printenv MYSQL_ROOT_PASSWORD >> /tmp/my.cnf"
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "nohup /tmp/mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter  --web.listen-address=:9101 --config.my-cnf=/tmp/my.cnf > /dev/null 2>&1 &" 
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "cd /tmp; curl -o run.sh https://gist.githubusercontent.com/impimp/a397177d2c11a4566e59603926708b92/raw/842713bbad37e507c1ee43ad02f147ae9c691d90/gistfile1.txt; chmod +x run.sh" 
	# 	kubectl exec cluster1-pxc-${i} -- bash -c "/tmp/run.sh > /dev/null 2>&1 &"
	# done;

	echo "[`date`] Running sysbench with instance type $stage"
	kubectl apply -f sysbench_oltp_read.yaml;
	sleep 5;
	kubectl wait --for=condition=complete job/sysbenchtest --timeout=-1s;
	sleep 5;
	kubectl logs jobs/sysbenchtest >> data/results_read_${stage};
	splitFiles data/results_read_${stage} ${stage} "read"
	kubectl delete -f sysbench_oltp_read.yaml;
	sleep 5;

	echo "[`date`] Running sysbench write with instance type $stage"
	kubectl apply -f sysbench_oltp_write.yaml;
	sleep 5;
	kubectl wait --for=condition=complete job/sysbenchtest --timeout=-1s;
	sleep 5;
	kubectl logs jobs/sysbenchtest >> data/results_write_${stage};
	splitFiles data/results_write_${stage} ${stage} "write"
	kubectl delete -f sysbench_oltp_write.yaml;


	# for i in $(seq 0 $(($numnodes_ -1 ))); do
	# 	mkdir -p data_pxc-${i}-${stage};
	# 	cd data_pxc-${i}-${stage};
	# 	kubectl cp cluster1-pxc-${i}:/tmp/data/ . ;
	# 	cd ..;
	# done
	echo "[`date`] Gathered data with instance type $stage"
	sleep 5;
done

