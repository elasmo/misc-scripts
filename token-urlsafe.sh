#!/usr/bin/env bash
nbytes=32 && [ "$1" == "" ] || nbytes=$1
echo -n "$(head -c ${nbytes} /dev/urandom | base64 -w0 | tr '+/' '-_' | tr -d  '=')"
