#!/bin/bash
MARIADBPWD=$1
MANILA_DBPASS=$2
MANILA_PASS=$3
controller=$4
RABBIT_PASS=$5
localaddress=$6

if [ ! -f /var/log/shared_stat ];then
        echo "have done before !" > /var/log/shared_stat

        echo "CREATE DATABASE manila;" > tmp.sql
        echo "GRANT ALL PRIVILEGES ON cinder.* TO 'manila'@'localhost' IDENTIFIED BY '${MANILA_DBPASS}';" >> tmp.sql
        echo "GRANT ALL PRIVILEGES ON cinder.* TO 'manila'@'%' IDENTIFIED BY '${MANILA_DBPASS}';" >> tmp.sql

        mysql -uroot -p${MARIADBPWD} < tmp.sql
        rm -rf tmp.sql

        source admin-openrc

        openstack user create --domain default --password-prompt manila
        openstack role add --project service --user manila admin
        openstack service create --name manila  --description "OpenStack Shared File Systems" share
	openstack service create --name manilav2 --description "OpenStack Shared File Systems" sharev2
        openstack endpoint create --region RegionOne share public http://${controller}:8786/v1/%\(tenant_id\)s
        openstack endpoint create --region RegionOne share internal http://${controller}:8786/v1/%\(tenant_id\)s
        openstack endpoint create --region RegionOne share admin http://${controller}:8786/v1/%\(tenant_id\)s
        openstack endpoint create --region RegionOne sharev2 public http://${controller}:8786/v2/%\(tenant_id\)s
        openstack endpoint create --region RegionOne sharev2 internal http://${controller}:8786/v2/%\(tenant_id\)s
        openstack endpoint create --region RegionOne sharev2 admin http://${controller}:8786/v2/%\(tenant_id\)s

	apt-get install manila-api manila-scheduler python-manilaclient
fi
if [ ! -f /etc/manila/manila.conf.bak ];then
	cp /etc/manila/manila.conf /etc/manila/manila.conf.bak
else
	cp /etc/manila/manila.conf.bak /etc/manila/manila.conf
fi

sed -i "/^#connection =/cconnection = mysql+pymysql://manila:${MANILA_DBPASS}@${controller}/manila" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/manila/manila.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${controller}" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0arootwrap_config = /etc/manila/rootwrap.conf" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0adefault_share_type = default_share_type" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${MANILA_PASS}" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = manila" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${controller}:11211" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${controller}:35357" /etc/manila/manila.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${controller}:5000" /etc/manila/manila.conf
sed -i "/\[DEFAULT\]/,+0amy_ip = ${localaddress}" /etc/manila/manila.conf
sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/manila/tmp" /etc/manila/manila.conf
su -s /bin/sh -c "manila-manage db sync" manila
service manila-scheduler restart
service manila-api restart
