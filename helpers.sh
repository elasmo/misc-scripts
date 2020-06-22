#!/usr/bin/env bash
#
# Various helpers
# ...preferably sourced from ~/.bashrc
#

alias vlr="virsh list --state-running --title | tail -n +3 | head -n -1 | awk '{print \$2}'"
alias vl="virsh list --all --title | tail -n +2 | awk '{print \$2,\$3}' | sort -k1 | sed 's/shut/off/g' | sed 's/running/on/g' | column -t"
alias calc="python3 -ic 'from math import *'"

if [ "$(pgrep ^spice-vdagent$)" == "" ]; then
    spice-vdagent
fi

snapshot() {
    virsh snapshot-create-as --domain "${1}" --name "snapshot-$(date +%s)"
}

vmclone() {
    source="${1}"
    dest="${2}"
    diskimage="/var/lib/libvirt/images/${dest}.img"

    if [ -f "${diskimage}" ]; then
        echo "${diskimage} already exist."
        return $?
    fi

    virt-clone -o ${source} -n ${dest} -f ${diskimage}
}

urlencode() {
    echo -n $1 | xxd -plain | sed 's/\(..\)/%\1/g'
}

urldecode() {
    url="0:$(echo -n "$@" | sed 's/%/ /g')"
    echo $url | xxd -r
}

token_urlsafe() {                                                                                                                                                                              
    local nbytes=32
    if [ "$1" != "" ]; then
        nbytes=$1
    fi
    echo "$(dd if=/dev/urandom bs=${nbytes} count=1 2> /dev/null | base64 -w0 | tr '+/' '-_' | tr -d  '=')"
}
