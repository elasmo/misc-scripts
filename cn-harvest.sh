#!/usr/bin/env bash

# Expects a CSV style file where the first field is 
# the host or IP address and the second field is the 
# port. A Metasploit export (i.e. services -o /tmp/) 
# will do fine.
#
services="/file/path"

get_field() {
    echo $1 | cut -f $2 -d',' | tr -d '"'
}

while read i; do
    ip="$(get_field $i 1)"
    port="$(get_field $i 2)"

    if [ "$(echo $port | grep -E '80|445|135|139|21|22|port')" ]; then
        continue
    fi

    cn="$(timeout 2 openssl s_client -connect $ip:$port < /dev/null 2> /dev/null | openssl x509 -noout -subject -in - 2> /dev/null | grep -oP "CN = \K([a-zA-Z0-9\*\._-]+)")"
    echo "$ip,$port,$cn"
done < $services
