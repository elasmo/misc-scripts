#!/bin/sh
[ -z "$(which curl)" ] && echo "curl required" && exit 1 
echo $(curl -s https://dns.loopia.se/checkip/checkip.php | sed 's/^.*: \([^<]*\).*$/\1/')
