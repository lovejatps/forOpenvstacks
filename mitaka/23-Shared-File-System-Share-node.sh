#!/bin/bash
MANILA_DBPASS=$1
MANILA_PASS=$2
controller=$3
RABBIT_PASS=$4
MANAGEMENT_INTERFACE_IP_ADDRESS=$5
NEUTRON_PASS=$6
NOVA_PASS=$7
CINDER_PASS=$8
if [ ! -f /var/log/shared_stat ];then
	apt-get install manila-share python-pymysql
	echo "have done before" > /var/log/shared_stat
fi
if [ ! -f /etc/manila/manila.conf.bak ];then
	cp /etc/manila/manila.conf /etc/manila/manila.conf.bak
else
	cp /etc/manila/manila.conf.bak /etc/manila/manila.conf
fi
echo "[database]"		>> /etc/manila/manila.conf
echo "[oslo_messaging_rabbit]"	>> /etc/manila/manila.conf
echo "[keystone_authtoken]"	>> /etc/manila/manila.conf
echo "[oslo_concurrency]"	>> /etc/manila/manila.conf
sed -i "/\[database\]/,+0aconnection = mysql+pymysql://manila:${MANILA_DBPASS}@${controller}/manila" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${controller}" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0arootwrap_config = /etc/manila/rootwrap.conf" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0adefault_share_type = default_share_type" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${MANILA_PASS}" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = manila" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${controller}:11211" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${controller}:35357" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${controller}:5000" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0amy_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/manila/manila.conf
sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/manila/tmp" /etc/manila/manila.conf

#Driver support for share servers management
apt-get install neutron-plugin-linuxbridge-agent
echo "[neutron]"               >> /etc/manila/manila.conf
echo "[nova]"               >> /etc/manila/manila.conf
echo "[cinder]"               >> /etc/manila/manila.conf
echo "[generic]"               >> /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0aenabled_share_protocols = NFS,CIFS" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0aenabled_share_backends = generic" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0apassword = ${NEUTRON_PASS}" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0ausername = neutron" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aproject_name = service" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aregion_name = RegionOne" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0auser_domain_name = default" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aproject_domain_name = default" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aauth_type = password" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0amemcached_servers = ${controller}:11211" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aauth_url = http://${controller}:35357" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aauth_uri = http://${controller}:5000" /etc/manila/manila.conf
sed -i "/\[neutron\]/,+0aurl = http://${controller}:9696" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0apassword = ${NOVA_PASS}" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0ausername = nova" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aproject_name = service" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aregion_name = RegionOne" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0auser_domain_name = default" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aproject_domain_name = default" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aauth_type = password" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0amemcached_servers = ${controller}:11211" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aauth_url = http://${controller}:35357" /etc/manila/manila.conf
sed -i "/\[nova\]/,+0aauth_uri = http://${controller}:5000" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0apassword = ${CINDER_PASS}" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0ausername = cinder" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aproject_name = service" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aregion_name = RegionOne" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0auser_domain_name = default" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aproject_domain_name = default" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aauth_type = password" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0amemcached_servers = ${controller}:11211" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aauth_url = http://${controller}:35357" /etc/manila/manila.conf
sed -i "/\[cinder\]/,+0aauth_uri = http://${controller}:5000" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0ainterface_driver = manila.network.linux.interface.BridgeInterfaceDriver" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0aservice_instance_password = manila" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0aservice_instance_user = manila" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0aservice_image_name = manila-service-image" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0aservice_instance_flavor_id = 100" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0adriver_handles_share_servers = True" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0ashare_driver = manila.share.drivers.generic.GenericShareDriver" /etc/manila/manila.conf
sed -i "/\[generic\]/,+0ashare_backend_name = GENERIC" /etc/manila/manila.conf

#Restart this serivce
service manila-share restart
