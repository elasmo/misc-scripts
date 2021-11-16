#!/bin/sh
curl -s https://dns.loopia.se/checkip/checkip.php | sed 's/^.*: \([^<]*\).*$/\1/'
