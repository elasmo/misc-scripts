#!/usr/bin/env bash
#
# Enumerates supported cipher suites
#
server=$1
port=$2
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

error() {
    echo >&2 "$@"
    exit 1
}

[ "$#" -gt 0 ] || error "Usage: $0 <server> [port]"
[ -n "$2" ] || port=443

for cipher in ${ciphers[@]}; do
    resp=$(echo -n | openssl s_client -cipher "${cipher}" -connect ${server}:${port} 2>&1)
    if [[ ! "${resp}" =~ ":error:" ]] ; then
        if [[ "${resp}" =~ "Cipher is ${cipher}" || "${resp}" =~ "Cipher    :" ]] ; then
            echo ${cipher}
        fi
    fi
done
