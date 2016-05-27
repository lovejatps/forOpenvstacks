#!/bin/bash
#MARIADBPWD=123456
MARIADBPWD=$1
#NOVA_DBPASS=123456
NOVA_DBPASS=$2
#RABBIT_PASS=123456
RABBIT_PASS=$3
#NOVA_PASS=123456
NOVA_PASS=$4
#my_ip=192.168.102.11
my_ip=$5
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$6
if [ ! -f /var/log/nova_stat ];then
	echo "have done before !" > /var/log/nova_stat

	echo "CREATE DATABASE nova_api;" > nova.sql
	echo "CREATE DATABASE nova;" >> nova.sql
        echo "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';" >> nova.sql
        echo "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';" >> nova.sql
        echo "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';" >> nova.sql
        echo "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';" >> nova.sql

        mysql -uroot -p${MARIADBPWD} < nova.sql
        rm -rf nova.sql
	
	source admin-openrc
	
	openstack user create --domain default --password-prompt nova
	openstack role add --project service --user nova admin
	openstack service create --name nova --description "OpenStack Compute" compute
	openstack endpoint create --region RegionOne compute public http://${CTL_HOST}:8774/v2.1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute internal http://${CTL_HOST}:8774/v2.1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute admin http://${CTL_HOST}:8774/v2.1/%\(tenant_id\)s

	apt-get install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler

	#from baidu:http://jingyan.baidu.com/article/359911f57ced1357fe030619.html
	#rm -rf /var/lib/nova/nova.sqlite
fi

if [ ! -f /etc/nova/nova.conf.bak ];then
        cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
else
        cp /etc/nova/nova.conf.bak /etc/nova/nova.conf
fi

echo "[api_database]" >> /etc/nova/nova.conf
echo "[database]" >> /etc/nova/nova.conf
echo "[oslo_messaging_rabbit]" >> /etc/nova/nova.conf
echo "[keystone_authtoken]" >> /etc/nova/nova.conf
echo "[vnc]" >> /etc/nova/nova.conf
echo "[glance]" >> /etc/nova/nova.conf
echo "[oslo_concurrency]" >> /etc/nova/nova.conf
sed -i "/enabled_apis/cenabled_apis = osapi_compute,metadata" /etc/nova/nova.conf
sed -i "/\[api_database\]/,+0aconnection = mysql+pymysql://nova:${NOVA_DBPASS}@${CTL_HOST}/nova_api" /etc/nova/nova.conf
sed -i "/\[database\]/,+0aconnection = mysql+pymysql://nova:${NOVA_DBPASS}@${CTL_HOST}/nova" /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0arpc_backend = rabbit" /etc/nova/nova.conf

sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_host = ${CTL_HOST}" /etc/nova/nova.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_userid = openstack" /etc/nova/nova.conf
sed -i "/\[oslo_messaging_rabbit\]/,+0arabbit_password = ${RABBIT_PASS}" /etc/nova/nova.conf

sed -i "/\[DEFAULT\]/,+0aauth_strategy = keystone" /etc/nova/nova.conf

sed -i "/\[keystone_authtoken\]/,+0apassword = ${NOVA_DBPASS}" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0ausername = nova" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_name = service" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0auser_domain_name = default" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aproject_domain_name = default" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_type = password" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0amemcached_servers = ${CTL_HOST}:11211" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_url = http://${CTL_HOST}:35357" /etc/nova/nova.conf
sed -i "/\[keystone_authtoken\]/,+0aauth_uri = http://${CTL_HOST}:5000" /etc/nova/nova.conf

sed -i "/\[DEFAULT\]/,+0amy_ip = ${my_ip}" /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0ause_neutron = True" /etc/nova/nova.conf
sed -i "/\[DEFAULT\]/,+0afirewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

sed -i "/\[vnc\]/,+0avncserver_listen = \$my_ip" /etc/nova/nova.conf
sed -i "/\[vnc\]/,+0avncserver_proxyclient_address = \$my_ip" /etc/nova/nova.conf

sed -i "/\[glance\]/,+0aapi_servers = http://${CTL_HOST}:9292" /etc/nova/nova.conf

sed -i "/\[oslo_concurrency\]/,+0alock_path = /var/lib/nova/tmp" /etc/nova/nova.conf

cp /etc/nova/nova.conf tmp/nova.conf.10
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova
service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
