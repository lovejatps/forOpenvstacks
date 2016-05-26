#!/bin/bash
#eth0=192.168.168.25
ch_stat=/var/log/mariadb_stat
confile=/etc/mysql/my.cnf
eth0=$1
if [ ! -f ${ch_stat} ];then
	apt-get install mariadb-server python-pymysql
	if [ ! -f ${confile}.bak ];then
		cp ${confile} ${confile}.bak
	else
		cp ${confile}.bak ${confile}
	fi
	sed -i "/^bind-address/cbind-address = ${eth0}" ${confile}
	sed -i "/bind-address/,+0acharacter-set-server = utf8" ${confile}
	sed -i "/bind-address/,+0acollation-server = utf8_general_ci" ${confile}
	sed -i "/bind-address/,+0adefault-storage-engine = innodb" ${confile}
	echo "have done before!" > ${ch_stat}
	cp ${confile} tmp/my.conf
	service mysql restart
	mysql_secure_installation
else
	service mysql restart
fi
