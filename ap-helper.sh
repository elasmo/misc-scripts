#!/bin/sh
#
# Setup Wifi Access Point to intercept traffic from wireless
# devices. It doesn't respect any current configuration.
#
set -e
PATH="/usr/sbin:/usr/bin"
ap_if="wlan0"
ext_if="eth0"
net_prefix="192.0.2"
ap_ssid="ap-$(head -c 4 < /dev/urandom | xxd -p)"
ap_psk="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 10)"
ap_conf="/etc/wpa_supplicant/wpa_supplicant-${ap_if}.conf"

# Networking
sysctl net.ipv4.ip_forward=1
ip address flush dev ${ap_if}
ip address add ${net_prefix}.1/24 dev ${ap_if}
ip link set ${ap_if} up

# nftables
nft flush ruleset
nft add table ip filter
nft add chain ip filter prerouting { type nat hook prerouting priority 0\; policy accept\; }
nft add chain ip filter postrouting { type nat hook postrouting priority 100\; policy accept\; }
nft add chain ip filter inbound { type filter hook input priority 0\; policy drop\; }
nft add chain ip filter outbound { type filter hook output priority 0\; policy drop\; }
nft add rule ip filter prerouting iifname ${ap_if} tcp dport { http, https } redirect to \:8080
nft add rule ip filter postrouting oifname ${ext_if} masquerade
nft add rule ip filter inbound iif lo accept
nft add rule ip filter inbound iifname ${ap_if} accept
nft add rule ip filter inbound ct state established accept
nft add rule ip filter inbound log prefix \"input drop: \"
nft add rule ip filter outbound oif lo accept
nft add rule ip filter outbound oifname ${ext_if} accept
nft add rule ip filter outbound oifname ${ap_if} udp sport bootps udp dport bootpc accept
nft add rule ip filter outbound oifname ${ap_if} ct state established accept
nft add rule ip filter outbound log prefix \"output drop: \"
nft add table ip6 filter
nft add chain ip6 filter inbound { type filter hook input priority 0\; policy drop\; }
nft add chain ip6 filter outbound { type filter hook output priority 0\; policy drop\; }
nft add rule ip6 filter inbound iif lo ct state established accept
nft add rule ip6 filter outbound oif lo accept

# DHCP/DNS
cat << EOF > /etc/dnsmasq.conf
interface=${ap_if}
bind-dynamic
dhcp-range=${ap_if},${net_prefix}.2,${net_prefix}.254,12h
log-dhcp
log-queries
EOF
systemctl restart dnsmasq

# Wifi access point
umask 077
cat << EOF > ${ap_conf}
network={
  ssid="${ap_ssid}"
  mode=2
  key_mgmt=WPA-PSK
  psk="${ap_psk}"
  frequency=2437
}
EOF
wpa_supplicant -i ${ap_if} -c ${ap_conf} -B

if type qrencode >/dev/null 2>&1; then
    qrencode -o - -t UTF8 "WIFI:S:${ap_ssid};T:WPA;P:${ap_psk};;"
fi
echo "Created AP: ${ap_ssid}:${ap_psk}"
