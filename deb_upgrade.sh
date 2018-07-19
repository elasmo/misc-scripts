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

close_ports() {
    for port in ${ports}; do
        echo "==> Closing ${port}"
        iptables -D INPUT -i eth0 -m state -p tcp --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
        iptables -D OUTPUT -o eth0 -p tcp --dport ${port} -j ACCEPT
    done
}

for port in ${ports}; do
    echo "==> Opening ${port}"
    iptables -A INPUT -i eth0 -m state -p tcp --sport ${port} --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -o eth0 -p tcp --dport ${port} -j ACCEPT
done

echo "==> Updating local repository"
apt -y update || error "update failed"                                                                                                                                                         

echo "==> Performing dist upgrade"
apt -y dist-upgrade || error "dist-upgrade failed"
