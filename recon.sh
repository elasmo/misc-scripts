#!/bin/sh
#
# Recon script
#
# Largerly based on:
# https://github.com/foobarto/redteam-notebook
#

homedir="/home"
if [ "$(uname -s)" = "FreeBSD" ]; then
    homedir="/usr/home"
fi

pprint() {
    printf "\e[38;5;155m===> $@\e[0m\n"
}

recon() {
    pprint "$1"
    echo "$2"
    echo
}


recon "Systems running"     "$(uname -a)"
recon "Distribution"        "$(cat /etc/*-release || cat /etc/issue || echo 'N/A')"
recon "Filesystems"         "$(df -a)"
recon "Network interfaces"  "$(ip a || ifconfig)"
recon "Routing table"       "$(ip r || netstat -rn -f inet)"
recon "DNS server"          "$(cat /etc/resolv.conf || dig example.com | grep SERVER || host -a example.com | grep from)"
recon "Users"               "$(cat /etc/passwd)"
recon "Grousp"              "$(cat /etc/group)"
recon "Admin accounts"      "$(grep -v -E '^#' /etc/passwd | awk -F: '$3 == 0 { print $1}' || echo 'N/A')"
recon "Logged in"           "$(finger || w || who -a || pinky || users)"
recon "Last logged in"      "$(last || lastlog)"
recon "Sudo permissions"    "$(surecon -ln 2> /dev/null|| echo "None")"
recon "Command history"     "$(cat ~/.bash_history || cat ~/.history)"
recon "Environment"         "$(env)"
recon "Shells"              "$(cat /etc/shells)"
recon "SUID files"          "$(find / -perm -4000 -type f 2> /dev/null)"
recon "SUID owned by root"  "$(find / -uid 0 -perm -4000 -type f 2> /dev/null)"
recon "GUID files"          "$(find / -perm -2000 -type f 2> /dev/null)"
recon "Word writable"       "$(find / -perm -2 -type f 2> /dev/null)"
recon "Word writable/executable" \
                            "$(find / ! -path "*/proc/*" -perm -2 -type f -print 2> /dev/null)"
recon "World writeable directories" \
                            "$(find / -perm -2 -type d 2>/dev/null)"
#recon "Plan files"          "$(find ${homedir} -iname *.plan -exec ls -la {} ; -exec cat {} 2>/dev/null)"
recon "/root"               "$(ls -ahlR /root 2>/dev/null || echo "N/A")"
recon "SSH files"           "$(find / -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" 2>/dev/null |xargs -r ls -la)"
recon "Inetd"               "$(ls -la /usr/sbin/in* || echo 'N/A')"
recon "Creds in logs"       "$(grep -lE 'pass|crede|creds' /var/log/*.log 2> /dev/null || echo 'N/A')"
recon "Logs"                "$(find /var/log -type f -exec ls -la {} \; 2> /dev/null)"
recon "Open files"          "$(lsof -i -n 2> /dev/null || echo 'N/A')"
recon "root mail"           "$(head /var/mail/root || echo 'N/A')"
recon "Processes run as root" \
                            "$(ps auxw | grep root)"
recon "Exports and NFS permissions" \
                            "$(ls -la /etc/exports 2>/dev/null; cat /etc/exports 2>/dev/null || echo 'N/A')"
recon "Cron jobs"           "$(ls -laR /etc/cron*)"
recon "Open connections"    "$(lsof -i || sockstat -4 || echo 'N/A')"
recon "Installed packages"  "$(dpkg -l || rpm -qa || pkg info)"
