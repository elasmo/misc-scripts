#!/bin/sh
#
# Simple helper to add burp certificate to Androids system trust store
#
set -e
truststore="/system/etc/security/cacerts/"
truststore_copy="/data/local/tmp/certs.bak"
tmp="/data/local/tmp"

curl -s -O localhost:8080/cert
burp_cert=$(openssl x509 -inform der -subject_hash -in cert | head  -1).0
openssl x509 -inform der -in cert -out ${burp_cert}

adb shell su -c mkdir -p ${truststore_copy}
adb shell su -c cp ${truststore}/* ${truststore_copy}
adb shell su -c mount -t tmpfs tmpfs ${truststore}
adb shell su -c mv ${truststore_copy}/* ${truststore}
adb push ${burp_cert} ${tmp}
adb shell su -c mv ${tmp}/${burp_cert} ${truststore}
adb shell su -c chown root:root ${truststore}/*
adb shell su -c chmod 644 ${truststore}/*
adb shell su -c chcon u:object_r:system_file:s0 ${truststore}/*

rm cert ${burp_cert}
