#!/bin/bash
control=mitaka-25.wodezoon.com
source admin-openrc
echo "Check Chrony Service"
chronyc sources
echo "Check Identity Service"
openstack --os-auth-url http://${control}:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue
openstack --os-auth-url http://${control}:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue

echo "Check Image Service"
openstack image list

echo "Check Compute Service"
openstack compute service list

echo "Check Network Service"
neutron ext-list
