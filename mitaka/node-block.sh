#!/bin/bash
CINDER_DBPASS=123456
CINDER_PASS=123456
controller=`cat control-node.sh | grep control= | cut -b 9-`
RABBIT_PASS=`cat control-node.sh | grep rabbit_passwd= | cut -b 15-`
MANAGEMENT_INTERFACE_IP_ADDRESS=(`ifconfig eth0 | grep "inet " | tr -sc '[0-9.]' ' '`)
if [ ! -f /var/log/block_stat ];then
	apt-get install lvm2
	pvcreate /dev/sdb
	vgcreate cinder-volumes /dev/sdb
	echo "have done before" > /var/log/block_stat
fi
if [ ! -f /etc/lvm/lvm.conf.bak ];then
	cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak
else
	cp /etc/lvm/lvm.conf.bak /etc/lvm/lvm.conf
fi
sed -i "/devices {/,+0atobechange    filter = [ \"a\/sdb/\", \"r\/.*/\"]" /etc/lvm/lvm.conf
sed -i "/tobechange/s/tobechange//" /etc/lvm/lvm.conf
sed -i "/devices {/,+0atobechange    filter = [ \"a\/sda/\", \"a\/sdb/\", \"r\/.*/\"]" /etc/lvm/lvm.conf
sed -i "/tobechange/s/tobechange//" /etc/lvm/lvm.conf
apt-get install cinder-volume
if [ ! -f /etc/cinder/cinder.conf.bak ];then
	cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak
else
	cp /etc/cinder/cinder.conf.bak /etc/cinder/cinder.conf
fi

echo "[database]"		>> /etc/cinder/cinder.conf
echo "[oslo_messaging_rabbit]"	>> /etc/cinder/cinder.conf
echo "[keystone_authtoken]"	>> /etc/cinder/cinder.conf
echo "[lvm]"			>> /etc/cinder/cinder.conf
echo "[oslo_concurrency]"	>> /etc/cinder/cinder.conf

sed -i "/\[database\]/,+0aconnection = mysql+pymysql://cinder:${CINDER_DBPASS}@${controller}/cinder" /etc/cinder/cinder.conf
sed -i "/\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/cinder/cinder.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/cinder/cinder.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/cinder/cinder.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${controller}" /etc/cinder/cinder.conf
sed -i "/\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${CINDER_PASS}" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = cinder" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${controller}:11211" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${controller}:35357" /etc/cinder/cinder.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${controller}:5000" /etc/cinder/cinder.conf
sed -i "/\[DEFAULT\]/,+0amy_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/cinder/cinder.conf
sed -i "/\[lvm\]/,+0aiscsi_helper = tgtadm" /etc/cinder/cinder.conf
sed -i "/\[lvm\]/,+0aiscsi_protocol = iscsi" /etc/cinder/cinder.conf
sed -i "/\[lvm\]/,+0avolume_group = cinder-volumes" /etc/cinder/cinder.conf
sed -i "/\[lvm\]/,+0avolume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver" /etc/cinder/cinder.conf
sed -i "/\[DEFAULT\]/,+0aenabled_backends = lvm" /etc/cinder/cinder.conf
sed -i "/\[DEFAULT\]/,+0aglance_api_servers = http://${controller}:9292" /etc/cinder/cinder.conf
sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/cinder/tmp" /etc/cinder/cinder.conf
service tgt restart
service cinder-volume restart
