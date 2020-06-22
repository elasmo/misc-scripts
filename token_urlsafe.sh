#!/bin/sh
#
# Generate URL safe random tokens
#
[ $# -eq 1 ] && _bytes=$1 || _bytes=32
#dd if=/dev/urandom bs=$_bytes count=1 2>/dev/null | base64 | tr '+/' '-_' | tr -d  '='
openssl rand -base64 $_bytes | tr '+/' '-_' | tr -d '='
