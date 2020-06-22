#!/usr/bin/env bash
if [ "$(pgrep ^spice-vdagent$)" == "" ]; then
    spice-vdagent
fi

snapshot() {
    virsh snapshot-create-as --domain "$1" --name "snapshot-$(date +%s)"
}

urlencode() {
    echo -n $1 | xxd -plain | sed 's/\(..\)/%\1/g'
}

urldecode() {
    url="0:$(echo -n "$@" | sed 's/%/ /g')"
    echo $url | xxd -r
}
