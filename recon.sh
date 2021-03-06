#!/bin/sh
#
# Recon script
#
# Example:
# sh recon.sh > recon
# less -R recon
#
# Caveats:
# errno output may be a bit wonky
#

pprint() {
    printf "\033[38;5;155m===> $1\033[0m\n"
    echo "$2"
    echo
}

strerror() {
    echo "\033[38;5;1m$1: $(perl -MPOSIX -e 'print strerror('$1')."\n";')\033[0m\n"
}

pprint "System running"         "$(uname -a)"
pprint "Distribution"           "$(cat /etc/*-release || cat /etc/issue || freebsd-vesion || strerror $?)"
pprint "Filesystems"            "$(df)"
pprint "Block devices"          "$(lsblk || strerror $?)"
pprint "Network interfaces"     "$(ip a || ifconfig -a)"
pprint "Routing table"          "$(ip r || netstat -rn)"
pprint "DNS server(s)"          "$(cat /etc/resolv.conf || dig example.com | grep SERVER || host -a example.com | grep from)"
pprint "Users"                  "$(grep -vE '^#' /etc/passwd)"
pprint "Groups"                 "$(grep -Ev '^#' /etc/group)"
pprint "Admin accounts"         "$(grep -vE '^#' /etc/passwd | awk -F: '$3 == 0 { print $1}' || strerror $?)"
pprint "Logged in"              "$(w || who -a || users || finger || pinky || strerror $?)"
pprint "Last logged in"         "$(last || lastlog)"
pprint "Sudo permissions"       "$(sudo -ln 2> /dev/null|| strerror $?)"
pprint "Command history for $(whoami)" \
                                "$(cat ~/.bash_history || cat ~/.history)"
pprint "Python history for $(whoami)" \
                                "$(cat ~/.python_history || strerror $?)"
pprint "Environment"            "$(env)"
pprint "Shells"                 "$(grep -v '^#' /etc/shells)"
pprint "SUID files"             "$(find / -perm -4000 -type f 2> /dev/null)"
pprint "SUID owned by root"     "$(find / -uid 0 -perm -4000 -type f 2> /dev/null)"
pprint "GUID files"             "$(find / -perm -2000 -type f 2> /dev/null)"
pprint "World writable files"   "$(find / ! -path "*/proc/*" -a ! -path "/sys/*" -perm -2 -type f 2> /dev/null)"
pprint "World writeable directories" \
                                "$(find / -perm -2 -type d 2>/dev/null)"
pprint "Writeable files not owned by $(whoami)" \
                                "$(find / ! -path "/proc*" -a ! -path "/sys/*" -type f -perm -2 ! -user $(whoami) 2> /dev/null)"
pprint "/root"                  "$(ls -ahlR /root 2>/dev/null ||  strerror $?)"
pprint "root mail"              "$(head /var/mail/root 2> /dev/null || strerror $?)"
pprint "SSH files"              "$(find / -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" 2> /dev/null | while read filename; do ls -l ${filename} && \ 
                                    openssl enc -base64 -e -in ${filename} || base64 ${filename} && echo; done)"
pprint "Suspected credentials in logs" \
                                    "$(grep -lE 'pass|crede|creds' /var/log/*.log 2> /dev/null || strerror $?)"
pprint "Logs"                   "$(find /var/log -type f -exec ls -la {} \; 2> /dev/null)"
pprint "Open files"             "$(lsof -i -n 2> /dev/null || strerror $?)"
pprint "Processes running as root" \
                                "$(ps auxw | grep root | grep -v grep)"
pprint "Exports and NFS permissions" \
                                "$(cat /etc/exports 2>/dev/null || strerror $?)"
pprint "Cron jobs"              "$(ls -laR /var/spool/cron/crontabs || ls -laR /etc/cron* || ls -laR /etc/rc.d/cron)"
pprint "Open connections"       "$(lsof -i 2> /dev/null || sockstat 2> /dev/null || ss -putan || netstat -na || strerror $?)"
pprint "Firewall rules"         "$(iptables -nvL 2> /dev/null || cat /etc/pf.conf 2> /dev/null || strerror $?)"
pprint "Installed packages"     "$(dpkg -l | awk '{print $2, $3}' || rpm -qa || pkg info || pkg_info | cut -f1 -d' ' || strerror $?)"
