#!/usr/bin/env bash
set -euo pipefail

error() {
    echo >&2 "$@"
    exit 1
}

if [ $(whoami) != "root" ]; then
    error "$(whoami) are not welcome here!"
fi

trap close_ports EXIT
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

close_ports() {
    for port in ${ports}; do 
        for host in ${hosts[@]}; do
            echo "==> Closing ${host}:${port}"
            iptables -D INPUT -i eth0 -m state -p tcp -s ${host} --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
            iptables -D OUTPUT -o eth0 -p tcp -d ${host} --dport ${port} -j ACCEPT
        done
    done
}

for port in ${ports}; do
    for host in ${hosts[@]}; do
        echo "==> Opening ${host}:${port}"
        iptables -A INPUT -i eth0 -m state -p tcp -s ${host} --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A OUTPUT -o eth0 -p tcp -d ${host} --dport ${port} -j ACCEPT
    done
done

echo "==> Updating local repository"
apt -y update || error "update failed"

echo "==> Performing dist upgrade"
apt -y dist-upgrade || error "dist-upgrade failed"

echo "==> Cleaning up"
apt autoremove || error "autoremove failed"
apt clean || error "clean failed"
