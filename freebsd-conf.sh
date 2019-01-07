#!/bin/sh

hostname="my_hostname"
ip_address="1.2.3.4"

sysrc hostname="${hostname}"
pkg update
freebsd-update fetch install

# OpenSSH
pkg install openssh-portable
sysrc sshd_enable="NO"
sysrc openssh_enable="YES"
cat <<EOF > /usr/local/etc/ssh/sshd_config
ListenAddress ${ip_address}
X11Forwarding no 
VersionAddendum none
EOF

# OpenNTPD
pkg install openntpd
sysrc ntpd_enable="NO"
sysrc openntpd_enable="YES"
sysrc openntpd_flags="-s"

# PF
sysrc pf_enable="YES"
cat <<EOF > /etc/pf.conf
set skip on lo
block return
pass
EOF

# Disable Sendmail
sysrc sendmail_enable="NO"
sysrc sendmail_outbound_enable="NO"                                                   
sysrc sendmail_submit_enable="NO"                                                     
sysrc sendmail_msp_queue_enable="NO" 

# LibreSSL
pkg install libressl
cat <<EOF > /etc/make.conf
DEFAULT_VERSIONS+=ssl=libressl
EOF

# Clear /tmp
sysrc clear_tmp_enable="YES"

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

# Periodic jobs tuning
cat <<EOF > /etc/periodic.conf.local
daily_status_security_pkgaudit_enable
EOF
