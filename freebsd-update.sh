#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "$0: must be run as root."
    exit 1
fi

jail_root="/jail"
jails="jail1 jail2 jail3 jail4"
local_machine="$(hostname -s)"

pprint() {
    printf "\e[0;35m===>\e[0m $@\n"
}

pprint "Updating local repository on ${local_machine}"
pkg update 

pprint "Upgrading packages on ${local_machine}"
pkg upgrade

pprint "Removing stale packages on ${local_machine}"
pkg autoremove -y

pprint "Removing package cache on ${local_machine}"
pkg clean -ay

pprint "Installing base and kernel updates on ${local_machine}"
PAGER=cat freebsd-update --not-running-from-cron fetch install

for jail in ${jails}; do
    pprint "Updating local repository on ${jail}"
    pkg -j ${jail} update

    pprint "Upgrading packages on ${jail}"
    pkg -j ${jail} upgrade

    pprint "Removing stale packages on ${jail}"
    pkg -j ${jail} autoremove -y

    pprint "Removing package cache on ${jail}"
    pkg -j ${jail} clean -ay

    pprint "Installing base and kernel updates on ${jail}"
    PAGER=cat freebsd-update -b "${jail_root}/${jail}" --not-running-from-cron fetch install
done

pprint "Note:"
echo "- ${jail_root}/base is not included in this upgrade"
echo "- if any kernel updates has been included, the kernel needs to be rebuilt using"
echo "  the custom confiugration:"
echo "  cd /usr/src && make buildkernel KERNCONF=CUSTOM && make installkernel KERNCONF=CUSTOM"
