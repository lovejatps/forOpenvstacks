# forOpenvstack
about virtual machine technology

Centos yum source:
1，进入yum源配置目录
cd /etc/yum.repos.d
2，备份系统自带的yum源
mv CentOS-Base.repo CentOS-Base.repo.bk
下载163网易的yum源：
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
3，更新玩yum源后，执行下边命令更新yum配置，使操作立即生效
yum makecache
