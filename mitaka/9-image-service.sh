#!/bin/bash
#MARIADBPWD=123456
MARIADBPWD=$1
#GLANCE_DBPASS=123456
GLANCE_DBPASS=$2
#GLANCE_PASS=123456
GLANCE_PASS=$3
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$4
if [ ! -f /var/log/image_stat ];then
	echo "have done before !" > /var/log/image_stat 
	
        echo "CREATE DATABASE glance;" > glance.sql
        echo "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}';" >> glance.sql
        echo "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';" >> glance.sql

        mysql -uroot -p${MARIADBPWD} < glance.sql
        rm -rf glance.sql
	
	source admin-openrc
	
	openstack user create --domain default --password-prompt glance
	openstack role add --project service --user glance admin
	openstack service create --name glance  --description "OpenStack Image" image
	openstack endpoint create --region RegionOne image public http://${CTL_HOST}:9292
	openstack endpoint create --region RegionOne image internal http://${CTL_HOST}:9292
	openstack endpoint create --region RegionOne image admin http://${CTL_HOST}:9292
fi
apt-get install glance
if [ ! -f /etc/glance/glance-api.conf.bak ];then
        cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak
else
        cp /etc/glance/glance-api.conf.bak /etc/glance/glance-api.conf
fi
sed -i "/^#connection =/cconnection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CTL_HOST}/glance" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${GLANCE_PASS}" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = glance" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/glance/glance-api.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/glance/glance-api.conf
sed -i "/\[paste_deploy\]/,+0aflavor = keystone" /etc/glance/glance-api.conf
sed -i "/\[glance_store\]/,+0afilesystem_store_datadir = /var/lib/glance/images/" /etc/glance/glance-api.conf
sed -i "/\[glance_store\]/,+0adefault_store = file" /etc/glance/glance-api.conf
sed -i "/\[glance_store\]/,+0astores = file,http" /etc/glance/glance-api.conf

cp /etc/glance/glance-api.conf tmp/glance-api.conf
if [ ! -f /etc/glance/glance-registry.conf.bak ];then
        cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak
else
        cp /etc/glance/glance-registry.conf.bak /etc/glance/glance-registry.conf
fi
sed -i "/\[database\]/,+0aconnection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CTL_HOST}/glance" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = glance" /etc/glance/glance-registry.conf
sed -i "/\[keystone_authtoken\]/,+0apassword = ${GLANCE_PASS}" /etc/glance/glance-registry.conf
sed -i "/\[paste_deploy\]/,+0aflavor = keystone" /etc/glance/glance-registry.conf
cp /etc/glance/glance-registry.conf tmp/glance-registry.conf	
su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart
if [ ! -f cirros ];then
	source admin-openrc
	
	if [ ! -f cirros-0.3.4-x86_64-disk.img ];then
		wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
	fi
	
	openstack image create "cirros" \
	  --file cirros-0.3.4-x86_64-disk.img \
	  --disk-format qcow2 --container-format bare \
	  --public
	
	openstack image list
	echo "have done !" > cirros
fi
