#!/bin/bash
MARIADBPWD=$1
CINDER_DBPASS=$2
controller=$3
RABBIT_PASS=$4
localaddress=$5
if [ ! -f /var/log/block_stat ];then
        echo "have done before !" > /var/log/block_stat

        echo "CREATE DATABASE cinder;" > cinder.sql
        echo "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '${CINDER_DBPASS}';" >> cinder.sql
        echo "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '${CINDER_DBPASS}';" >> cinder.sql

        mysql -uroot -p${MARIADBPWD} < cinder.sql
        rm -rf cinder.sql

        source admin-openrc

	openstack user create --domain default --password-prompt cinder
	openstack role add --project service --user cinder admin
	openstack service create --name cinder --description "OpenStack Block Storage" volume
	openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
	openstack endpoint create --region RegionOne volume public http://${controller}:8776/v1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne volume internal http://${controller}:8776/v1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne volume admin http://${controller}:8776/v1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne volumev2 public http://${controller}:8776/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne volumev2 internal http://${controller}:8776/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne volumev2 admin http://${controller}:8776/v2/%\(tenant_id\)s
	
	apt-get install cinder-api cinder-scheduler
fi
if [ ! -f /etc/cinder/cinder.conf.bak ];then
	cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak
else
	cp /etc/cinder/cinder.conf.bak /etc/cinder/cinder.conf
fi
sed -i "/^#connection =/cconnection = mysql+pymysql://cinder:${CINDER_DBPASS}@${controller}/cinder" /etc/cinder/cinder.conf
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
sed -i "/\[DEFAULT\]/,+0amy_ip = ${localaddress}" /etc/cinder/cinder.conf
sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/cinder/tmp" /etc/cinder/cinder.conf
su -s /bin/sh -c "cinder-manage db sync" cinder
if [ `cat /etc/nova/nova.conf | grep cinder | wc -l` -eq 0 ];then
	echo "[cinder]" >> /etc/nova/nova.conf
fi
sed -i "/\[cinder\]/,+0aos_region_name = RegionOne" /etc/nova/nova.conf
service nova-api restart
service cinder-scheduler restart
service cinder-api restart
