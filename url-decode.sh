#!/bin/sh
if ! type xxd >/dev/null; then
    echo "xxd not found"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) <string>"
    exit 1
fi

url="0:$(echo -n "$@" | sed 's/%/ /g')"
echo $url | xxd -r
