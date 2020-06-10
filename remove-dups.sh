#!/bin/sh
# Script to help removing duplicate files
# 
# Use `sh remove-dups.sh list` to list all duplicates without doing anything.
# Expects a file with FreeBSD cksum(1) output (CRC OCTETS FILENAME). Examples:
# remove-dups.sh -f directory/
# find path/ -type f exec cksum {} \; >> list.cksum
# remove-dups.sh -f list.cksum
# remove-dups.sh -l -f list.cksum
#
# TODO
#	option to delete all files with named checksum
#	output as csv
#set -x

usage() {
    printf "Usage: %s [-l] [-d dir] [-f] file|dir\n" "$(basename $0)"
    exit 2
}

crc_old=0
name_old=""
fflag=0
lflag=0
args=`getopt lf: $*` || usage
set -- $args
while :; do
    case "$1" in
        -l) lflag=1; shift ;; 
        -f) fflag=1; file="$2"; shift; shift ;;
        --) shift; break ;;
    esac
done

# File must be specified
[ $fflag -ne 1 ] && usage

if [ -d "$file" ]; then
    # Checksum and sort if file is directory
    chklist=$(find "$file" -type f -exec cksum {} \;)
    IFS=$'\n' sorted=$(echo "$chklist" | sort -n -k 1)
elif [ -r "$file" ]; then
    # Sort if file is regular file
    sorted=$(sort -n -k 1 "$file")
else
    echo "Unable to read $file"
    exit 1
fi

for i in $sorted; do
    echo $i
    echo
done
exit

rm_this=""
echo -n $sorted | while read i; do
    crc=$(echo "$i" | cut -f1 -d' ')
    name=$(echo "$i" | cut -f3- -d' ')
    echo "Working on $i"

    c=0
    for rm_crc in $rm_this; do
        echo "-$rm_crc-"
        if [ $rm_crc -eq $crc ]; then
            echo rm -v "$name"
            c=1
        fi
    done
    [ $c -eq 1 ] && continue

    if [ $crc -eq $crc_old ]; then
        echo "[*] Found duplicate"
        echo "[1] $crc $name"
        echo "[2] $crc_old $name_old"

        # Don't ask for user interaction if '-l' is specified
        [ $lflag -eq 1 ] && continue

        echo -n "[*] Remove (1/2/[B]oth/[A]ll)? "
        read user_input 0</dev/tty # haxx
        case $user_input in
            1) echo rm -vi "$name" ;;
            2) echo rm -vi "$name_old" ;;
            B) echo rm -vi "$name" "$name_old" ;;
            A) rm_this="$crc " ;;
            *) echo "[*] Skipping" ;;
        esac
        echo
    fi

    crc_old=$crc
    name_old="$name"
done 
