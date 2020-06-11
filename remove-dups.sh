#!/bin/sh
#
# File duplicate removal helper
# 
# Calculates checksums using cksum(1) on files located in a directory or
# takes previously generated file, roughly in the format "CRC LEN FILENAME\n"
# The '-l' flag lists duplicates and don't prompt for user interaction.

# Examples
# remove-dups.sh -f directory/
# remove-dups.sh -f cksum.out
# remove-dups.sh -f cksum.out -l
#
usage() {
    printf "Usage: %s [-l] -f <file | dir>\n" "`basename $0`"
    exit 2
}

crc_old=0
name_old=""
opt_rm=""
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
    chklist=`find "$file" -type f -exec cksum "{}" \;`
    sorted=`echo "$chklist" | sort -n -k 1`
elif [ -r "$file" ]; then
    # Sort if file is regular file
    sorted=`sort -n -k 1 "$file"`
else
    echo "Unable to read $file"
    exit 1
fi

# Main loop
echo "$sorted" | while read line; do
    crc=`echo "$line" | cut -f1 -d' '`
    name=`echo "$line" | cut -f3- -d' '`

    # Remove all files with crc in rm_this var
    for opt_crc in $opt_rm; do
        if [ $opt_crc -eq $crc ]; then
            rm -v "$name"
            continue 2
        fi
    done

    # Look for duplicates
    if [ $crc -eq $crc_old ]; then
        # Print CSV and don't prompt if '-l' is specified
        if [ $lflag -eq 1 ]; then
            echo "$crc,$name"
            echo "$crc_old $name_old"
            continue
        fi

        echo "==> Found duplicate"
        echo "1: $crc $name"
        echo "2: $crc_old $name_old"
        echo -n "==> Remove (1/2/[B]oth/[A]ll)? "

        read user_input 0</dev/tty # haxx

        case $user_input in
            1) rm -v "$name" ;;
            2) rm -v "$name_old" ;;
            B) rm -v "$name" "$name_old" ;;
            A) rm -v "$name" "$name_old"; opt_rm="$opt_rm $crc " ;;
            *) echo "==> Skipping.." ;;
        esac

        echo
    fi

    crc_old=$crc
    name_old="$name"
done 
