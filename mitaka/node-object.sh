#!/bin/bash
MANAGEMENT_INTERFACE_IP_ADDRESS=$1
if [ ! -f /var/log/obj_stat ];then
	apt-get install xfsprogs rsync
	mkfs.xfs /dev/sdb
	mkfs.xfs /dev/sdc
	mkdir -p /srv/node/sdb
	mkdir -p /srv/node/sdc
	/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
	/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
	mount /srv/node/sdb
	mount /srv/node/sdc
	if [ ! -f /etc/rsyncd.conf ];then
		cp rsyncd.conf /etc/rsyncd.conf
	fi
	sed -i "/address =/caddress = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/rsyncd.conf
	if [ ! -f /etc/default/rsync.bak ];then
		cp /etc/default/rsync /etc/default/rsync.bak
	else
		cp /etc/default/rsync.bak /etc/default/rsync
	fi
	sed -i "/RSYNC_ENABLE=/cRSYNC_ENABLE=true" /etc/default/rsync
	service rsync start

	apt-get install swift swift-account swift-container swift-object
	curl -o /etc/swift/account-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/account-server.conf-sample?h=stable/mitaka
	curl -o /etc/swift/container-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/container-server.conf-sample?h=stable/mitaka
	curl -o /etc/swift/object-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/object-server.conf-sample?h=stable/mitaka
	echo "have done before" > /var/log/obj_stat
fi
if [ ! -f /etc/swift/account-server.conf.bak ];then
	cp /etc/swift/account-server.conf /etc/swift/account-server.conf.bak
else
	cp /etc/swift/account-server.conf.bak /etc/swift/account-server.conf
fi
sed -i "/bind_ip =/cbind_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/swift/account-server.conf
sed -i "/bind_port =/cbind_port = 6002" /etc/swift/account-server.conf
sed -i "/user =/cuser = swift" /etc/swift/account-server.conf
sed -i "/swift_dir =/cswift_dir = /etc/swift" /etc/swift/account-server.conf
sed -i "/devices =/cdevices = /srv/node" /etc/swift/account-server.conf
sed -i "/mount_check =/cmount_check = True" /etc/swift/account-server.conf
sed -i "/pipeline =/cpipeline = healthcheck recon account-server" /etc/swift/account-server.conf
sed -i "/use = egg:swift#recon/,+0arecon_cache_path = /var/cache/swift" /etc/swift/account-server.conf


if [ ! -f /etc/swift/container-server.conf.bak ];then
	cp /etc/swift/container-server.conf /etc/swift/container-server.conf.bak
else
	cp /etc/swift/container-server.conf.bak /etc/swift/container-server.conf
fi
sed -i "/bind_ip =/cbind_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/swift/container-server.conf
sed -i "/bind_port =/cbind_port = 6001" /etc/swift/container-server.conf
sed -i "/user =/cuser = swift" /etc/swift/container-server.conf
sed -i "/swift_dir =/cswift_dir = /etc/swift" /etc/swift/container-server.conf
sed -i "/devices =/cdevices = /srv/node" /etc/swift/container-server.conf
sed -i "/mount_check =/cmount_check = True" /etc/swift/container-server.conf
sed -i "/pipeline =/cpipeline = healthcheck recon container-server" /etc/swift/container-server.conf
sed -i "/use = egg:swift#recon/,+0arecon_cache_path = /var/cache/swift" /etc/swift/container-server.conf

if [ ! -f /etc/swift/object-server.conf.bak ];then
	cp /etc/swift/object-server.conf /etc/swift/object-server.conf.bak
else
	cp /etc/swift/object-server.conf.bak /etc/swift/object-server.conf
fi
sed -i "/bind_ip =/cbind_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/swift/object-server.conf
sed -i "/bind_port =/cbind_port = 6000" /etc/swift/object-server.conf
sed -i "/user =/cuser = swift" /etc/swift/object-server.conf
sed -i "/swift_dir =/cswift_dir = /etc/swift" /etc/swift/object-server.conf
sed -i "/devices =/cdevices = /srv/node" /etc/swift/object-server.conf
sed -i "/mount_check =/cmount_check = True" /etc/swift/object-server.conf
sed -i "/pipeline =/cpipeline = healthcheck recon object-server" /etc/swift/object-server.conf
sed -i "/use = egg:swift#recon/,+0arecon_lock_path = /var/lock" /etc/swift/object-server.conf
sed -i "/use = egg:swift#recon/,+0arecon_cache_path = /var/cache/swift" /etc/swift/object-server.conf

chown -R swift:swift /srv/node
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift
