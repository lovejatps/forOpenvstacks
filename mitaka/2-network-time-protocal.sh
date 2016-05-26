#!/bin/bash
ch_stat=/var/log/chrony_stat
if [ ! -f ${ch_stat} ];then
	apt-get install chrony
	sed -i "/^server/s/^/#/" /etc/chrony/chrony.conf
	echo "server $1 iburst" >> /etc/chrony/chrony.conf
	echo "the config is done !" > ${ch_stat}
	cp /etc/chrony/chrony.conf tmp/chrony.conf
fi
service chrony restart
