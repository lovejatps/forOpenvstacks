#!/bin/bash
manageth=eth0
providereth=${manageth}
mariadbpwd=123456
rabbit_passwd=123456
keystonepwd=123456
glancepwd=123456
novadbpwd=123456
novapwd=123456
neutrondbpwd=123456
metadata_secret=123456
cinderdbpwd=123456
cinderpwd=123456
control=`cat control-node.sh | grep control= | cut -b 9-`
localnode=mitaka-33.wodezoon.com
dns_server=192.168.11.254
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
echo "############Start/Restart NTP!"
./2-network-time-protocal.sh ${control}
echo "############Start/Restart Openstack-Package!"
./3-openstack-package.sh
echo "############Start/Restart compute-Service ! enter 'y' or 'Y' to continue !"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./11-compute-service-node.sh ${novadbpwd} ${rabbit_passwd} ${novapwd} ${ipaddr} ${control}
fi
echo "############Start/Restart networking-service.sh-Setup! enter 'y' or 'Y' to continue !"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./15-networking-compute.sh ${rabbit_passwd} ${neutrondbpwd} ${control} ${providereth} ${ipaddr}
fi
echo "############Start/Restart Block Storage Service!enter 'y' or 'Y' to continue !"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./21-Block-Storage-node.sh ${cinderdbpwd} ${cinderpwd} ${control} ${rabbit_passwd} ${ipaddr}
fi
echo "############Start/Restart Shared-File-System Service!enter 'y' or 'Y' to continue !"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./23-Shared-File-System-Service-node.sh ${cinderdbpwd} ${cinderpwd} ${control} ${rabbit_passwd} ${ipaddr}
fi
