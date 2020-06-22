#!/bin/sh
#
# Generate URL safe random tokens
#
_bytes=32
[ $# -eq 1 ] && _bytes=$1 || _bytes=32
dd if=/dev/urandom bs=$_bytes count=1 2>/dev/null | base64 -w 0 | tr '+/' '-_' | tr -d  '='
echo
