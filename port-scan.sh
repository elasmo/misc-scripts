#!/usr/bin/env bash
#
# Simple one-liner portscan

while read port; do </dev/tcp/127.0.0.1/${port} && echo ${port}; done < <(grep -oE [0-9]+/tcp /etc/services | tr -d '/tcp')
