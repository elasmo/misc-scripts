#!/usr/bin/env bash
set -euo pipefail

error() {
    printf >&2 "\e[38;5;155m===>\e[0m\e[0;31m $@\e[0m\n"
    exit 1
}

if [ $(id -u) -ne 0 ]; then
    error "$(whoami) are not welcome here!"
fi

apt_options="--no-install-recommends -qq --yes"
ports="443,80"
net_if=$(ip -4 route list 0/0 | cut -f5 -d' ')

# Note: add these to /etc/hosts
repositories=(
    "ftp.se.debian.org"
    "security.debian.org" 
    "gemmei.ftp.acc.umu.se"
    "caesar.ftp.acc.umu.se"
    "saimei.ftp.acc.umu.se"
    "security-cdn.debian.org"
    "gensho.ftp.acc.umu.se"
)

pprint() {
    printf "\e[38;5;155m===>\e[0m $@\n"
}

close_ports() {
    pprint "Closing ports"
    for repo in ${repositories[@]}; do
        iptables -D OUTPUT -o ${net_if} -p tcp -d ${repo} -m multiport --dports ${ports} -j ACCEPT
        iptables -D INPUT -i ${net_if} -m state -p tcp -s ${repo} -m multiport --sports ${ports} --state ESTABLISHED,RELATED -j ACCEPT
    done
}

trap close_ports EXIT

pprint "Opening ports"
for repo in ${repositories[@]}; do
    iptables -A OUTPUT -o ${net_if} -p tcp -d ${repo} -m multiport --dports ${ports} -j ACCEPT
    iptables -A INPUT -i ${net_if} -m state -p tcp -s ${repo} -m multiport --sports ${ports} --state ESTABLISHED,RELATED -j ACCEPT
done

pprint "Updating local repo"
apt-get ${apt_options} update || error "update failed"

pprint "Performing upgrade"
apt-get ${apt_options} dist-upgrade || error "dist-upgrade failed"

pprint "Cleaning up"
apt-get ${apt_options} autoremove || error "autoremove failed"
apt-get ${apt_options} clean || error "clean failed"
