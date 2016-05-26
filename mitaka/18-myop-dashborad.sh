#!/bin/bash
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$1
apt-get install openstack-dashboard
if [ ! -f /etc/openstack-dashboard/local_settings.py.bak ];then
	cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.bak
else
	cp /etc/openstack-dashboard/local_settings.py.bak /etc/openstack-dashboard/local_settings.py
fi
sed -i "/^OPENSTACK_HOST = /cOPENSTACK_HOST = \"${CTL_HOST}\"" /etc/openstack-dashboard/local_settings.py
sed -i "/^ALLOWED_HOSTS = /cALLOWED_HOSTS = ['*', ]" /etc/openstack-dashboard/local_settings.py
sed -i "/^SECRET_KEY/,+0aSESSION_ENGINE = 'django.contrib.sessions.backends.cache'" /etc/openstack-dashboard/local_settings.py
sed -i "/'LOCATION': '127.0.0.1:11211',/s//'LOCATION': '${CTL_HOST}:11211',/" /etc/openstack-dashboard/local_settings.py

sed -i "/OPENSTACK_KEYSTONE_URL = /cOPENSTACK_KEYSTONE_URL = \"http://%s:5000/v3\" % OPENSTACK_HOST" /etc/openstack-dashboard/local_settings.py
sed -i "/OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = /cOPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True" /etc/openstack-dashboard/local_settings.py
sed -i "/^#OPENSTACK_API_VERSIONS = {/s/#//" /etc/openstack-dashboard/local_settings.py

sed -i "/^#    \"identity\": 3,/s/#//" /etc/openstack-dashboard/local_settings.py
sed -i "/^#    \"volume\": 2,/s/#//" /etc/openstack-dashboard/local_settings.py
sed -i "/^    \"identity\": 3,/,+0a    \"image\": 2," /etc/openstack-dashboard/local_settings.py
sed -i "/^    \"volume\": 2,/,+0a}" /etc/openstack-dashboard/local_settings.py
sed -i "/^\"image\": 2,/s/^/    /" /etc/openstack-dashboard/local_settings.py

sed -i "/OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = /cOPENSTACK_KEYSTONE_DEFAULT_DOMAIN = \"default\"" /etc/openstack-dashboard/local_settings.py
sed -i "/OPENSTACK_KEYSTONE_DEFAULT_ROLE = /cOPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"" /etc/openstack-dashboard/local_settings.py

#sed -i "/OPENSTACK_NEUTRON_NETWORK = {/cOPENSTACK_NEUTRON_NETWORK = {" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_router/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_quotas/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_distributed_router/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_ha_router/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_lb/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_firewall/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_vpn/s/False/True/" /etc/openstack-dashboard/local_settings.py
sed -i "/enable_fip_topology_check/s/False/True/" /etc/openstack-dashboard/local_settings.py

sed -i "/TIME_ZONE = /cTIME_ZONE = \"Asia/Shanghai\"" /etc/openstack-dashboard/local_settings.py

cp /etc/openstack-dashboard/local_settings.py tmp/local_settings.py
service apache2 reload
