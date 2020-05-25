#!/bin/sh
#
# Fetches debian iso, verifies sha512 hash and signature
#
#base="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd"

error() {
    echo >&2 "$@"
    exit 1
}

if [ $# != 1 ]; then
    error "Usage: $(basename $0) <url>"
fi

iso_url="$1"
base_url="${iso_url%/*}"
iso_file="${iso_url##*/}"
key_id="6294BE9B"
TMP_SHA512=$(mktemp)
TMP_SIG=$(mktemp)

which curl > /dev/null || error "curl not found" 
which openssl > /dev/null || error "openssl not found"
which dirmngr > /dev/null || error "dirmngr not found"
gpg_runtime=$(which gpg 2> /dev/null || which gpgv2 2> /dev/null) || error "gpg not found"

# Download ISO
if [ ! -f ./${iso_file} ]; then
    echo "Requesting ${iso_url}..."
    curl -fsLO "${iso_url}" && echo "OK" || error "Error retrieving ${iso_url}"
else 
    echo "Found $PWD/${iso_file}"
fi

# Verify SHA512 hash
curl -fsO "${base_url}/SHA512SUMS" -o $TMP_SHA512 || error "fetch failed"
sha512 -C SHA512SUMS "${iso_file}" || error "hash mismatch"

# Verify signature
${gpg_runtime} --keyserver keyring.debian.org --recv ${key_id}
curl -O "${base_url}/SHA512SUMS.sign" -o $TMP_SIG || error "fetch signature failed"
${gpg_runtime} --verify $TMP_SIG $TMP_SHA512 2> /dev/null && echo "OK" || error "verification failed"
