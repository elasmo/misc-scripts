#!/usr/bin/env bash
#
# Various helpers
#

alias vl='virsh list --all'

if [ "$(pgrep ^spice-vdagent$)" == "" ]; then
    spice-vdagent
fi

spiceme() {
    running="$(virsh list --inactive | awk '{print $2}' | grep ^${1}$)"

    if [ "${running}" != "" ]; then
        virsh start ${1}
    elif [ ! "$(virsh dominfo ${1} 2> /dev/null)" ]; then
        echo "Domain '${1}' not found."
        echo
        virsh list --all
        return $?
    fi

    spicy -f --uri="$(virsh domdisplay $1)"
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
