#!/bin/sh
#
# File duplicate removal helper
# 
# remove-dups.sh -f directory/
# remove-dups.sh -f cksum.out
# remove-dups.sh -f cksum.out -l
#
usage() {
    printf "Usage: %s [-l] [-d dir] [-f] file|dir\n" "`basename $0`"
    exit 2
}

crc_old=0
name_old=""
rm_this=""
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

echo "$sorted" | while read line; do
    crc=`echo "$line" | cut -f1 -d' '`
    name=`echo "$line" | cut -f3- -d' '`

    # Remove all files with crc in rm_this var
    c=0
    for rm_crc in $rm_this; do
        if [ $rm_crc -eq $crc ]; then
            echo rm -v "$name"
            c=1
            break
        fi
    done
    [ $c -eq 1 ] && continue

    # Look for duplicates
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
