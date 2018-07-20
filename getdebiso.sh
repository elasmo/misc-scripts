#!/bin/sh
#
# Fetches debian iso, verifies sha512 hash and signature
#

base="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd"

iso_file="debian-9.4.0-amd64-netinst.iso"
sha_file="SHA512SUMS"
sig_file="${sha_file}.sign"

iso_url="${base}/${iso_file}"
sha_url="${base}/SHA512SUMS"
sig_url="${base}/SHA512SUMS.sign"

error() {
    echo >&2 "$@"
    exit 1
}

which curl > /dev/null || error "curl not found" 
which gpg > /dev/null || error "gpg not found"
which openssl > /dev/null || error "openssl not found"
which dirmngr > /dev/null || error "dirmngr not found"

if [ ! -f ${iso_file} ]; then
    echo -n "=== Fetching ${iso_url}..."
    curl -sLO "${iso_url}" && echo "OK" || error "failed"
else 
    echo "=== Found ${iso_file}"
fi

echo -n "=== Verifying hash..."
curl -sO "${sha_url}" || error "fetch failed"
expected_hash=$(grep -E "^[0-9a-f]{128}\s{2}${iso_file}$" ${sha_file} | awk '{print $1}' || error "failed")
iso_hash=$(openssl sha512 "${iso_file}" | cut -f2 -d' ')
[ "${iso_hash}" = "${expected_hash}" ] && echo "OK" || error "hash mismatch"

echo -n "=== Verifying signature..."
gpg --keyserver keyring.debian.org --recv 6294BE9B 2> /dev/null || error "fetch key failed"
curl -sO "${sig_url}" || error "fetch signature failed"
gpg --verify ${sig_file} ${sha_file} 2> /dev/null && echo "OK" || error "verification failed"
