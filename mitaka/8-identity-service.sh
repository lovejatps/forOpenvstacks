#!/bin/bash
#MARIADBPWD=123456
MARIADBPWD=$1
#KEYSTONEPWD=123456
KEYSTONEPWD=$2
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$3
ch_stat=/var/log/keystone_stat
if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}

	echo "CREATE DATABASE keystone;" > keystone.sql
	echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONEPWD}';" >> keystone.sql
	echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONEPWD}';" >> keystone.sql
	
	mysql -uroot -p${MARIADBPWD} < keystone.sql
	rm -rf keystone.sql

	RANDPWD=`openssl rand -hex 10`
	
	if [ ! -f /etc/init/keystone.override ];then
		echo "manual" > /etc/init/keystone.override
	fi
	apt-get install keystone apache2 libapache2-mod-wsgi
	if [ ! -f /etc/keystone/keystone.conf.bak ];then
		cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak
	else
		cp /etc/keystone/keystone.conf.bak /etc/keystone/keystone.conf
	fi
	sed -i "/^#admin_token/cadmin_token = ${RANDPWD}" /etc/keystone/keystone.conf
	sed -i "/^connection =/cconnection = mysql+pymysql://keystone:${KEYSTONEPWD}@${CTL_HOST}/keystone" /etc/keystone/keystone.conf
	#sed -i "/^#provider =/cprovider = keystone.token.providers.uuid.Provider" /etc/keystone/keystone.conf
	sed -i "/^#provider =/cprovider = fernet" /etc/keystone/keystone.conf
	#sed -i "/^#driver=keystone.token.persistence.backends.sql.Token/s/#//" /etc/keystone/keystone.conf
	
	cp /etc/keystone/keystone.conf tmp/keystone.conf
	
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	
	keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	echo "Continue...?"
	read tmp
	
	if [ `sudo cat /etc/apache2/apache2.conf | grep ServerName | wc -l` -eq 0 ];then
		echo "ServerName ${CTL_HOST}" >> /etc/apache2/apache2.conf
	fi
	cp wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
	
	ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
	service apache2 restart
	rm -f /var/lib/keystone/keystone.db
	
	echo "export OS_TOKEN=`sudo cat /etc/keystone/keystone.conf | grep "^admin_token" | cut -b 15-`" > identifiedexport
	echo "export OS_URL=http://${CTL_HOST}:35357/v3" >> identifiedexport
	echo "export OS_IDENTITY_API_VERSION=3" >> identifiedexport
	source identifiedexport
	
	openstack service create  --name keystone --description "OpenStack Identity" identity
	openstack endpoint create --region RegionOne  identity public http://${CTL_HOST}:5000/v3
	openstack endpoint create --region RegionOne  identity internal http://${CTL_HOST}:5000/v3
	openstack endpoint create --region RegionOne  identity admin http://${CTL_HOST}:35357/v3
	openstack domain create --description "Default Domain" default
	openstack project create --domain default  --description "Admin Project" admin
	openstack user create --domain default  --password-prompt admin
	openstack role create admin
	openstack role add --project admin --user admin admin
	openstack project create --domain default  --description "Service Project" service
	openstack project create --domain default  --description "Demo Project" demo
	openstack user create --domain default  --password-prompt demo
	openstack role create user
	openstack role add --project demo --user demo user
	
	if [ ! -f /etc/keystone/keystone-paste.ini.bak ];then
		cp /etc/keystone/keystone-paste.ini /etc/keystone/keystone-paste.ini.bak
	else
		cp /etc/keystone/keystone-paste.ini.bak /etc/keystone/keystone-paste.ini
	fi
	sed -i "/^pipeline/s/admin_token_auth//" /etc/keystone/keystone-paste.ini
	cp /etc/keystone/keystone-paste.ini tmp/keystone-paste.ini
	
	echo "unset OS_TOKEN OS_URL" > identifiedexport
	source identifiedexport
	
	openstack --os-auth-url http://${CTL_HOST}:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue
	openstack --os-auth-url http://${CTL_HOST}:5000/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name demo --os-username demo token issue
	
	echo "export OS_PROJECT_DOMAIN_NAME=default"	> admin-openrc
	echo "export OS_USER_DOMAIN_NAME=default"	>>	admin-openrc
	echo "export OS_PROJECT_NAME=admin"		>>	admin-openrc
	echo "export OS_USERNAME=admin"			>>	admin-openrc
	echo "export OS_PASSWORD=123456"		>>	admin-openrc
	echo "export OS_AUTH_URL=http://${CTL_HOST}:35357/v3"	>>	admin-openrc
	echo "export OS_IDENTITY_API_VERSION=3"		>>	admin-openrc
	echo "export OS_IMAGE_API_VERSION=2"		>>	admin-openrc
	
	echo "export OS_PROJECT_DOMAIN_NAME=default"	>	demo-openrc
	echo "export OS_USER_DOMAIN_NAME=default"	>>	demo-openrc
	echo "export OS_PROJECT_NAME=demo"		>>	demo-openrc
	echo "export OS_USERNAME=demo"			>>	demo-openrc
	echo "export OS_PASSWORD=123456"		>>	demo-openrc
	echo "export OS_AUTH_URL=http://${CTL_HOST}:5000/v3"	>>	demo-openrc
	echo "export OS_IDENTITY_API_VERSION=3"		>>	demo-openrc
	echo "export OS_IMAGE_API_VERSION=2"		>>	demo-openrc
	
	source admin-openrc
	openstack token issue
	source demo-openrc
fi
