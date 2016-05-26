#!/bin/bash
#NOVA_DBPASS=123456
NOVA_DBPASS=$1
#RABBIT_PASS=123456
RABBIT_PASS=$2
#NOVA_PASS=123456
NOVA_PASS=$3
#my_ip=192.168.102.11
my_ip=$4
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$5
if [ ! -f /var/log/compute_stat ];then
	echo "have done !" > /var/log/compute_stat
	apt-get install nova-compute
fi
if [ ! -f /etc/nova/nova.conf.bak ];then
	cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
else
	cp /etc/nova/nova.conf.bak /etc/nova/nova.conf
fi

chmod 777 /etc/nova/nova.conf

echo "[oslo_messaging_rabbit]" >> /etc/nova/nova.conf
echo "[keystone_authtoken]" >> /etc/nova/nova.conf
echo "[vnc]" >> /etc/nova/nova.conf
echo "[glance]" >> /etc/nova/nova.conf
echo "[oslo_concurrency]" >> /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/nova/nova.conf

sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${CTL_HOST}" /etc/nova/nova.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/nova/nova.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/nova/nova.conf

sed -i "/\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/nova/nova.conf

sed -i "/\[keystone_authtoken\]/,+0apassword = ${NOVA_PASS}" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = nova" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/nova/nova.conf

sed -i "/\[DEFAULT\]/,+0amy_ip = ${my_ip}" /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0ause_neutron = True" /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0afirewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

sed -i "/\[vnc\]/,+0aenabled = True" /etc/nova/nova.conf
sed -i "/\[vnc\]/,+0avncserver_listen = 0.0.0.0" /etc/nova/nova.conf
sed -i "/\[vnc\]/,+0avncserver_proxyclient_address = \$my_ip" /etc/nova/nova.conf
sed -i "/\[vnc\]/,+0anovncproxy_base_url = http://${CTL_HOST}:6080/vnc_auto.html" /etc/nova/nova.conf

sed -i "/\[glance\]/,+0aapi_servers = http://${CTL_HOST}:9292" /etc/nova/nova.conf

sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/nova/tmp" /etc/nova/nova.conf

cp /etc/nova/nova.conf tmp/nova.conf
if [ `egrep -c '(vmx|svm)' /proc/cpuinfo` -lt 1 ];then
	sed -i "/^virt_type=/cvirt_type = qemu" /etc/nova/nova.conf
fi
service nova-compute restart
