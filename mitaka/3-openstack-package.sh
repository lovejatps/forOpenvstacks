#!/bin/bash
ch_stat=/var/log/3-openstack_stat
if [ ! -f ${ch_stat} ];then
	apt-get install software-properties-common
	add-apt-repository cloud-archive:mitaka
	apt-get update && apt-get dist-upgrade
	apt-get install python-openstackclient
	echo "have done before !" > ${ch_stat}
fi
