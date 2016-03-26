#!/bin/bash

[ $# -eq 0 ] && echo "usage: $0 <enable|disable>">&2 && exit

[ "$1" == "enable" ] && {
	echo always > /sys/kernel/mm/transparent_hugepage/enabled
	echo always > /sys/kernel/mm/transparent_hugepage/defrag
} || {
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	echo never > /sys/kernel/mm/transparent_hugepage/defrag
}
