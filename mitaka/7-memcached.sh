#!/bin/bash
#eth0=192.168.168.25
eth0=$1
if [ ! -f /etc/memcached.conf.bak ];then
	cp /etc/memcached.conf /etc/memcached.conf.bak
	apt-get install memcached python-memcache
else
	cp /etc/memcached.conf.bak /etc/memcached.conf
fi
sed -i "/^-l 127.0.0.1/c-l ${eth0}" /etc/memcached.conf
cp /etc/memcached.conf tmp/memcached.conf
service memcached restart
