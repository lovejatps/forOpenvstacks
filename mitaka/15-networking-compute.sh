#!/bin/bash
#RABBIT_PASS=123456
RABBIT_PASS=$1
#NEUTRON_PASS=123456
NEUTRON_PASS=$2
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$3
#provider interface
eth=$4
#local IP address
ipaddr=$5
ch_stat=/var/log/neutron_base_stat
if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}
	apt-get install neutron-linuxbridge-agent
fi
./17-networking-compute-self-service.sh ${eth} ${ipaddr}
if [ ! -f /etc/neutron/neutron.conf.bak ];then
	cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak
else
	cp /etc/neutron/neutron.conf.bak /etc/neutron/neutron.conf
fi
sed -i "/^\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/neutron/neutron.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${CTL_HOST}" /etc/neutron/neutron.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/neutron/neutron.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/neutron/neutron.conf
sed -i "/^\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = neutron" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${NEUTRON_PASS}" /etc/neutron/neutron.conf
cp /etc/neutron/neutron.conf tmp/neutron.conf

echo "[neutron]" >> /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aurl = http://${CTL_HOST}:9696" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aauth_type = password" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aproject_domain_name = default" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0auser_domain_name = default" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aregion_name = RegionOne" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aproject_name = service" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0ausername = neutron" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0apassword = ${NEUTRON_PASS}" /etc/nova/nova.conf
cp /etc/nova/nova.conf tmp/nova.conf.15
service nova-compute restart
service neutron-linuxbridge-agent restart
