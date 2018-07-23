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

error() {
    strerror=$(perl -MPOSIX -e 'print strerror('$1')."\n";')
    echo "\033[38;5;1m$1: ${strerror}\033[0m\n"
}

pprint "Systems running"        "$(uname -a)"
pprint "Distribution"           "$(cat /etc/*-release || cat /etc/issue || error $?)"
pprint "Filesystems"            "$(df -a)"
pprint "Network interfaces"     "$(ip a || ifconfig)"
pprint "Routing table"          "$(ip r || netstat -rn)"
pprint "DNS server(s)"          "$(cat /etc/resolv.conf || dig example.com | grep SERVER || host -a example.com | grep from)"
pprint "Users"                  "$(grep -vE ^# /etc/passwd)"
pprint "Groups"                 "$(grep -Ev ^# /etc/group)"
pprint "Admin accounts"         "$(grep -vE '^#' /etc/passwd | awk -F: '$3 == 0 { print $1}' || error $?)"
pprint "Logged in"              "$(finger || w || who -a || pinky || users || error $?)"
pprint "Last logged in"         "$(last || lastlog)"
pprint "Sudo permissions"       "$(sudo -ln 2> /dev/null|| error $?)"
pprint "Command history for $(whoami)" \
                                "$(cat ~/.bash_history || cat ~/.history)"
pprint "Environment"            "$(env)"
pprint "Shells"                 "$(grep -v ^# /etc/shells)"
pprint "SUID files"             "$(find / -perm -4000 -type f 2> /dev/null)"
pprint "SUID owned by root"     "$(find / -uid 0 -perm -4000 -type f 2> /dev/null)"
pprint "GUID files"             "$(find / -perm -2000 -type f 2> /dev/null)"
pprint "World writable files"   "$(find / ! -path "*/proc/*" -perm -2 -type f 2> /dev/null)"
pprint "World writeable directories" \
                                "$(find / -perm -2 -type d 2>/dev/null)"
pprint "/root"                  "$(ls -ahlR /root 2>/dev/null ||  error $?)"
pprint "root mail"              "$(head /var/mail/root 2> /dev/null || error $?)"
pprint "SSH files"              "$(find / -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" \
                                    2> /dev/null | while read filename; do ls -l $filename && base64 $filename && echo; done)"
pprint "Suspected credentials in logs" \
                                    "$(grep -lE 'pass|crede|creds' /var/log/*.log 2> /dev/null || error $?)"
pprint "Logs"                   "$(find /var/log -type f -exec ls -la {} \; 2> /dev/null)"
pprint "Open files"             "$(lsof -i -n 2> /dev/null || error $?)"
pprint "Processes running as root" \
                                "$(ps auxw | grep root)"
pprint "Exports and NFS permissions" \
                                "$(cat /etc/exports 2>/dev/null || error $?)"
pprint "Cron jobs"              "$(ls -laR /etc/cron*)"
pprint "Open connections"       "$(lsof -i || sockstat || netstat -na || error $?)"
pprint "Installed packages"     "$(dpkg -l || rpm -qa || pkg info || error $?)"
