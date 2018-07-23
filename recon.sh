#!/bin/sh
#
# Recon script
#

pprint() {
    pprint "$1"
    printf "\033[38;5;155m===> $1\033[0m\n"
    echo "$2"
    echo
}

pprint "Systems running"     "$(uname -a)"
pprint "Distribution"        "$(cat /etc/*-release || cat /etc/issue || echo 'N/A')"
pprint "Filesystems"         "$(df -a)"
pprint "Network interfaces"  "$(ip a || ifconfig)"
pprint "Routing table"       "$(ip r || netstat -rn)"
pprint "DNS server(s)"       "$(cat /etc/resolv.conf || dig example.com | grep SERVER || host -a example.com | grep from)"
pprint "Users"               "$(cat /etc/passwd | grep -v ^#)"
pprint "Grousp"              "$(cat /etc/group | grep -v ^#)"
pprint "Admin accounts"      "$(grep -v -E '^#' /etc/passwd | awk -F: '$3 == 0 { print $1}' || echo 'N/A')"
pprint "Logged in"           "$(finger || w || who -a || pinky || users)"
pprint "Last logged in"      "$(last || lastlog)"
pprint "Sudo permissions"    "$(sudo -ln 2> /dev/null|| echo "None")"
pprint "Command history for $(whoami)" \
                            "$(cat ~/.bash_history || cat ~/.history)"
pprint "Environment"         "$(env)"
pprint "Shells"              "$(cat /etc/shells | grep -v ^#)"
pprint "SUID files"          "$(find / -perm -4000 -type f 2> /dev/null)"
pprint "SUID owned by root"  "$(find / -uid 0 -perm -4000 -type f 2> /dev/null)"
pprint "GUID files"          "$(find / -perm -2000 -type f 2> /dev/null)"
pprint "World writable"      "$(find / -perm -2 -type f 2> /dev/null)"
pprint "World writable/executable" \
                             "$(find / ! -path "*/proc/*" -perm -2 -type f -print 2> /dev/null)"
pprint "World writeable directories" \
                             "$(find / -perm -2 -type d 2>/dev/null)"
pprint "/root"               "$(ls -ahlR /root 2>/dev/null || echo "N/A")"
pprint "SSH files"           "$(find / -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" \ 
                                -o -name "authorized_keys" 2>/dev/null |xargs -r ls -la)"
pprint "Inetd"               "$(ls -la /usr/sbin/in* || echo 'N/A')"
pprint "Suspected credentials in logs"       "$(grep -lE 'pass|crede|creds' /var/log/*.log 2> /dev/null || echo 'N/A')"
pprint "Logs"                "$(find /var/log -type f -exec ls -la {} \; 2> /dev/null)"
pprint "Open files"          "$(lsof -i -n 2> /dev/null || echo 'N/A')"
pprint "root mail"           "$(head /var/mail/root 2> /dev/null || echo 'N/A')"
pprint "Processes running as root" \
                             "$(ps auxw | grep root)"
pprint "Exports and NFS permissions" \
                             "$(cat /etc/exports 2>/dev/null || echo 'N/A')"
pprint "Cron jobs"           "$(ls -laR /etc/cron*)"
pprint "Open connections"    "$(lsof -i || sockstat -4 || echo 'N/A')"
pprint "Installed packages"  "$(dpkg -l || rpm -qa || pkg info)"
