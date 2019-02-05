#!/bin/sh
#
# Note: depricated in favour of Ansible
#

hostname="my_hostname"
ip_address="1.2.3.4"
user="elasmo"

# Timezone, hostname & keymap
tzsetup -sr /usr/share/zoneinfo/Europe/Stockholm
sysrc hostname="${hostname}"
sysrc keymap="se.kbd"

# Update system
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update
env PAGER=cat freebsd-update fetch 
freebsd-update install

# Doas
pkg install -y doas
cat <<EOF > /usr/local/etc/doas.conf
permit persist setenv { -ENV PS1=$DOAS_PS1 SSH_AUTH_SOCK } :wheel
EOF

# OpenSSH
pkg install -y openssh-portable
sysrc sshd_enable="NO"
sysrc openssh_enable="YES"
cat <<EOF > /usr/local/etc/ssh/sshd_config
ListenAddress ${ip_address}
X11Forwarding no 
AllowTcpForwarding no
VersionAddendum none
PermitRootLogin no
ChallengeResponseAuthentication no
#AuthenticationMethods publickey
UsePAM no
Subsystem sftp  /usr/local/libexec/sftp-server
EOF

# OpenNTPD
pkg install -y openntpd
sysrc ntpd_enable="NO"
sysrc openntpd_enable="YES"
sysrc openntpd_flags="-s"
cat <<EOF > /usr/local/etc/ntpd.conf
servers pool.ntp.org
sensor *
constraints from "https://www.sunet.se"
EOF

# LibreSSL
pkg install -y libressl
cat <<EOF > /etc/make.conf
DEFAULT_VERSIONS+=ssl=libressl
EOF

# PF
sysrc pf_enable="YES"
cat <<EOF > /etc/pf.conf
set skip on lo
block return
pass
EOF

# rc.conf tunables
sysrc sendmail_enable="NO"
sysrc sendmail_outbound_enable="NO"                                                   
sysrc sendmail_submit_enable="NO"                                                     
sysrc sendmail_msp_queue_enable="NO" 
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"

# sysctl tuning
echo "cc_cubic_load=YES" >> /boot/loader.conf
cat <<EOF > /etc/sysctl.conf
kern.randompid=1                   
kern.random.fortuna.minpoolsize=128
net.inet.ip.check_interface=1      
net.inet.ip.process_options=0      
net.inet.ip.random_id=1            
net.inet.ip.redirect=0             
net.inet.tcp.cc.algorithm=cubic    
net.inet.icmp.drop_redirect=1      
net.inet.tcp.drop_synfin=1         
net.inet.sctp.blackhole=2          
net.inet.tcp.blackhole=2           
net.inet.udp.blackhole=1           
net.inet.tcp.icmp_may_rst=0        
security.bsd.hardlink_check_gid=1  
security.bsd.hardlink_check_uid=1  
security.bsd.see_other_gids=0      
security.bsd.see_other_uids=0      
security.bsd.stack_guard_page=1    
security.bsd.unprivileged_proc_debug=0 
security.bsd.unprivileged_read_msgbuf=0
EOF

# login.conf
cat <<"EOF" > /etc/login.conf
default:\
	:passwd_format=sha512:\
	:copyright=/etc/COPYRIGHT:\
	:welcome=/etc/motd:\
	:setenv=MAIL=/var/mail/$,BLOCKSIZE=K:\
	:path=/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin ~/bin:\
	:nologin=/var/run/nologin:\
	:cputime=unlimited:\
	:datasize=unlimited:\
	:stacksize=unlimited:\
	:memorylocked=64K:\
	:memoryuse=unlimited:\
	:filesize=unlimited:\
	:coredumpsize=unlimited:\
	:openfiles=unlimited:\
	:maxproc=unlimited:\
	:sbsize=unlimited:\
	:vmemoryuse=unlimited:\
	:swapuse=unlimited:\
	:pseudoterminals=unlimited:\
	:kqueues=unlimited:\
	:umtxp=unlimited:\
	:priority=0:\
	:ignoretime@:\
	:umask=022:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:

standard:\
	:tc=default:
xuser:\
	:tc=default:
staff:\
	:tc=default:
daemon:\
	:memorylocked=128M:\
	:tc=default:
news:\
	:tc=default:
dialer:\
	:tc=default:

root:\
	:ignorenologin:\
	:memorylocked=unlimited:\
	:tc=default:
EOF
cap_mkdb /etc/login.conf

# Periodic jobs
cat <<EOF > /etc/periodic.conf.local
daily_status_security_pkgaudit_enable="NO"
EOF

# Users
pw mod user -n root -P -w random 
pw useradd -n ${user} -s /bin/sh -m -G wheel -w random
