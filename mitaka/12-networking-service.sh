#!/bin/bash
#neutron=neutron.wodezoon.com
neutron=$1
#MARIADBPWD=123456
MARIADBPWD=$2
#NEUTRON_DBPASS=123456
NEUTRON_DBPASS=$3
#NEUTRON_PASS=123456
NEUTRON_PASS=$4
#METADATA_SECRET=123456
METADATA_SECRET=$5
#RABBIT_PASS=123456
RABBIT_PASS=$6
#NOVA_PASS=123456
NOVA_PASS=$7
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$8
#PROVIDER_INTERFACE_NAME=eth1
PROVIDER_INTERFACE_NAME=$9
#OVERLAY_INTERFACE_IP_ADDRESS=192.168.102.123
OVERLAY_INTERFACE_IP_ADDRESS=$10
ch_stat=/var/log/neutron_base_stat
if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}

	echo "CREATE DATABASE neutron;" > tmp.sql
	echo "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}';" >> tmp.sql
	echo "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';" >> tmp.sql
	
	mysql -uroot -p${MARIADBPWD} < tmp.sql
	rm -rf tmp.sql

	source admin-openrc

	openstack user create --domain default --password-prompt neutron
	openstack role add --project service --user neutron admin
	openstack service create --name neutron --description "OpenStack Networking" network
	openstack endpoint create --region RegionOne network public http://${CTL_HOST}:9696
	openstack endpoint create --region RegionOne network internal http://${CTL_HOST}:9696
	openstack endpoint create --region RegionOne network admin http://${CTL_HOST}:9696
fi
./14-networking-Self-service-networks.sh ${neutron} ${NEUTRON_DBPASS} ${NEUTRON_PASS} ${RABBIT_PASS} ${NOVA_PASS} ${CTL_HOST} ${PROVIDER_INTERFACE_NAME} ${OVERLAY_INTERFACE_IP_ADDRESS}

if [ ! -f /etc/neutron/metadata_agent.ini.bak ];then
	cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.bak
else
	cp /etc/neutron/metadata_agent.ini.bak /etc/neutron/metadata_agent.ini
fi
sed -i "/^#nova_metadata_ip = /cnova_metadata_ip = ${CTL_HOST}" /etc/neutron/metadata_agent.ini
sed -i "/^#metadata_proxy_shared_secret =/cmetadata_proxy_shared_secret = ${METADATA_SECRET}" /etc/neutron/metadata_agent.ini

echo "[neutron]" >> /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0ametadata_proxy_shared_secret = ${METADATA_SECRET}" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aservice_metadata_proxy = True" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0apassword = ${NEUTRON_PASS}" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0ausername = neutron" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aproject_name = service" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aregion_name = RegionOne" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0auser_domain_name = default" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aproject_domain_name = default" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aauth_type = password" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/nova/nova.conf
sed -i "/\[neutron\]/,+0aurl = http://${CTL_HOST}:9696" /etc/nova/nova.conf

cp /etc/nova/nova.conf tmp/nova.conf.12
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
service nova-api restart
service neutron-server restart
service neutron-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart
