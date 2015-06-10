#iptables-persistent
natServer=218.240.151.112
insideDev=192.168.10.0/24
#turn natServer into open ip_forward service
sed -i "/^#net.ipv4.ip_forward=1/cnet.ipv4.ip_forward=1" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
#allow insideDev ping outside
iptables -t nat -A POSTROUTING -s ${insideDev} -j SNAT \
--to-source ${natServer}
#allow outside link insideDev port 42522
iptables -t nat -A PREROUTING -d ${natServer} -p tcp -m tcp --dport 42522 \
-j DNAT --to-destination 192.168.10.11:22
#allow outside link NATSERVER port 41522
iptables -A INPUT -d ${natServer} -p tcp --dport 41522 -j ACCEPT
#reject ALL link
iptables -A INPUT -d ${natServer} -j REJECT \
--reject-with icmp-host-prohibited
