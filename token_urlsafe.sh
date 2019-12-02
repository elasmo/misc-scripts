#!/usr/bin/env bash
token_urlsafe() {                                                                                                                                                                              
    local nbytes=32
    if [ "$1" != "" ]; then
        nbytes=$1
    fi
    echo "$(dd if=/dev/urandom bs=${nbytes} count=1 2> /dev/null | base64 -w0 | tr '+/' '-_' | tr -d  '=')"
}
