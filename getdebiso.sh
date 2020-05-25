#!/bin/sh
#
# Fetches debian iso, verifies sha512 hash and signature
#

cleanup() {
    rm -f $TMP_SIG $TMP_SHA
}

error() {
    echo >&2 "$@"
    cleanup
    exit 1
}

[ $# != 1 ] && error "Usage: $(basename $0) <url>"

get_url() {
    [ -s $2 ] && return
    echo "Requesting $1"
    curl -fsL $1 -o $2
}

trap cleanup EXIT 

iso_url="$1"
base_url="${iso_url%/*}"
iso_file="${iso_url##*/}"
sha_url="${base_url}/SHA512SUMS"
sig_url="${base_url}/SHA512SUMS.sign"
TMP_SHA=$(mktemp)
TMP_SIG=$(mktemp)
key_id="6294BE9B"

# Check dependencies
for dep in curl openssl dirmngr; do
    type $dep > /dev/null || error "$dep not found"
done
type gpg > /dev/null || type gpg2 > /dev/null || error "gpg not found"
   
# Download ISO
get_url $iso_url $iso_file

# Verify SHA512 hash
get_url "$sha_url" $TMP_SHA
sha512 -C $TMP_SHA "$iso_file" || error "Hash mismatch"

# Verify signature
get_url "$sig_url" $TMP_SIG

case "$(uname -s)" in
    "OpenBSD") 
        gpg2 --search-keys $key_id || error "Error retrieving $key_id"
        echo $TMP_SIG $iso_file
        gpg2 --verify $TMP_SIG $TMP_SHA || error "Verification failed";;
    "Linux") 
        gpg --keyserver --recv $key_id || error "Error retrieving $key_id"
        gpg --verify $TMP_SIG $TMP_SHA
        ;;
esac
