#!/bin/bash
#---------------配置公钥--------------------
cat >> /root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvRrCUSL4BYdQkr1STfAPOzwHoncPm3nbGZEoZFuAr/Wr2YT7/lwUc5AHFrmsxnJJLg86PAY7DswTk1zbRMvaP/4EYNQxQUqG62k2pPD8Aw1ZKQJT/N9JFkPSC/dUFSXxo2knQqXi0AxgBVPdcyhCCNgu8I4fVyw8u3vh9ryD+AxjqwcpvmbAN7t9iRykLHriYTXyCaOfXG/EM8xtdFb6IGVt8Wn715ZxIMkjwpaJHRAd6gcoSC8mkSse6kMtBh35CajexxR5QFSFvMrLyI0gbA9VLheAhEnfjGhHMW7UFPYGOyajmLiuoonYkvPwiuPOMyv4TtAn6Eroe0tNh8a2f root@proxy
EOF

#--------------配置Yum仓库-----------------
mkdir -p /etc/yum.repos.d/repo_bak/
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo_bak/
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.myhuaweicloud.com/repo/CentOS-Base-7.repo
m -rf /var/run/yum.pid
yum makecache
cat > /etc/yum.repos.d/local.repo << EOF
[local]
name=local
baseurl='ftp://192.168.1.222/rpm'
enable=1
gpgcheck=0
EOF
#------------------配置时间,DNS服务----------------
yum -y install chrony
cat > /etc/resolv.conf << EOF
search test.hkz
nameserver 192.168.1.222
EOF
cat > /etc/chrony.conf << EOF
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
server  ntp.myhuaweicloud.com  iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
EOF
systemctl restart chronyd 
systemctl enable  chronyd
#--------------卸载不需要服务-----------------
systemctl stop  ntpd
yum -y remove ntp
yum -y remove postfix.x86_64 
#-------------安装必备软件---------------------
yum -y install bash-completion.noarch


