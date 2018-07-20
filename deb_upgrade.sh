#!/usr/bin/env bash
set -euo pipefail
trap close_ports EXIT

if [ $(whoami) != "root" ]; then
    error "$(whoami) are not welcome here!"
fi

ports="443 80"
hosts=(
    "ftp.se.debian.org"
    "security.debian.org" 
    "gemmei.ftp.acc.umu.se"
    "caesar.ftp.acc.umu.se"
    "saimei.ftp.acc.umu.se"
    "security-cdn.debian.org"
    "gensho.ftp.acc.umu.se"
)

error() {
    printf >&2 "\e[38;5;155m===>\e[0m\e[0;31m $@\e[0m\n"
    exit 1
}

pprint() {
    printf "\e[38;5;155m===>\e[0m $@\n"
}

close_ports() {
    for port in ${ports}; do 
        for host in ${hosts[@]}; do
            pprint "Closing ${host}:${port}"
            iptables -D INPUT -i eth0 -m state -p tcp -s ${host} --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
            iptables -D OUTPUT -o eth0 -p tcp -d ${host} --dport ${port} -j ACCEPT
        done
    done
}

for port in ${ports}; do
    for host in ${hosts[@]}; do
        pprint "Opening ${host}:${port}"
        iptables -A INPUT -i eth0 -m state -p tcp -s ${host} --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A OUTPUT -o eth0 -p tcp -d ${host} --dport ${port} -j ACCEPT
    done
done

pprint "Updating local repository"
apt -y update || error "update failed"

pprint "Performing dist upgrade"
apt -y dist-upgrade || error "dist-upgrade failed"

pprint "Cleaning up"
apt autoremove || error "autoremove failed"
apt clean || error "clean failed"
