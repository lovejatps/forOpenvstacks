#!/bin/bash
manageth=eth0
providereth=${manageth}
rabbit_passwd=123456
mariadbpwd=123456
novadbpwd=123456
keystonepwd=123456
glancepwd=123456
neutrondbpwd=123456
metadata_secret=123456
novapwd=123456
control=`cat control-node.sh | grep control= | cut -b 9-`
localnode=mitaka-compute1.wodezoon.com
dns_server=192.168.102.18
ch_stat=/var/log/control_stat

if [ ! -f ${ch_stat} ];then
	ipaddr=(`ifconfig ${manageth} | grep "inet " | tr -sc '[0-9.]' ' '`)
	echo "Your Current ${manageth} IP Adrress is ${ipaddr}"
	sed -i "/127/s/^/#/" /etc/hosts
	echo "${localnode}" > /etc/hostname
	hostname ${localnode}
	./1-host-networking.sh ${dns_server} ${manageth}
	echo "have reboot before" > ${ch_stat}
	reboot
	echo "please contiune after this reboot !"
	read thereboot
else
	ipaddr=(`ifconfig ${manageth}:0 | grep "inet " | tr -sc '[0-9.]' ' '`)
	echo "Your Current ${manageth}:0 IP Adrress is ${ipaddr}"
fi
echo "############Start NTP!"
./2-network-time-protocal.sh ${control}
echo "############Start Openstack-Package!"
./3-openstack-package.sh
echo "############Start compute-Service"
./11-compute-service-node.sh ${novadbpwd} ${rabbit_passwd} ${novapwd} ${ipaddr} ${control}
echo "############Start networking-service.sh-Setup!"
./15-networking-compute.sh ${rabbit_passwd} ${neutrondbpwd} ${control} ${providereth} ${ipaddr}
