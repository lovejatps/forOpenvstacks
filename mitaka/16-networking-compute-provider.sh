#!/bin/bash
#PROVIDER_INTERFACE_NAME=eth0:1
PROVIDER_INTERFACE_NAME=$1
if [ ! -f /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak ];then
	cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak
else
	cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak /etc/neutron/plugins/ml2/linuxbridge_agent.ini
fi
sed -i "/\[linux_bridge\]/,+0aphysical_interface_mappings = provider:${PROVIDER_INTERFACE_NAME}" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[vxlan\]/,+0aenable_vxlan = False" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[securitygroup\]/,+0aenable_security_group = True" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "/\[securitygroup\]/,+0afirewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini tmp/linuxbridge_agent.ini
