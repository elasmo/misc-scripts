#!/bin/sh
#
# Fetches debian iso, verifies sha512 hash and signature
#
# Dependencies: dirmngr, gpg, curl, openssl
#

base="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd"

iso_file="debian-9.4.0-amd64-netinst.iso"
sha_file="SHA512SUMS"
sig_file="${sha_file}.sign"

iso_url="${base}/${iso_file}"
sha_url="${base}/SHA512SUMS"
sig_url="${base}/SHA512SUMS.sign"

if [ ! -f ${iso_file} ]; then
    echo -n "=== Fetching ${iso_url}..."
    curl -sLO "${iso_url}" && echo "OK" || { echo >&2 "failed"; exit 1; }
fi

echo -n "=== Verifying hash..."
curl -sO "${sha_url}" || { echo >&2 "fetch failed"; exit 1; }
expected_hash=$(grep -E "^[0-9a-f]{128}\s{2}${iso_file}$" ${sha_file} | awk '{print $1}' || { echo >&2 "failed"; exit 1; })
iso_hash=$(openssl sha512 "${iso_file}" | cut -f2 -d' ')
[ "${iso_hash}" = "${expected_hash}" ] && echo "OK" || { echo >&2 "failed"; exit 1; }

echo -n "=== Verifying signature..."
gpg --keyserver keyring.debian.org --recv 6294BE9B 2> /dev/null || { echo >&2 "fetch key failed"; exit 1; }
curl -sO "${sig_url}" || { echo >&2 "fetch signature failed"; exit 1; }
gpg --verify ${sig_file} ${sha_file} 2> /dev/null && echo "OK" || { echo >&2 "verification failed"; exit 1; }
