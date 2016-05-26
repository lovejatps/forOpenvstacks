#!/bin/bash
#PROVIDER_INTERFACE_NAME=eth1
PROVIDER_INTERFACE_NAME=$1
#OVERLAY_INTERFACE_IP_ADDRESS=192.168.102.123
OVERLAY_INTERFACE_IP_ADDRESS=$2
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
