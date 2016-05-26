#!/bin/bash
#eth0=192.168.168.25
eth0=$1
if [ ! -f /etc/mongodb.conf.bak ];then
	apt-get install mongodb-server mongodb-clients python-pymongo
	cp /etc/mongodb.conf /etc/mongodb.conf.bak
else
	cp /etc/mongodb.conf.bak /etc/mongodb.conf
fi
sed -i "/^bind_ip/cbind_ip = ${eth0}" /etc/mongodb.conf
cp /etc/mongodb.conf tmp/mongodb.conf
service mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
service mongodb start
