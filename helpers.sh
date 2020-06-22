#!/usr/bin/env bash
if [ "$(pgrep ^spice-vdagent$)" == "" ]; then
    spice-vdagent
fi

snapshot() {
    virsh snapshot-create-as --domain "$1" --name "snapshot-$(date +%s)"
}
