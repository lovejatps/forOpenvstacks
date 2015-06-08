echo "choose which setup type--1:wget-setup;2:git-setup;3:apt-get-setup"
read tmp
if [ ${nettype} -eq 1 ]; then
wget http://cisofy.com/files/lynis-1.6.3.tar.gz
tar xvfvz lynis-1.6.3.tar.gz
$(pwd)/lynis-1.6.3/lynis --check-all -Q
fi
if [ ${nettype} -eq 1 ]; then
git clone https://github.com/CISOfy/lynis
$(pwd)lynis*/lynis --check-all -Q
fi
if [ ${nettype} -eq 1 ]; then
apt-get install lynis
fi
