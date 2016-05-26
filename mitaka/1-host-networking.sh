#!/bin/bash
dns=$1
netfile=/etc/network/interfaces
eth00=(`ifconfig $2 | grep "inet " | tr -sc '[0-9.]' ' '`)
if [ ! -f ${netfile}.bak ]; then
	cp ${netfile} ${netfile}.bak
else
	cp ${netfile}.bak ${netfile}
fi
sed -i "/^auto ${interface}/s/^/#/"	$netfile
sed -i "/^iface ${interface}/s/^/#/"	$netfile
sed -i "/^	/s/^/#/"	$netfile
if [ $# -eq 3 ];then
	echo "auto $2" >>		$netfile
	echo "iface $2 inet static"	>>	$netfile
else
	echo "auto $2:0" >>		$netfile
	echo "iface $2:0 inet static"	>>	$netfile
fi
echo "	address	${eth00}"		>>	$netfile
echo "	netmask	255.255.255.0"		>>	$netfile
echo "	gateway	${eth00%.*}.1"		>>	$netfile
echo "	dns-nameservers	${dns}"		>>	$netfile

echo "# The provider network interface"		>>	$netfile	
if [ $# -eq 3 ];then
	echo "auto $3"					>>	$netfile	
	echo "iface $3 inet manual"			>>	$netfile	
else
	echo "auto $2:1"			>>	$netfile	
	echo "iface $2:1 inet manual"		>>	$netfile	
fi
echo "up ip link set dev \$IFACE  up"		>>	$netfile	
echo "down ip link set dev \$IFACE  down"	>>	$netfile	
