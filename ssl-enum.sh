#!/usr/bin/env bash
#
# Enumerates supported cipher suites
#
server=$1
port=$2
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

[ "$#" -gt 0 ] || { echo >&2 "Usage: $0 <server> [port]"; exit 1; }
[ -n "$2" ] || port=443

for cipher in ${ciphers}; do
    resp=$(echo -n | openssl s_client -cipher "${cipher}" -connect ${server}:${port} 2>&1)
    if [[ ! "${resp}" =~ ":error:" ]] ; then
        if [[ "${resp}" =~ "Cipher is ${cipher}" || "${resp}" =~ "Cipher    :" ]] ; then
            echo ${cipher}
        fi
    fi
done
