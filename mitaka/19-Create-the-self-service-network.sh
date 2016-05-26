#!/bin/bash
lan_name=tlan1
sublan_name=subtlan1
router_name=route1
DNS_RESOLVER=$1
#provider="192.168.11.0/24"
provider=provider1
subprovider=subprovider1
START_IP_ADDRESS=$2
END_IP_ADDRESS=$3
PROVIDER_NETWORK_GATEWAY=$4
PROVIDER_NETWORK_CIDR=$5
SELFSERVICE_NETWORK_GATEWAY=192.168.168.1
SELFSERVICE_NETWORK_CIDR=192.168.168.0/24
ch_stat=/var/log/selfservice_stat

if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}

	source admin-openrc
	neutron net-create --shared --provider:physical_network provider --provider:network_type flat ${provider}
	neutron net-update ${provider} --router:external True
	neutron subnet-create --name ${subprovider} --allocation-pool start=${START_IP_ADDRESS},end=${END_IP_ADDRESS} --dns-nameserver ${DNS_RESOLVER} --gateway ${PROVIDER_NETWORK_GATEWAY} ${provider} ${PROVIDER_NETWORK_CIDR}

	source demo-openrc
	neutron net-create ${lan_name}
	neutron subnet-create --name ${sublan_name} \
	  --dns-nameserver ${DNS_RESOLVER} --gateway ${SELFSERVICE_NETWORK_GATEWAY} \
	  ${lan_name} ${SELFSERVICE_NETWORK_CIDR}

	source demo-openrc
	neutron router-create ${router_name}
	neutron router-interface-add ${router_name} ${sublan_name}
	neutron router-gateway-set ${router_name} ${provider}
fi
