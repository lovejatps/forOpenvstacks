#!/bin/bash
controller=$1
SWIFT_PASS=$2
. admin-openrc
if [ ! -f /var/log/obj_storage_stat ];then
	openstack user create --domain default --password-prompt swift
	openstack role add --project service --user swift admin
	openstack service create --name swift --description "OpenStack Object Storage" object-store
	openstack endpoint create --region RegionOne object-store public http://${controller}:8080/v1/AUTH_%\(tenant_id\)s
	openstack endpoint create --region RegionOne object-store internal http://${controller}:8080/v1/AUTH_%\(tenant_id\)s
	openstack endpoint create --region RegionOne object-store admin http://${controller}:8080/v1
	apt-get install swift swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached
	mkdir /etc/swift
	curl -o /etc/swift/proxy-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/mitaka
	echo "have done before" > /var/log/obj_storage_stat
fi
if [ ! -f /etc/swift/proxy-server.conf.bak ];then
	cp /etc/swift/proxy-server.conf /etc/swift/proxy-server.conf.bak
else
	cp /etc/swift/proxy-server.conf.bak /etc/swift/proxy-server.conf
fi
sed -i "/\[DEFAULT\]/,+0aswift_dir = /etc/swift" /etc/swift/proxy-server.conf
sed -i "/\[DEFAULT\]/,+0auser = swift" /etc/swift/proxy-server.conf
sed -i "/bind_port =/cbind_port = 8080" /etc/swift/proxy-server.conf
sed -i "/pipeline =/cpipeline = catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server" /etc/swift/proxy-server.conf

sed -i "/account_autocreate =/caccount_autocreate = True" /etc/swift/proxy-server.conf

sed -i "/filter:keystoneauth/s/#//" /etc/swift/proxy-server.conf
sed -i "/filter:keystoneauth/s/ //" /etc/swift/proxy-server.conf
sed -i "/filter:keystoneauth/,+0aoperator_roles = admin,user" /etc/swift/proxy-server.conf
sed -i "/filter:keystoneauth/,+0ause = egg:swift#keystoneauth" /etc/swift/proxy-server.conf

sed -i "/filter:authtoken/s/#//" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/s/ //" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0adelay_auth_decision = True" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0apassword = ${SWIFT_PASS}" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0ausername = swift" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0aproject_name = service" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0auser_domain_name = default" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0aproject_domain_name = default" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0aauth_type = password" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0amemcached_servers = ${controller}:11211" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0aauth_url = http://${controller}:35357" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0aauth_uri = http://${controller}:5000" /etc/swift/proxy-server.conf
sed -i "/filter:authtoken/,+0apaste.filter_factory = keystonemiddleware.auth_token:filter_factory" /etc/swift/proxy-server.conf

sed -i "/use = egg:swift#memcache/,+0amemcache_servers = ${controller}:11211" /etc/swift/proxy-server.conf
