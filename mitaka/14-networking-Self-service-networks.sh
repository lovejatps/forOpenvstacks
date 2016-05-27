#!/bin/bash
#neutron=neutron.wodezoon.com
neutron=$1
#NEUTRON_DBPASS=123456
NEUTRON_DBPASS=$2
#NEUTRON_PASS=123456
NEUTRON_PASS=$3
#RABBIT_PASS=123456
RABBIT_PASS=$4
#NOVA_PASS=123456
NOVA_PASS=$5
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$6
#PROVIDER_INTERFACE_NAME=eth1
PROVIDER_INTERFACE_NAME=$7
#OVERLAY_INTERFACE_IP_ADDRESS=192.168.102.123
OVERLAY_INTERFACE_IP_ADDRESS=$8
ch_stat=/var/log/neutron_stat
if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}
	apt-get install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
fi
if [ ! -f /etc/neutron/neutron.conf.bak ];then
	cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak
else
	cp /etc/neutron/neutron.conf.bak /etc/neutron/neutron.conf
fi
#sed -i "/\[database\]/,+0aconnection = mysql+pymysql://${neutron}:${NEUTRON_DBPASS}@${CTL_HOST}/neutron" /etc/neutron/neutron.conf
#echo "[database]" >> /etc/neutron/neutron.conf
#echo "[DEFAULT]" >> /etc/neutron/neutron.conf
#echo "[oslo_messaging_rabbit]" >> /etc/neutron/neutron.conf
#sed -i "/^connection = /cconnection = mysql+pymysql://${neutron}:${NEUTRON_DBPASS}@${CTL_HOST}/neutron" /etc/neutron/neutron.conf
sed -i "/^connection = /cconnection = mysql+pymysql://neutron:${NEUTRON_DBPASS}@${CTL_HOST}/neutron" /etc/neutron/neutron.conf
sed -i "/^core_plugin = /ccore_plugin = ml2" /etc/neutron/neutron.conf
sed -i "/^core_plugin = ml2/,+0aservice_plugins = router" /etc/neutron/neutron.conf
sed -i "/allow_overlapping_ips/callow_overlapping_ips = True" /etc/neutron/neutron.conf

sed -i "/^\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/neutron/neutron.conf

sed -i "/rabbit_host = /crabbit_host = ${CTL_HOST}" /etc/neutron/neutron.conf
sed -i "/rabbit_host = ${CTL_HOST}/,+0arabbit_userid = openstack" /etc/neutron/neutron.conf
sed -i "/rabbit_userid = openstack/,+0arabbit_password = ${RABBIT_PASS}" /etc/neutron/neutron.conf

sed -i "/auth_strategy = /cauth_strategy = keystone" /etc/neutron/neutron.conf

sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/neutron/neutron.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/neutron/neutron.conf
sed -i "/memcached_servers = ${CTL_HOST}:11211/,+0ausername = neutron" /etc/neutron/neutron.conf
sed -i "/memcached_servers = ${CTL_HOST}:11211/,+0aproject_name = service" /etc/neutron/neutron.conf
sed -i "/memcached_servers = ${CTL_HOST}:11211/,+0auser_domain_name = default" /etc/neutron/neutron.conf
sed -i "/memcached_servers = ${CTL_HOST}:11211/,+0aproject_domain_name = default" /etc/neutron/neutron.conf
sed -i "/memcached_servers = ${CTL_HOST}:11211/,+0aauth_type = password" /etc/neutron/neutron.conf
sed -i "/username = neutron/,+0apassword = ${NEUTRON_PASS}" /etc/neutron/neutron.conf

sed -i "/^#notify_nova_on_port_status_changes =/cnotify_nova_on_port_status_changes = True" /etc/neutron/neutron.conf
sed -i "/^#notify_nova_on_port_data_changes =/cnotify_nova_on_port_data_changes = True" /etc/neutron/neutron.conf

sed -i "/\[nova\]/,+0apassword = ${NOVA_PASS}" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0ausername = nova" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0aproject_name = service" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0aregion_name = RegionOne" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0auser_domain_name = default" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0aproject_domain_name = default" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0aauth_type = password" /etc/neutron/neutron.conf
sed -i "/\[nova\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/neutron/neutron.conf

cp /etc/neutron/neutron.conf tmp/neutron.conf
if [ ! -f /etc/neutron/plugins/ml2/ml2_conf.ini.bak ];then
	cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.bak
else
	cp /etc/neutron/plugins/ml2/ml2_conf.ini.bak /etc/neutron/plugins/ml2/ml2_conf.ini
fi
sed -i "/\[ml2\]/,+0atype_drivers = flat,vlan,vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[ml2\]/,+0atenant_network_types = vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[ml2\]/,+0amechanism_drivers = linuxbridge,l2population" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[ml2\]/,+0aextension_drivers = port_security" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[ml2_type_flat\]/,+0aflat_networks = provider" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[ml2_type_vxlan\]/,+0avni_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/\[securitygroup\]/,+0aenable_ipset = True" /etc/neutron/plugins/ml2/ml2_conf.ini

cp /etc/neutron/plugins/ml2/ml2_conf.ini tmp/ml2_conf.ini
if [ ! -f /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak ];then
	cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak
else
	cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak /etc/neutron/plugins/ml2/linuxbridge_agent.ini
fi
sed -i "/\[linux_bridge\]/,+0aphysical_interface_mappings = provider:${PROVIDER_INTERFACE_NAME}" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[vxlan\]/,+0aenable_vxlan = True" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[vxlan\]/,+0alocal_ip = ${OVERLAY_INTERFACE_IP_ADDRESS}" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[vxlan\]/,+0al2_population = True" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[securitygroup\]/,+0aenable_security_group = True" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[securitygroup\]/,+0afirewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" /etc/neutron/plugins/ml2/linuxbridge_agent.ini

cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini tmp/linuxbridge_agent.ini
if [ ! -f /etc/neutron/l3_agent.ini.bak ];then
	cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.bak
else
	cp /etc/neutron/l3_agent.ini.bak /etc/neutron/l3_agent.ini
fi
sed -i "/^\[DEFAULT\]/,+0ainterface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver" /etc/neutron/l3_agent.ini
sed -i "/^\[DEFAULT\]/,+0aexternal_network_bridge = ${PROVIDER_INTERFACE_NAME}" /etc/neutron/l3_agent.ini

cp /etc/neutron/l3_agent.ini tmp/l3_agent.ini
if [ ! -f /etc/neutron/dhcp_agent.ini.bak ];then
	cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.bak
else
	cp /etc/neutron/dhcp_agent.ini.bak /etc/neutron/dhcp_agent.ini
fi
sed -i "/^\[DEFAULT\]/,+0ainterface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver" /etc/neutron/dhcp_agent.ini 
sed -i "/^\[DEFAULT\]/,+0adhcp_driver = neutron.agent.linux.dhcp.Dnsmasq" /etc/neutron/dhcp_agent.ini 
sed -i "/^\[DEFAULT\]/,+0aenable_isolated_metadata = True" /etc/neutron/dhcp_agent.ini 
cp /etc/neutron/dhcp_agent.ini tmp/dhcp_agent.ini

