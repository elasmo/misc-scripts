#!/bin/sh
# 
# Generate a random MAC address
#
tr -dc A-F0-9 < /dev/urandom | head -c 10 | sed -r 's/(..)/\1:/g;s/:$//;s/^/02:/'
