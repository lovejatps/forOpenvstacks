#!/bin/bash
#rabbit_pass=123456
ch_stat=/var/log/rabbit_stat
rabbit_pass=$1
if [ ! -f ${ch_stat} ];then
	apt-get install rabbitmq-server
	rabbitmqctl add_user openstack ${rabbit_pass}
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"
	echo "have done before" > ${ch_stat}
fi
