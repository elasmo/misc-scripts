#!/bin/sh
if ! type xxd >/dev/null; then
    echo "xxd not found"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) <string>"
    exit 1
fi

echo -n $1 | xxd -plain | sed 's/\(..\)/%\1/g'
