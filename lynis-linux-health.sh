echo "choose which setup type--1:wget-setup;2:git-setup;3:apt-get-setup;4:shutdown-IPV6&&ICMP&&Broadcast"
read tmp
if [ ${nettype} -eq 1 ]; then
wget http://cisofy.com/files/lynis-1.6.3.tar.gz
tar xvfvz lynis-1.6.3.tar.gz
$(pwd)/lynis-1.6.3/lynis --check-all -Q
fi
if [ ${nettype} -eq 2 ]; then
git clone https://github.com/CISOfy/lynis
$(pwd)lynis*/lynis --check-all -Q
fi
if [ ${nettype} -eq 3 ]; then
apt-get install lynis
fi
if [ ${nettype} -eq 4 ]; then
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
fi
