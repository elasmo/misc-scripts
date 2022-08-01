#!/bin/sh
#
# Simple helper to add burp certificate to Androids system trust store
#
set -e
system_store="/system/etc/security/cacerts/"
cert_backup="/data/local/tmp/certs.bak"
tmp="/data/local/tmp"

curl -s -O localhost:8080/cert
new_filename=$(openssl x509 -inform der -subject_hash -in cert | head  -1).0
openssl x509 -inform der -in cert -out ${new_filename}

adb shell su -c mkdir -p ${cert_backup}
adb shell su -c cp ${system_store}/* ${cert_backup}
adb shell su -c mount -t tmpfs tmpfs ${system_store}
adb shell su -c mv ${cert_backup}/* ${system_store}
adb push ${new_filename} ${tmp}
adb shell su -c mv ${tmp}/${new_filename} ${system_store}
adb shell su -c chown root:root ${system_store}/*
adb shell su -c chmod 644 ${system_store}/*
adb shell su -c chcon u:object_r:system_file:s0 ${system_store}/*

rm cert ${new_filename}
