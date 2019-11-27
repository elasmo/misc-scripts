#!/usr/bin/env bash
#
# Various helpers
# ...preferably sourced from ~/.bashrc
#

alias vlr="virsh list --state-running --title | tail -n +3 | head -n -1 | awk '{print \$2}'"
alias vl="virsh list --all --title | tail -n +2 | awk '{print \$2,\$3}' | sort -k1 | sed 's/shut/off/g' | sed 's/running/on/g' | column -t"

if [ "$(pgrep ^spice-vdagent$)" == "" ]; then
    spice-vdagent
fi

snapshot() {
    virsh snapshot-create-as --domain "${1}" --name "snapshot-$(date +%s)"
}

spiceme() {
    running="$(virsh list --inactive | awk '{print $2}' | grep ^${1}$)"

    # Always revert to known-good state if name is set to guest
    if [ "${1}" == "guest" ]; then
        virsh snapshot-revert guest --current
    fi

    if [ "${running}" != "" ]; then
        virsh start ${1}
    elif [ ! "$(virsh dominfo ${1} 2> /dev/null)" ]; then
        printf "Domain '${1}' not found.\n\n"
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

urldecode() {
    url="0:$(echo -n "$@" | sed 's/%/ /g')"
    echo $url | xxd -r
}
