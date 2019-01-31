#!/usr/bin/env bash
#
# Create a LUKS encrypted volume and attach it to a virsh managed guest
#
# Usage examples:
# host$ attach-luks myvm 5G
# myvm$ sudo cryptsetup luksOpen /dev/vde cryptvol
# myvm$ sudo mount /dev/mapper/cryptvol /mnt
# 
# If the size argument is omitted, 10G is used by default
#
set -e

error() {
    printf >&2 "\e[38;5;155m===>\e[0m\e[0;31m $@\e[0m\n"
    if [ ! -z ${crypt_vol+x} ]; then
        if [ -f "${crypt_vol}" ]; then
            pprint "Cleaning up\n"
            rm -f "${crypt_vol}"
        fi
    fi
    exit 1
}

usage() {
    echo "Usage: $(basename $0) <vm_name> [<size>]"
    exit 1
}

pprint() {
    printf "\e[38;5;155m===>\e[0m $@"
}


[ $# -eq 0 ] && usage


size="10G"
vm_name="$1"
vol_root="${HOME}/.cryptovols"
crypt_vol="${vol_root}/${vm_name}_$(uuidgen)"
password=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 64)

trap 'error "Exiting"' EXIT 


# Check if vm guest is existent 
if [ ! "$(virsh dominfo $1 2> /dev/null)" ]; then 
    error "virsh domain $1 not found"
fi

# Set default size 10G if size is not specified
if [ $# -eq 2 ]; then
    size="$2"
fi

# Create image directory if not found
if [ ! -d "${vol_root}" ]; then
    pprint "Creating ${vol_root}\n"
    mkdir ${vol_root}
fi


pprint "Creating ${size} crypto volume ${crypt_vol}\n"
truncate -s ${size} "${crypt_vol}"
echo ${password} | sudo cryptsetup --hash sha512 --batch-mode luksFormat ${crypt_vol}

pprint "Password: ${password}\n"

pprint "Attaching ${crypt_vol} to ${vm_name}\n"
virsh attach-disk --config ${vm_name} ${crypt_vol} vde --cache none > /dev/null
